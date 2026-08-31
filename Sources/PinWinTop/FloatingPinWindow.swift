import Cocoa

class FloatingPinWindow: NSWindow {

    var isPinned = false
    private var pinButton: NSButton!
    private var pinTimer: Timer?
    private var targetAXWindow: AXUIElement?

    init() {
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 24, height: 24),
            styleMask: .borderless,
            backing: .buffered,
            defer: false
        )

        self.level = .floating // Stay on top
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        self.backgroundColor = .clear
        self.isOpaque = false
        self.hasShadow = false
        self.ignoresMouseEvents = false

        setupButton()
    }

    private func setupButton() {
        pinButton = NSButton(frame: NSRect(x: 0, y: 0, width: 24, height: 24))
        pinButton.bezelStyle = .circular
        pinButton.setButtonType(.pushOnPushOff)
        pinButton.title = "📌"
        pinButton.target = self
        pinButton.action = #selector(togglePin)
        pinButton.isBordered = false
        pinButton.wantsLayer = true
        pinButton.layer?.backgroundColor = NSColor.windowBackgroundColor.withAlphaComponent(0.8).cgColor
        pinButton.layer?.cornerRadius = 12

        self.contentView?.addSubview(pinButton)
    }

    func attachTo(axWindow: AXUIElement, at position: CGPoint) {
        self.targetAXWindow = axWindow
        self.setFrameOrigin(position)
        if !self.isVisible {
            self.orderFront(nil)
        }
    }

    func detach() {
        if isPinned {
            forceUnpin()
        }
        self.targetAXWindow = nil
        self.orderOut(nil)
    }

    @objc private func togglePin() {
        isPinned.toggle()
        if isPinned {
            pinButton.layer?.backgroundColor = NSColor.controlAccentColor.withAlphaComponent(0.8).cgColor
            startPinning()
        } else {
            pinButton.layer?.backgroundColor = NSColor.windowBackgroundColor.withAlphaComponent(0.8).cgColor
            stopPinning()

            // Trigger a re-evaluation of current window to reattach correctly
            if let delegate = NSApplication.shared.delegate as? AppDelegate {
                if let activeApp = NSWorkspace.shared.frontmostApplication {
                    delegate.windowTracker.observeApp(activeApp)
                }
            }
        }
    }

    func forceUnpin() {
        isPinned = false
        pinButton.state = .off
        pinButton.layer?.backgroundColor = NSColor.windowBackgroundColor.withAlphaComponent(0.8).cgColor
        stopPinning()
    }

    private func startPinning() {
        guard let window = targetAXWindow else { return }

        // Timer to continually force the window to the front
        pinTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            let error = AXUIElementPerformAction(window, kAXRaiseAction as CFString)
            if error != .success {
                // If we get an error (e.g., window destroyed), stop the timer
                self.forceUnpin()
                self.detach()
            }
        }
    }

    private func stopPinning() {
        pinTimer?.invalidate()
        pinTimer = nil
    }

    override var canBecomeKey: Bool {
        return false // Don't steal focus
    }
}
