import SwiftUI

struct TaskListView: View {
    @EnvironmentObject var storage: StorageManager
    @State private var searchText = ""
    @State private var showNewTask = false
    @State private var selectedTask: OzzieTask?
    @State private var showCompleted = false

    var filteredTasks: [OzzieTask] {
        if searchText.isEmpty {
            return storage.activeTasks
        }
        return storage.searchTasks(query: searchText)
    }

    var body: some View {
        VStack(spacing: 0) {
            headerBar
            searchBar
            Divider()

            if let task = selectedTask {
                TaskDetailView(task: task, onBack: {
                    selectedTask = nil
                })
                .environmentObject(storage)
            } else {
                taskList
            }
        }
        .frame(width: 380, height: 500)
        .background(Color(nsColor: .windowBackgroundColor))
        .sheet(isPresented: $showNewTask) {
            NewTaskView(isPresented: $showNewTask)
                .environmentObject(storage)
        }
    }

    // MARK: - Header

    private var headerBar: some View {
        HStack {
            Image(nsImage: WizardIcon.createLargeIcon(size: 24))
                .resizable()
                .frame(width: 24, height: 24)
                .clipShape(RoundedRectangle(cornerRadius: 4))

            Text("Ozzie")
                .font(.system(size: 16, weight: .bold, design: .rounded))

            Spacer()

            Button(action: { showNewTask = true }) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 18))
                    .foregroundColor(.accentColor)
            }
            .buttonStyle(.plain)
            .help("New Task (Cmd+Option+N)")

            Menu {
                Button(showCompleted ? "Hide Completed" : "Show Completed") {
                    showCompleted.toggle()
                }
                Divider()
                Button("Quit Ozzie") {
                    NSApplication.shared.terminate(nil)
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
            .menuStyle(.borderlessButton)
            .frame(width: 24)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(nsColor: .windowBackgroundColor))
    }

    // MARK: - Search

    private var searchBar: some View {
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
        .padding(.bottom, 8)
    }

    // MARK: - Task List

    private var taskList: some View {
        ScrollView {
            LazyVStack(spacing: 2) {
                if filteredTasks.isEmpty {
                    emptyState
                } else {
                    ForEach(filteredTasks) { task in
                        TaskRowView(task: task) {
                            selectedTask = task
                        }
                        .contextMenu {
                            taskContextMenu(for: task)
                        }
                    }
                }

                if showCompleted && !storage.completedTasks.isEmpty {
                    completedSection
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(nsImage: WizardIcon.createLargeIcon(size: 64))
                .resizable()
                .frame(width: 64, height: 64)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .opacity(0.6)

            Text("No tasks yet")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.secondary)

            Text("Highlight text and press\nCmd+Option+N to create a task")
                .font(.system(size: 12))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
    }

    private var completedSection: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("COMPLETED")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.secondary)
                .padding(.horizontal, 12)
                .padding(.top, 16)
                .padding(.bottom, 4)

            ForEach(storage.completedTasks) { task in
                TaskRowView(task: task) {
                    selectedTask = task
                }
                .opacity(0.6)
                .contextMenu {
                    taskContextMenu(for: task)
                }
            }
        }
    }

    @ViewBuilder
    private func taskContextMenu(for task: OzzieTask) -> some View {
        Button("Mark as To Do") {
            var updated = task
            updated.status = .todo
            storage.updateTask(updated)
        }
        Button("Mark as In Progress") {
            var updated = task
            updated.status = .inProgress
            storage.updateTask(updated)
        }
        Button("Mark as Done") {
            var updated = task
            updated.status = .done
            storage.updateTask(updated)
        }
        Divider()
        Button("Delete Task", role: .destructive) {
            storage.deleteTask(task)
        }
    }
}
