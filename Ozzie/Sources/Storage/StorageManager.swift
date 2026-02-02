import Foundation
import Combine

class StorageManager: ObservableObject {
    static let shared = StorageManager()

    @Published var tasks: [OzzieTask] = []

    private let fileManager = FileManager.default
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    private var storageDirectory: URL {
        let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let ozzieDir = appSupport.appendingPathComponent("Ozzie", isDirectory: true)
        if !fileManager.fileExists(atPath: ozzieDir.path) {
            try? fileManager.createDirectory(at: ozzieDir, withIntermediateDirectories: true)
        }
        return ozzieDir
    }

    private var tasksFileURL: URL {
        storageDirectory.appendingPathComponent("tasks.json")
    }

    var screenshotsDirectory: URL {
        let dir = storageDirectory.appendingPathComponent("screenshots", isDirectory: true)
        if !fileManager.fileExists(atPath: dir.path) {
            try? fileManager.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }

    private init() {
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted
        decoder.dateDecodingStrategy = .iso8601
        loadTasks()
    }

    // MARK: - CRUD Operations

    func loadTasks() {
        guard fileManager.fileExists(atPath: tasksFileURL.path) else {
            tasks = []
            return
        }
        do {
            let data = try Data(contentsOf: tasksFileURL)
            tasks = try decoder.decode([OzzieTask].self, from: data)
        } catch {
            print("Ozzie: Failed to load tasks: \(error)")
            tasks = []
        }
    }

    func saveTasks() {
        do {
            let data = try encoder.encode(tasks)
            try data.write(to: tasksFileURL, options: .atomic)
        } catch {
            print("Ozzie: Failed to save tasks: \(error)")
        }
    }

    func addTask(_ task: OzzieTask) {
        tasks.insert(task, at: 0)
        saveTasks()
    }

    func updateTask(_ task: OzzieTask) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
            saveTasks()
        }
    }

    func deleteTask(_ task: OzzieTask) {
        // Clean up screenshots
        for context in task.contexts where context.type == .screenshot {
            if let path = context.screenshotPath {
                try? fileManager.removeItem(atPath: path)
            }
        }
        tasks.removeAll { $0.id == task.id }
        saveTasks()
    }

    func addContextToTask(taskId: UUID, context: TaskContext) {
        if let index = tasks.firstIndex(where: { $0.id == taskId }) {
            tasks[index].contexts.append(context)
            saveTasks()
        }
    }

    func addSubtask(taskId: UUID, subtask: SubTask) {
        if let index = tasks.firstIndex(where: { $0.id == taskId }) {
            tasks[index].subtasks.append(subtask)
            saveTasks()
        }
    }

    func toggleSubtask(taskId: UUID, subtaskId: UUID) {
        if let taskIndex = tasks.firstIndex(where: { $0.id == taskId }),
           let subtaskIndex = tasks[taskIndex].subtasks.firstIndex(where: { $0.id == subtaskId }) {
            tasks[taskIndex].subtasks[subtaskIndex].isCompleted.toggle()
            saveTasks()
        }
    }

    func saveScreenshot(_ imageData: Data) -> String? {
        let filename = UUID().uuidString + ".png"
        let fileURL = screenshotsDirectory.appendingPathComponent(filename)
        do {
            try imageData.write(to: fileURL)
            return fileURL.path
        } catch {
            print("Ozzie: Failed to save screenshot: \(error)")
            return nil
        }
    }

    // MARK: - Queries

    var activeTasks: [OzzieTask] {
        tasks.filter { $0.status != .done }
            .sorted { task1, task2 in
                // Overdue first, then by due date, then by creation date
                if task1.isOverdue != task2.isOverdue {
                    return task1.isOverdue
                }
                if let d1 = task1.effectiveDueDate, let d2 = task2.effectiveDueDate {
                    return d1 < d2
                }
                if task1.effectiveDueDate != nil { return true }
                if task2.effectiveDueDate != nil { return false }
                return task1.createdAt > task2.createdAt
            }
    }

    var completedTasks: [OzzieTask] {
        tasks.filter { $0.status == .done }
            .sorted { $0.createdAt > $1.createdAt }
    }

    func searchTasks(query: String) -> [OzzieTask] {
        guard !query.isEmpty else { return activeTasks }
        let lowered = query.lowercased()
        return tasks.filter {
            $0.title.lowercased().contains(lowered) ||
            $0.contexts.contains { $0.content.lowercased().contains(lowered) }
        }
    }
}
