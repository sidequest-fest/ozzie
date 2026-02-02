import Foundation

enum TaskStatus: String, Codable, CaseIterable {
    case todo = "todo"
    case inProgress = "in_progress"
    case done = "done"

    var displayName: String {
        switch self {
        case .todo: return "To Do"
        case .inProgress: return "In Progress"
        case .done: return "Done"
        }
    }

    var icon: String {
        switch self {
        case .todo: return "circle"
        case .inProgress: return "circle.lefthalf.filled"
        case .done: return "checkmark.circle.fill"
        }
    }
}

struct OzzieTask: Identifiable, Codable {
    let id: UUID
    var title: String
    var createdAt: Date
    var dueDate: Date?
    var dueTime: Date?
    var status: TaskStatus
    var subtasks: [SubTask]
    var contexts: [TaskContext]
    var summary: String?
    var notificationScheduled: Bool

    init(
        id: UUID = UUID(),
        title: String,
        createdAt: Date = Date(),
        dueDate: Date? = nil,
        dueTime: Date? = nil,
        status: TaskStatus = .todo,
        subtasks: [SubTask] = [],
        contexts: [TaskContext] = [],
        summary: String? = nil,
        notificationScheduled: Bool = false
    ) {
        self.id = id
        self.title = title
        self.createdAt = createdAt
        self.dueDate = dueDate
        self.dueTime = dueTime
        self.status = status
        self.subtasks = subtasks
        self.contexts = contexts
        self.summary = summary
        self.notificationScheduled = notificationScheduled
    }

    var completedSubtasks: Int {
        subtasks.filter { $0.isCompleted }.count
    }

    var progress: Double {
        guard !subtasks.isEmpty else { return status == .done ? 1.0 : 0.0 }
        return Double(completedSubtasks) / Double(subtasks.count)
    }

    var isOverdue: Bool {
        guard let due = effectiveDueDate else { return false }
        return due < Date() && status != .done
    }

    var effectiveDueDate: Date? {
        guard let dueDate = dueDate else { return nil }
        if let dueTime = dueTime {
            let calendar = Calendar.current
            let dateComponents = calendar.dateComponents([.year, .month, .day], from: dueDate)
            let timeComponents = calendar.dateComponents([.hour, .minute], from: dueTime)
            var combined = DateComponents()
            combined.year = dateComponents.year
            combined.month = dateComponents.month
            combined.day = dateComponents.day
            combined.hour = timeComponents.hour
            combined.minute = timeComponents.minute
            return calendar.date(from: combined)
        }
        return dueDate
    }
}
