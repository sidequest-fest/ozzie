import AppKit
import Carbon.HIToolbox

/// Manages global keyboard shortcuts for Ozzie
/// Cmd+Option+N: New task from highlighted text
/// Cmd+Option+A: Add context to existing task
/// Cmd+Option+S: Screenshot capture and attach to task
class HotkeyManager {
    static let shared = HotkeyManager()

    var onNewTask: (() -> Void)?
    var onAddContext: (() -> Void)?
    var onScreenshot: (() -> Void)?

    private var newTaskHotkeyRef: EventHotKeyRef?
    private var addContextHotkeyRef: EventHotKeyRef?
    private var screenshotHotkeyRef: EventHotKeyRef?

    private static let newTaskHotkeyId = UInt32(1)
    private static let addContextHotkeyId = UInt32(2)
    private static let screenshotHotkeyId = UInt32(3)

    // Store a reference so the C callback can reach us
    private static var instance: HotkeyManager?

    private init() {
        HotkeyManager.instance = self
    }

    func registerHotkeys() {
        // Install Carbon event handler for hotkeys
        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))

        InstallEventHandler(
            GetApplicationEventTarget(),
            { (_, event, _) -> OSStatus in
                var hotkeyId = EventHotKeyID()
                GetEventParameter(
                    event,
                    EventParamName(kEventParamDirectObject),
                    EventParamType(typeEventHotKeyID),
                    nil,
                    MemoryLayout<EventHotKeyID>.size,
                    nil,
                    &hotkeyId
                )

                DispatchQueue.main.async {
                    switch hotkeyId.id {
                    case HotkeyManager.newTaskHotkeyId:
                        HotkeyManager.instance?.onNewTask?()
                    case HotkeyManager.addContextHotkeyId:
                        HotkeyManager.instance?.onAddContext?()
                    case HotkeyManager.screenshotHotkeyId:
                        HotkeyManager.instance?.onScreenshot?()
                    default:
                        break
                    }
                }

                return noErr
            },
            1,
            &eventType,
            nil,
            nil
        )

        // Cmd+Option+N → New task
        var newTaskId = EventHotKeyID(signature: OSType(0x4F5A5A49), id: HotkeyManager.newTaskHotkeyId) // "OZZI"
        RegisterEventHotKey(
            UInt32(kVK_ANSI_N),
            UInt32(cmdKey | optionKey),
            newTaskId,
            GetApplicationEventTarget(),
            0,
            &newTaskHotkeyRef
        )

        // Cmd+Option+A → Add context
        var addContextId = EventHotKeyID(signature: OSType(0x4F5A5A49), id: HotkeyManager.addContextHotkeyId)
        RegisterEventHotKey(
            UInt32(kVK_ANSI_A),
            UInt32(cmdKey | optionKey),
            addContextId,
            GetApplicationEventTarget(),
            0,
            &addContextHotkeyRef
        )

        // Cmd+Option+S → Screenshot
        var screenshotId = EventHotKeyID(signature: OSType(0x4F5A5A49), id: HotkeyManager.screenshotHotkeyId)
        RegisterEventHotKey(
            UInt32(kVK_ANSI_S),
            UInt32(cmdKey | optionKey),
            screenshotId,
            GetApplicationEventTarget(),
            0,
            &screenshotHotkeyRef
        )

        print("Ozzie: Global hotkeys registered (Cmd+Option+N/A/S)")
    }

    func unregisterHotkeys() {
        if let ref = newTaskHotkeyRef { UnregisterEventHotKey(ref) }
        if let ref = addContextHotkeyRef { UnregisterEventHotKey(ref) }
        if let ref = screenshotHotkeyRef { UnregisterEventHotKey(ref) }
    }
}
