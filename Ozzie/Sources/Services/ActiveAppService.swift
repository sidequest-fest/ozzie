import AppKit

class ActiveAppService {
    static let shared = ActiveAppService()

    private init() {}

    func frontmostAppName() -> String {
        if let app = NSWorkspace.shared.frontmostApplication {
            return app.localizedName ?? app.bundleIdentifier ?? "Unknown"
        }
        return "Unknown"
    }

    func getSelectedText() -> String? {
        // Use the pasteboard to get selected text
        // The user highlights text, and we grab it from the general pasteboard
        // We use a copy-then-read approach: simulate Cmd+C, then read pasteboard

        let pasteboard = NSPasteboard.general
        let previousContents = pasteboard.string(forType: .string)
        let previousChangeCount = pasteboard.changeCount

        // Simulate Cmd+C via CGEvent
        let source = CGEventSource(stateID: .combinedSessionState)

        let keyDown = CGEvent(keyboardEventSource: source, virtualKey: 0x08, keyDown: true) // 'c' key
        keyDown?.flags = .maskCommand
        let keyUp = CGEvent(keyboardEventSource: source, virtualKey: 0x08, keyDown: false)
        keyUp?.flags = .maskCommand

        keyDown?.post(tap: .cghidEventTap)
        keyUp?.post(tap: .cghidEventTap)

        // Brief wait for the copy to happen
        Thread.sleep(forTimeInterval: 0.1)

        // Check if pasteboard changed
        if pasteboard.changeCount != previousChangeCount {
            let newText = pasteboard.string(forType: .string)

            // Restore previous pasteboard contents
            if let previous = previousContents {
                pasteboard.clearContents()
                pasteboard.setString(previous, forType: .string)
            }

            return newText
        }

        return nil
    }
}
