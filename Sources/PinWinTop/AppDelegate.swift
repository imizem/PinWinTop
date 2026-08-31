import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {

    var statusItem: NSStatusItem!
    let windowTracker = WindowTracker()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Accessibility check
        if !AccessibilityManager.shared.isAccessibilityTrusted() {
            AccessibilityManager.shared.promptForAccessibility()
        }

        setupMenu()
        windowTracker.startTracking()
    }

    func setupMenu() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem.button {
            button.title = "📌" // Simple pin icon for now
            button.toolTip = "PinWinTop"
        }

        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Settings...", action: #selector(openSettings), keyEquivalent: ","))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "q"))

        statusItem.menu = menu
    }

    @objc func openSettings() {
        // Placeholder for future settings
        let alert = NSAlert()
        alert.messageText = "Settings"
        alert.informativeText = "Settings will be available in a future update."
        alert.runModal()
    }

    @objc func quitApp() {
        NSApplication.shared.terminate(self)
    }
}
