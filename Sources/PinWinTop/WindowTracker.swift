import Cocoa
import ApplicationServices

class WindowTracker {

    let floatingPin = FloatingPinWindow()
    private var observer: AXObserver?
    private var currentAppElement: AXUIElement?
    var currentWindowElement: AXUIElement?

    func startTracking() {
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(activeAppDidChange), name: NSWorkspace.didActivateApplicationNotification, object: nil)

        // Setup initial focus
        if let activeApp = NSWorkspace.shared.frontmostApplication {
            observeApp(activeApp)
        }
    }

    @objc private func activeAppDidChange(notification: Notification) {
        guard !floatingPin.isPinned else { return } // Don't track if pinned
        guard let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication else { return }

        // Don't track ourselves
        if app.bundleIdentifier == Bundle.main.bundleIdentifier { return }

        observeApp(app)
    }

    func observeApp(_ app: NSRunningApplication) {
        removeObserver()

        let pid = app.processIdentifier
        let appElement = AXUIElementCreateApplication(pid)
        currentAppElement = appElement

        var observerRaw: AXObserver?
        let result = AXObserverCreate(pid, observerCallback, &observerRaw)
        if result == .success, let newObserver = observerRaw {
            observer = newObserver

            // Add observer for window focus changes
            AXObserverAddNotification(newObserver, appElement, kAXFocusedWindowChangedNotification as CFString, Unmanaged.passUnretained(self).toOpaque())
            // Add observer for window movement
            AXObserverAddNotification(newObserver, appElement, kAXWindowMovedNotification as CFString, Unmanaged.passUnretained(self).toOpaque())
            // Add observer for window resizing
            AXObserverAddNotification(newObserver, appElement, kAXWindowResizedNotification as CFString, Unmanaged.passUnretained(self).toOpaque())
            // Add observer for window close
            AXObserverAddNotification(newObserver, appElement, kAXUIElementDestroyedNotification as CFString, Unmanaged.passUnretained(self).toOpaque())

            CFRunLoopAddSource(RunLoop.current.getCFRunLoop(), AXObserverGetRunLoopSource(newObserver), .defaultMode)

            // Immediately check for the focused window
            updateTargetWindow()
        }
    }

    private func removeObserver() {
        if let obs = observer {
            CFRunLoopRemoveSource(RunLoop.current.getCFRunLoop(), AXObserverGetRunLoopSource(obs), .defaultMode)
            observer = nil
        }
        currentAppElement = nil
    }

    func updateTargetWindow() {
        guard !floatingPin.isPinned else { return } // Don't track if pinned
        guard let appElement = currentAppElement else {
            floatingPin.detach()
            return
        }

        var focusedWindowRaw: CFTypeRef?
        let result = AXUIElementCopyAttributeValue(appElement, kAXFocusedWindowAttribute as CFString, &focusedWindowRaw)

        if result == .success, let window = focusedWindowRaw {
            let windowElement = window as! AXUIElement
            currentWindowElement = windowElement
            updatePinPosition()
        } else {
            floatingPin.detach()
        }
    }

    func updatePinPosition() {
        guard let windowElement = currentWindowElement else { return }

        var positionRaw: CFTypeRef?
        var sizeRaw: CFTypeRef?

        let posResult = AXUIElementCopyAttributeValue(windowElement, kAXPositionAttribute as CFString, &positionRaw)
        let sizeResult = AXUIElementCopyAttributeValue(windowElement, kAXSizeAttribute as CFString, &sizeRaw)

        if posResult == .success, sizeResult == .success {
            var position = CGPoint.zero
            var size = CGSize.zero

            AXValueGetValue(positionRaw as! AXValue, .cgPoint, &position)
            AXValueGetValue(sizeRaw as! AXValue, .cgSize, &size)

            // Calculate position for the pin. We want it left of standard controls.
            // Y needs conversion because AX origin is top-left, AppKit is bottom-left
            guard let screen = NSScreen.screens.first else { return }
            let appKitY = screen.frame.height - position.y - 24

            // Place to the left of standard traffic lights (~30px left)
            let finalPoint = CGPoint(x: position.x - 30, y: appKitY - 2)

            floatingPin.attachTo(axWindow: windowElement, at: finalPoint)
        }
    }

    func handleWindowDestroyed(element: AXUIElement) {
        if CFEqual(element, currentWindowElement) {
            floatingPin.detach()
            currentWindowElement = nil
            // If it was pinned, we need to unpin
            if floatingPin.isPinned {
                floatingPin.forceUnpin()
            }
        }
    }
}

// Global callback for AXObserver
private func observerCallback(_ observer: AXObserver, _ element: AXUIElement, _ notification: CFString, _ refcon: UnsafeMutableRawPointer?) {
    guard let refcon = refcon else { return }
    let tracker = Unmanaged<WindowTracker>.fromOpaque(refcon).takeUnretainedValue()

    if notification == kAXFocusedWindowChangedNotification as CFString {
        tracker.updateTargetWindow()
    } else if notification == kAXWindowMovedNotification as CFString || notification == kAXWindowResizedNotification as CFString {
        if tracker.floatingPin.isPinned {
            // We still need to update position when pinned!
            if CFEqual(element, tracker.currentWindowElement) {
                tracker.updatePinPosition()
            }
        } else {
            tracker.updatePinPosition()
        }
    } else if notification == kAXUIElementDestroyedNotification as CFString {
        tracker.handleWindowDestroyed(element: element)
    }
}
