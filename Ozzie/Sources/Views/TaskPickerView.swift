import SwiftUI

/// Shown when the user adds context via hotkey — lets them pick which task to attach it to
struct TaskPickerView: View {
    @EnvironmentObject var storage: StorageManager
    @State private var searchText = ""
    @State private var createNewTask = false

    let contextText: String
    let sourceApp: String
    var screenshotPath: String? = nil
    var isScreenshot: Bool = false

    var filteredTasks: [OzzieTask] {
        if searchText.isEmpty {
            return storage.activeTasks
        }
        return storage.searchTasks(query: searchText)
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            contextPreview
            Divider()

            if createNewTask {
                newTaskField
            } else {
                taskPickerList
            }
        }
        .frame(width: 380, height: 500)
        .background(Color(nsColor: .windowBackgroundColor))
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            Image(systemName: isScreenshot ? "camera.viewfinder" : "doc.text.fill")
                .foregroundColor(.accentColor)

            Text(isScreenshot ? "Attach Screenshot" : "Add Context")
                .font(.system(size: 15, weight: .bold))

            Spacer()

            Button("Done") {
                switchToTaskList()
            }
            .font(.system(size: 13))
            .buttonStyle(.plain)
            .foregroundColor(.accentColor)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    // MARK: - Context Preview

    private var contextPreview: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 6) {
                Image(systemName: "app.badge")
                    .font(.system(size: 10))
                Text("From: \(sourceApp)")
                    .font(.system(size: 11))
            }
            .foregroundColor(.secondary)

            if isScreenshot, let path = screenshotPath, let image = NSImage(contentsOfFile: path) {
                Image(nsImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: 60)
                    .cornerRadius(4)
            }

            Text(contextText)
                .font(.system(size: 12))
                .lineLimit(3)
                .foregroundColor(.primary)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.accentColor.opacity(0.06))
    }

    // MARK: - Task Picker

    private var taskPickerList: some View {
        VStack(spacing: 0) {
            // Search
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                    .font(.system(size: 12))
                TextField("Search tasks...", text: $searchText)
                    .textFieldStyle(.plain)
                    .font(.system(size: 13))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(nsColor: .controlBackgroundColor))
            .cornerRadius(8)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)

            // Create new option
            Button(action: { createNewTask = true }) {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.accentColor)
                    Text("Create new task with this context")
                        .font(.system(size: 13, weight: .medium))
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
            .buttonStyle(.plain)

            Divider()
                .padding(.horizontal, 16)

            // Task list
            ScrollView {
                LazyVStack(spacing: 2) {
                    ForEach(filteredTasks) { task in
                        Button(action: { attachToTask(task) }) {
                            HStack(spacing: 10) {
                                Image(systemName: task.status.icon)
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(task.title)
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(.primary)
                                        .lineLimit(1)

                                    Text("\(task.contexts.count) context items")
                                        .font(.system(size: 11))
                                        .foregroundColor(.secondary)
                                }

                                Spacer()

                                Image(systemName: "plus.circle")
                                    .foregroundColor(.accentColor)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color(nsColor: .controlBackgroundColor).opacity(0.5))
                            .cornerRadius(6)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
            }
        }
    }

    // MARK: - New Task Field

    @State private var newTaskTitle = ""

    private var newTaskField: some View {
        VStack(spacing: 12) {
            TextField("Task title...", text: $newTaskTitle)
                .textFieldStyle(.roundedBorder)
                .font(.system(size: 14))
                .padding(.horizontal, 16)
                .padding(.top, 12)

            HStack(spacing: 12) {
                Button("Cancel") {
                    createNewTask = false
                    newTaskTitle = ""
                }
                .buttonStyle(.plain)
                .foregroundColor(.secondary)

                Button("Create & Attach") {
                    createNewAndAttach()
                }
                .buttonStyle(.plain)
                .foregroundColor(.accentColor)
                .disabled(newTaskTitle.isEmpty)
            }
            .padding(.horizontal, 16)

            Spacer()
        }
    }

    // MARK: - Actions

    private func attachToTask(_ task: OzzieTask) {
        let context = TaskContext(
            content: contextText,
            sourceApp: sourceApp,
            type: isScreenshot ? .screenshot : .text,
            screenshotPath: screenshotPath
        )

        storage.addContextToTask(taskId: task.id, context: context)
        switchToTaskList()
    }

    private func createNewAndAttach() {
        let title = newTaskTitle.isEmpty ? contextText.components(separatedBy: .newlines).first ?? "New Task" : newTaskTitle

        let context = TaskContext(
            content: contextText,
            sourceApp: sourceApp,
            type: isScreenshot ? .screenshot : .text,
            screenshotPath: screenshotPath
        )

        let task = OzzieTask(title: String(title.prefix(100)), contexts: [context])
        storage.addTask(task)
        switchToTaskList()
    }

    private func switchToTaskList() {
        // Replace popover content with task list
        if let popover = NSApp.windows.first(where: { $0.contentViewController is NSHostingController<TaskPickerView> }) {
            // Just close — the AppDelegate will handle resetting
        }

        // Reset the popover content to TaskListView via notification
        NotificationCenter.default.post(name: .resetPopoverContent, object: nil)
    }
}

extension Notification.Name {
    static let resetPopoverContent = Notification.Name("resetPopoverContent")
}
