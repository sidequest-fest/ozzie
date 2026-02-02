import Foundation
import UserNotifications

class OzzieNotificationManager {
    static let shared = OzzieNotificationManager()

    private let center = UNUserNotificationCenter.current()

    private init() {}

    func requestPermission() {
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Ozzie: Notification permission error: \(error)")
            }
            if granted {
                print("Ozzie: Notification permission granted")
            }
        }
    }

    func scheduleDeadlineNotifications(for task: OzzieTask) {
        guard let dueDate = task.effectiveDueDate, dueDate > Date() else { return }

        // Remove existing notifications for this task
        removeNotifications(for: task.id)

        // Schedule notification 1 hour before
        scheduleNotification(
            id: "\(task.id.uuidString)-1h",
            title: "Ozzie Reminder",
            body: "'\(task.title)' is due in 1 hour",
            date: dueDate.addingTimeInterval(-3600)
        )

        // Schedule notification 15 minutes before
        scheduleNotification(
            id: "\(task.id.uuidString)-15m",
            title: "Ozzie Reminder",
            body: "'\(task.title)' is due in 15 minutes!",
            date: dueDate.addingTimeInterval(-900)
        )

        // Schedule notification at due time
        scheduleNotification(
            id: "\(task.id.uuidString)-due",
            title: "Ozzie: Task Due Now",
            body: "'\(task.title)' is due right now!",
            date: dueDate
        )

        // Daily brief: schedule for 9 AM if the task is due today
        let calendar = Calendar.current
        if calendar.isDateInToday(dueDate) || calendar.isDateInTomorrow(dueDate) {
            scheduleDailyBrief()
        }
    }

    func scheduleDailyBrief() {
        let id = "ozzie-daily-brief"
        center.removePendingNotificationRequests(withIdentifiers: [id])

        var dateComponents = DateComponents()
        dateComponents.hour = 9
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        let activeTasks = StorageManager.shared.activeTasks
        let overdueCount = activeTasks.filter { $0.isOverdue }.count
        let todayCount = activeTasks.filter { task in
            guard let due = task.effectiveDueDate else { return false }
            return Calendar.current.isDateInToday(due)
        }.count

        var body = "You have \(activeTasks.count) active task\(activeTasks.count == 1 ? "" : "s")."
        if overdueCount > 0 {
            body += " \(overdueCount) overdue!"
        }
        if todayCount > 0 {
            body += " \(todayCount) due today."
        }

        let content = UNMutableNotificationContent()
        content.title = "Ozzie's Morning Brief"
        content.body = body
        content.sound = .default

        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        center.add(request)
    }

    func removeNotifications(for taskId: UUID) {
        let identifiers = [
            "\(taskId.uuidString)-1h",
            "\(taskId.uuidString)-15m",
            "\(taskId.uuidString)-due"
        ]
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
    }

    private func scheduleNotification(id: String, title: String, body: String, date: Date) {
        guard date > Date() else { return }

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute, .second],
            from: date
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        center.add(request) { error in
            if let error = error {
                print("Ozzie: Failed to schedule notification: \(error)")
            }
        }
    }
}
