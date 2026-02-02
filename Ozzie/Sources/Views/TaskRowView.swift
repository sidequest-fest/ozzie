import SwiftUI

struct TaskRowView: View {
    let task: OzzieTask
    let onTap: () -> Void

    @EnvironmentObject var storage: StorageManager

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 10) {
                // Status indicator
                statusButton

                // Task info
                VStack(alignment: .leading, spacing: 3) {
                    Text(task.title)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.primary)
                        .lineLimit(1)

                    HStack(spacing: 8) {
                        // Subtask progress
                        if !task.subtasks.isEmpty {
                            HStack(spacing: 3) {
                                Image(systemName: "checklist")
                                    .font(.system(size: 10))
                                Text("\(task.completedSubtasks)/\(task.subtasks.count)")
                                    .font(.system(size: 11))
                            }
                            .foregroundColor(.secondary)
                        }

                        // Context count
                        if !task.contexts.isEmpty {
                            HStack(spacing: 3) {
                                Image(systemName: "doc.text")
                                    .font(.system(size: 10))
                                Text("\(task.contexts.count)")
                                    .font(.system(size: 11))
                            }
                            .foregroundColor(.secondary)
                        }

                        // Due date
                        if let dueDate = task.effectiveDueDate {
                            HStack(spacing: 3) {
                                Image(systemName: "calendar")
                                    .font(.system(size: 10))
                                Text(formatDueDate(dueDate))
                                    .font(.system(size: 11))
                            }
                            .foregroundColor(task.isOverdue ? .red : .secondary)
                        }
                    }
                }

                Spacer()

                // Chevron
                Image(systemName: "chevron.right")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.secondary.opacity(0.5))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color(nsColor: .controlBackgroundColor).opacity(0.5))
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }

    private var statusButton: some View {
        Button(action: {
            var updated = task
            switch task.status {
            case .todo:
                updated.status = .inProgress
            case .inProgress:
                updated.status = .done
            case .done:
                updated.status = .todo
            }
            storage.updateTask(updated)
        }) {
            Image(systemName: task.status.icon)
                .font(.system(size: 16))
                .foregroundColor(statusColor)
        }
        .buttonStyle(.plain)
        .help("Cycle status: To Do → In Progress → Done")
    }

    private var statusColor: Color {
        switch task.status {
        case .todo: return .secondary
        case .inProgress: return .blue
        case .done: return .green
        }
    }

    private func formatDueDate(_ date: Date) -> String {
        let calendar = Calendar.current

        if calendar.isDateInToday(date) {
            let formatter = DateFormatter()
            formatter.dateFormat = "h:mm a"
            return "Today \(formatter.string(from: date))"
        } else if calendar.isDateInTomorrow(date) {
            return "Tomorrow"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"
            return formatter.string(from: date)
        }
    }
}
