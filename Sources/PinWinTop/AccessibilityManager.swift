import Cocoa
import ApplicationServices

class AccessibilityManager {

    static let shared = AccessibilityManager()

    private init() {}

    func isAccessibilityTrusted() -> Bool {
        let checkOptionPrompt = kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String
        let options = [checkOptionPrompt: false]
        return AXIsProcessTrustedWithOptions(options as CFDictionary)
    }

    func promptForAccessibility() {
        let alert = NSAlert()
        alert.messageText = "Accessibility Permissions Required"
        alert.informativeText = "PinWinTop requires Accessibility permissions to track window positions and keep them on top.\n\nPlease grant permissions in System Settings -> Privacy & Security -> Accessibility, then restart the app."
        alert.addButton(withTitle: "Open System Settings")
        alert.addButton(withTitle: "Quit")

        let response = alert.runModal()

        if response == .alertFirstButtonReturn {
            // Attempt to open the exact prefpane, falling back to general security pane
            if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
                NSWorkspace.shared.open(url)
            }
            NSApplication.shared.terminate(nil)
        } else {
            NSApplication.shared.terminate(nil)
        }
    }
}
