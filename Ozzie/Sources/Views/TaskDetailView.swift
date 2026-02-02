import SwiftUI

struct TaskDetailView: View {
    @EnvironmentObject var storage: StorageManager
    @State var task: OzzieTask
    let onBack: () -> Void

    @State private var newSubtaskTitle = ""
    @State private var isEditingTitle = false
    @State private var editedTitle = ""
    @State private var showDatePicker = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                backButton
                titleSection
                statusSection
                dateSection
                subtasksSection
                contextSection
            }
            .padding(16)
        }
    }

    // MARK: - Back Button

    private var backButton: some View {
        Button(action: {
            saveChanges()
            onBack()
        }) {
            HStack(spacing: 4) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 12, weight: .semibold))
                Text("Back")
                    .font(.system(size: 13))
            }
            .foregroundColor(.accentColor)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Title

    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            if isEditingTitle {
                TextField("Task title", text: $editedTitle, onCommit: {
                    task.title = editedTitle
                    isEditingTitle = false
                    saveChanges()
                })
                .textFieldStyle(.plain)
                .font(.system(size: 18, weight: .bold))
            } else {
                Text(task.title)
                    .font(.system(size: 18, weight: .bold))
                    .onTapGesture {
                        editedTitle = task.title
                        isEditingTitle = true
                    }
            }

            Text("Created \(formatFullDate(task.createdAt))")
                .font(.system(size: 11))
                .foregroundColor(.secondary)
        }
    }

    // MARK: - Status

    private var statusSection: some View {
        HStack(spacing: 8) {
            ForEach(TaskStatus.allCases, id: \.self) { status in
                Button(action: {
                    task.status = status
                    saveChanges()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: status.icon)
                            .font(.system(size: 11))
                        Text(status.displayName)
                            .font(.system(size: 12, weight: .medium))
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(task.status == status ? statusBgColor(status) : Color.clear)
                    .foregroundColor(task.status == status ? .white : .secondary)
                    .cornerRadius(6)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.secondary.opacity(0.2), lineWidth: task.status == status ? 0 : 1)
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Date

    private var dateSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(.secondary)
                    .font(.system(size: 13))

                if let dueDate = task.dueDate {
                    Text(formatFullDate(dueDate))
                        .font(.system(size: 13))
                        .foregroundColor(task.isOverdue ? .red : .primary)

                    Spacer()

                    Button("Change") {
                        showDatePicker.toggle()
                    }
                    .font(.system(size: 12))
                    .buttonStyle(.plain)
                    .foregroundColor(.accentColor)

                    Button(action: {
                        task.dueDate = nil
                        task.dueTime = nil
                        saveChanges()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                } else {
                    Button("Set due date") {
                        task.dueDate = Calendar.current.date(byAdding: .day, value: 1, to: Date())
                        showDatePicker = true
                    }
                    .font(.system(size: 13))
                    .buttonStyle(.plain)
                    .foregroundColor(.accentColor)
                }
            }

            if showDatePicker, let binding = Binding<Date>(
                get: { task.dueDate ?? Date() },
                set: { task.dueDate = $0; saveChanges() }
            ) as Binding<Date>? {
                DatePicker("Due:", selection: binding, displayedComponents: [.date, .hourAndMinute])
                    .datePickerStyle(.graphical)
                    .labelsHidden()
                    .onChange(of: task.dueDate) { _ in
                        task.dueTime = task.dueDate
                        saveChanges()
                    }
            }
        }
        .padding(12)
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(8)
    }

    // MARK: - Subtasks

    private var subtasksSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "checklist")
                    .foregroundColor(.secondary)
                    .font(.system(size: 13))
                Text("Subtasks")
                    .font(.system(size: 13, weight: .semibold))

                if !task.subtasks.isEmpty {
                    Text("\(task.completedSubtasks)/\(task.subtasks.count)")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.secondary.opacity(0.15))
                        .cornerRadius(4)
                }
            }

            // Progress bar
            if !task.subtasks.isEmpty {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.secondary.opacity(0.15))
                            .frame(height: 4)

                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.green)
                            .frame(width: geometry.size.width * task.progress, height: 4)
                    }
                }
                .frame(height: 4)
            }

            ForEach(task.subtasks) { subtask in
                HStack(spacing: 8) {
                    Button(action: {
                        toggleSubtask(subtask.id)
                    }) {
                        Image(systemName: subtask.isCompleted ? "checkmark.square.fill" : "square")
                            .font(.system(size: 14))
                            .foregroundColor(subtask.isCompleted ? .green : .secondary)
                    }
                    .buttonStyle(.plain)

                    Text(subtask.title)
                        .font(.system(size: 13))
                        .strikethrough(subtask.isCompleted)
                        .foregroundColor(subtask.isCompleted ? .secondary : .primary)

                    Spacer()

                    Button(action: {
                        deleteSubtask(subtask.id)
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary.opacity(0.5))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.vertical, 2)
            }

            // Add subtask field
            HStack(spacing: 8) {
                Image(systemName: "plus")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)

                TextField("Add subtask...", text: $newSubtaskTitle, onCommit: addSubtask)
                    .textFieldStyle(.plain)
                    .font(.system(size: 13))
            }
            .padding(.top, 4)
        }
        .padding(12)
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(8)
    }

    // MARK: - Context

    private var contextSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "doc.text")
                    .foregroundColor(.secondary)
                    .font(.system(size: 13))
                Text("Context")
                    .font(.system(size: 13, weight: .semibold))

                if !task.contexts.isEmpty {
                    Text("\(task.contexts.count)")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.secondary.opacity(0.15))
                        .cornerRadius(4)
                }
            }

            if task.contexts.isEmpty {
                Text("No context yet. Highlight text and press Cmd+Option+A to add.")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .padding(.vertical, 8)
            } else {
                ForEach(task.contexts) { context in
                    ContextItemView(context: context, onDelete: {
                        deleteContext(context.id)
                    })
                }
            }

            // Summary (placeholder for future AI)
            if let summary = task.summary {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 11))
                        Text("Summary")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundColor(.purple)

                    Text(summary)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                .padding(10)
                .background(Color.purple.opacity(0.08))
                .cornerRadius(6)
            }
        }
        .padding(12)
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(8)
    }

    // MARK: - Actions

    private func saveChanges() {
        storage.updateTask(task)

        // Schedule notifications if there's a due date
        if task.dueDate != nil {
            OzzieNotificationManager.shared.scheduleDeadlineNotifications(for: task)
        }
    }

    private func addSubtask() {
        guard !newSubtaskTitle.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        let subtask = SubTask(title: newSubtaskTitle)
        task.subtasks.append(subtask)
        newSubtaskTitle = ""
        saveChanges()
    }

    private func toggleSubtask(_ id: UUID) {
        if let index = task.subtasks.firstIndex(where: { $0.id == id }) {
            task.subtasks[index].isCompleted.toggle()
            saveChanges()
        }
    }

    private func deleteSubtask(_ id: UUID) {
        task.subtasks.removeAll { $0.id == id }
        saveChanges()
    }

    private func deleteContext(_ id: UUID) {
        task.contexts.removeAll { $0.id == id }
        saveChanges()
    }

    private func statusBgColor(_ status: TaskStatus) -> Color {
        switch status {
        case .todo: return .secondary
        case .inProgress: return .blue
        case .done: return .green
        }
    }

    private func formatFullDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Context Item

struct ContextItemView: View {
    let context: TaskContext
    let onDelete: () -> Void

    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: context.displayIcon)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)

                Text(context.sourceApp)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)

                Text("·")
                    .foregroundColor(.secondary)

                Text(formatRelativeDate(context.addedAt))
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)

                Spacer()

                Button(action: { isExpanded.toggle() }) {
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)

                Button(action: onDelete) {
                    Image(systemName: "xmark")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary.opacity(0.5))
                }
                .buttonStyle(.plain)
            }

            if context.type == .screenshot, let path = context.screenshotPath {
                if let image = NSImage(contentsOfFile: path) {
                    Image(nsImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: isExpanded ? 300 : 80)
                        .cornerRadius(4)
                        .clipped()
                }
            }

            if isExpanded || context.type == .text {
                Text(context.content)
                    .font(.system(size: 12))
                    .foregroundColor(.primary)
                    .lineLimit(isExpanded ? nil : 3)
            }
        }
        .padding(10)
        .background(Color(nsColor: .controlBackgroundColor).opacity(0.5))
        .cornerRadius(6)
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color.secondary.opacity(0.1), lineWidth: 1)
        )
    }

    private func formatRelativeDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
