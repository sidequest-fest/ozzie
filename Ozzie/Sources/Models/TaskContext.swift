import Foundation

enum ContextType: String, Codable {
    case text = "text"
    case screenshot = "screenshot"
}

struct TaskContext: Identifiable, Codable {
    let id: UUID
    var content: String
    var sourceApp: String
    var addedAt: Date
    var type: ContextType
    var screenshotPath: String?

    init(
        id: UUID = UUID(),
        content: String,
        sourceApp: String = "Unknown",
        addedAt: Date = Date(),
        type: ContextType = .text,
        screenshotPath: String? = nil
    ) {
        self.id = id
        self.content = content
        self.sourceApp = sourceApp
        self.addedAt = addedAt
        self.type = type
        self.screenshotPath = screenshotPath
    }

    var displayIcon: String {
        switch type {
        case .text: return "doc.text"
        case .screenshot: return "camera.viewfinder"
        }
    }
}
