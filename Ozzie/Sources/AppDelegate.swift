import AppKit
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var popover: NSPopover!
    private var eventMonitor: Any?
    private let storageManager = StorageManager.shared

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupMenuBar()
        setupPopover()
        setupHotkeys()
        setupEventMonitor()
        setupNotifications()
        setupPopoverResetObserver()
    }

    private func setupPopoverResetObserver() {
        NotificationCenter.default.addObserver(
            forName: .resetPopoverContent,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self = self else { return }
            self.popover.contentViewController = NSHostingController(
                rootView: TaskListView()
                    .environmentObject(self.storageManager)
            )
        }
    }

    // MARK: - Menu Bar Setup

    private func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        if let button = statusItem.button {
            button.image = WizardIcon.createMenuBarIcon()
            button.image?.size = NSSize(width: 18, height: 18)
            button.action = #selector(togglePopover)
            button.target = self
            button.toolTip = "Ozzie — Your Task Wizard"
        }
    }

    // MARK: - Popover

    private func setupPopover() {
        popover = NSPopover()
        popover.contentSize = NSSize(width: 380, height: 500)
        popover.behavior = .transient
        popover.animates = true
        popover.contentViewController = NSHostingController(
            rootView: TaskListView()
                .environmentObject(storageManager)
        )
    }

    @objc private func togglePopover() {
        guard let button = statusItem.button else { return }

        if popover.isShown {
            popover.performClose(nil)
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)

            // Bring app to front when popover opens
            NSApp.activate(ignoringOtherApps: true)
        }
    }

    private func closePopover() {
        if popover.isShown {
            popover.performClose(nil)
        }
    }

    // MARK: - Click-Outside-to-Dismiss

    private func setupEventMonitor() {
        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
            self?.closePopover()
        }
    }

    // MARK: - Global Hotkeys

    private func setupHotkeys() {
        let hotkeyManager = HotkeyManager.shared

        hotkeyManager.onNewTask = { [weak self] in
            self?.handleNewTask()
        }

        hotkeyManager.onAddContext = { [weak self] in
            self?.handleAddContext()
        }

        hotkeyManager.onScreenshot = { [weak self] in
            self?.handleScreenshot()
        }

        hotkeyManager.registerHotkeys()
    }

    // MARK: - Hotkey Handlers

    private func handleNewTask() {
        let sourceApp = ActiveAppService.shared.frontmostAppName()
        let selectedText = ActiveAppService.shared.getSelectedText()

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            let title = selectedText?.components(separatedBy: .newlines).first ?? "New Task"
            let trimmedTitle = String(title.prefix(100))

            var task = OzzieTask(title: trimmedTitle)

            if let text = selectedText, !text.isEmpty {
                let context = TaskContext(
                    content: text,
                    sourceApp: sourceApp,
                    type: .text
                )
                task.contexts.append(context)
            }

            self.storageManager.addTask(task)

            // Show popover to let user edit
            self.showPopover()
        }
    }

    private func handleAddContext() {
        let sourceApp = ActiveAppService.shared.frontmostAppName()
        let selectedText = ActiveAppService.shared.getSelectedText()

        DispatchQueue.main.async { [weak self] in
            guard let self = self,
                  let text = selectedText, !text.isEmpty else {
                return
            }

            // Show task picker popover
            let pickerView = TaskPickerView(
                contextText: text,
                sourceApp: sourceApp
            ).environmentObject(self.storageManager)

            self.popover.contentViewController = NSHostingController(rootView: pickerView)
            self.showPopover()
        }
    }

    private func handleScreenshot() {
        let sourceApp = ActiveAppService.shared.frontmostAppName()

        // Brief delay to let the user switch away from any UI
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            ScreenCaptureService.shared.captureSelection { [weak self] imageData, ocrText in
                guard let self = self,
                      let data = imageData else { return }

                DispatchQueue.main.async {
                    // Save screenshot
                    guard let path = self.storageManager.saveScreenshot(data) else { return }

                    let context = TaskContext(
                        content: ocrText ?? "[Screenshot]",
                        sourceApp: sourceApp,
                        type: .screenshot,
                        screenshotPath: path
                    )

                    // Show task picker — user chooses which task to attach to
                    let pickerView = TaskPickerView(
                        contextText: ocrText ?? "[Screenshot attached]",
                        sourceApp: sourceApp,
                        screenshotPath: path,
                        isScreenshot: true
                    ).environmentObject(self.storageManager)

                    self.popover.contentViewController = NSHostingController(rootView: pickerView)
                    self.showPopover()
                }
            }
        }
    }

    private func showPopover() {
        guard let button = statusItem.button else { return }
        if !popover.isShown {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            NSApp.activate(ignoringOtherApps: true)
        }
    }

    // MARK: - Notifications

    private func setupNotifications() {
        OzzieNotificationManager.shared.requestPermission()
        OzzieNotificationManager.shared.scheduleDailyBrief()
    }

    // MARK: - Cleanup

    func applicationWillTerminate(_ notification: Notification) {
        HotkeyManager.shared.unregisterHotkeys()
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
        }
    }
}
