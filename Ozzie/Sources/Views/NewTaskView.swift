import SwiftUI

struct NewTaskView: View {
    @EnvironmentObject var storage: StorageManager
    @Binding var isPresented: Bool

    @State private var title = ""
    @State private var hasDueDate = false
    @State private var dueDate = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
    @State private var subtaskText = ""
    @State private var subtasks: [String] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Text("New Task")
                    .font(.system(size: 16, weight: .bold))
                Spacer()
                Button("Cancel") {
                    isPresented = false
                }
                .buttonStyle(.plain)
                .foregroundColor(.secondary)
            }

            // Title
            TextField("What needs to be done?", text: $title)
                .textFieldStyle(.roundedBorder)
                .font(.system(size: 14))

            // Due date toggle
            Toggle(isOn: $hasDueDate) {
                HStack(spacing: 6) {
                    Image(systemName: "calendar")
                        .font(.system(size: 13))
                    Text("Set due date")
                        .font(.system(size: 13))
                }
            }
            .toggleStyle(.switch)

            if hasDueDate {
                DatePicker("Due:", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                    .font(.system(size: 13))
            }

            // Quick subtasks
            VStack(alignment: .leading, spacing: 6) {
                Text("Subtasks")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.secondary)

                ForEach(subtasks.indices, id: \.self) { index in
                    HStack {
                        Image(systemName: "square")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                        Text(subtasks[index])
                            .font(.system(size: 13))
                        Spacer()
                        Button(action: { subtasks.remove(at: index) }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 10))
                                .foregroundColor(.secondary)
                        }
                        .buttonStyle(.plain)
                    }
                }

                HStack(spacing: 6) {
                    Image(systemName: "plus")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                    TextField("Add subtask...", text: $subtaskText, onCommit: {
                        if !subtaskText.trimmingCharacters(in: .whitespaces).isEmpty {
                            subtasks.append(subtaskText)
                            subtaskText = ""
                        }
                    })
                    .textFieldStyle(.plain)
                    .font(.system(size: 13))
                }
            }

            Spacer()

            // Create button
            Button(action: createTask) {
                HStack {
                    Image(systemName: "sparkles")
                    Text("Create Task")
                        .font(.system(size: 14, weight: .semibold))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(title.isEmpty ? Color.secondary.opacity(0.3) : Color.accentColor)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .buttonStyle(.plain)
            .disabled(title.isEmpty)
        }
        .padding(20)
        .frame(width: 340, height: 420)
    }

    private func createTask() {
        let task = OzzieTask(
            title: title,
            dueDate: hasDueDate ? dueDate : nil,
            dueTime: hasDueDate ? dueDate : nil,
            subtasks: subtasks.map { SubTask(title: $0) }
        )

        storage.addTask(task)

        if hasDueDate {
            OzzieNotificationManager.shared.scheduleDeadlineNotifications(for: task)
        }

        isPresented = false
    }
}
