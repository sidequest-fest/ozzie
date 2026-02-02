#!/usr/bin/env python3
"""Generate the Ozzie Project Anatomy PDF."""

from reportlab.lib.pagesizes import letter
from reportlab.lib.units import inch
from reportlab.lib.colors import HexColor, black, white
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.platypus import (
    SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle,
    PageBreak, HRFlowable
)
from reportlab.lib.enums import TA_LEFT, TA_CENTER

# Colors
PURPLE = HexColor("#7B2FBE")
DARK_BG = HexColor("#1A1A2E")
ACCENT = HexColor("#9B59B6")
LIGHT_BG = HexColor("#F5F3FF")
GRAY = HexColor("#6B7280")
DARK = HexColor("#1F2937")
BLUE = HexColor("#3B82F6")
GREEN = HexColor("#10B981")
ORANGE = HexColor("#F59E0B")

def build_pdf():
    doc = SimpleDocTemplate(
        "/home/user/ozzie/Ozzie_Project_Anatomy.pdf",
        pagesize=letter,
        leftMargin=0.75*inch,
        rightMargin=0.75*inch,
        topMargin=0.75*inch,
        bottomMargin=0.75*inch,
    )

    styles = getSampleStyleSheet()

    # Custom styles
    title_style = ParagraphStyle(
        "OzzieTitle", parent=styles["Title"],
        fontSize=28, textColor=PURPLE, spaceAfter=4,
        fontName="Helvetica-Bold"
    )
    subtitle_style = ParagraphStyle(
        "OzzieSubtitle", parent=styles["Normal"],
        fontSize=13, textColor=GRAY, spaceAfter=20,
        fontName="Helvetica"
    )
    h1 = ParagraphStyle(
        "H1", parent=styles["Heading1"],
        fontSize=20, textColor=DARK, spaceAfter=10, spaceBefore=20,
        fontName="Helvetica-Bold"
    )
    h2 = ParagraphStyle(
        "H2", parent=styles["Heading2"],
        fontSize=15, textColor=PURPLE, spaceAfter=6, spaceBefore=14,
        fontName="Helvetica-Bold"
    )
    h3 = ParagraphStyle(
        "H3", parent=styles["Heading3"],
        fontSize=12, textColor=ACCENT, spaceAfter=4, spaceBefore=10,
        fontName="Helvetica-Bold"
    )
    body = ParagraphStyle(
        "OzzieBody", parent=styles["Normal"],
        fontSize=10.5, textColor=DARK, spaceAfter=6,
        fontName="Helvetica", leading=14
    )
    code = ParagraphStyle(
        "OzzieCode", parent=styles["Normal"],
        fontSize=9, textColor=DARK, spaceAfter=4,
        fontName="Courier", leading=12, leftIndent=16
    )
    bullet = ParagraphStyle(
        "OzzieBullet", parent=body,
        leftIndent=20, bulletIndent=8, spaceAfter=3
    )
    small = ParagraphStyle(
        "Small", parent=body, fontSize=9, textColor=GRAY
    )

    elements = []

    def hr():
        elements.append(Spacer(1, 6))
        elements.append(HRFlowable(width="100%", color=HexColor("#E5E7EB"), thickness=1))
        elements.append(Spacer(1, 6))

    def section(title_text):
        elements.append(Paragraph(title_text, h1))
        hr()

    def file_header(path, desc):
        elements.append(Paragraph(f"<b>{path}</b>", h2))
        elements.append(Paragraph(desc, body))

    def bullet_item(text):
        elements.append(Paragraph(f"• {text}", bullet))

    def code_line(text):
        elements.append(Paragraph(text.replace("<", "&lt;").replace(">", "&gt;"), code))

    # =============================================
    # COVER
    # =============================================
    elements.append(Spacer(1, 2*inch))
    elements.append(Paragraph("🧙 Ozzie the Wizard", title_style))
    elements.append(Paragraph("Project Anatomy — v1.0", subtitle_style))
    elements.append(Spacer(1, 0.3*inch))
    elements.append(Paragraph(
        "A native macOS menu bar task manager built with Swift &amp; SwiftUI. "
        "This document maps every file in the project, its purpose, key types, "
        "and how it connects to the rest of the system.",
        body
    ))
    elements.append(Spacer(1, 0.4*inch))

    # Quick reference table
    ref_data = [
        ["Platform", "macOS 14.0+ (Sonoma)"],
        ["Language", "Swift 5.9"],
        ["UI Framework", "SwiftUI + AppKit"],
        ["Build System", "XcodeGen → Xcode"],
        ["Storage", "Local JSON (~/ Library/Application Support/Ozzie/)"],
        ["Bundle ID", "com.ozzie.wizard"],
        ["Hotkeys", "Cmd+Option+N / A / S"],
    ]
    ref_table = Table(ref_data, colWidths=[1.8*inch, 4.2*inch])
    ref_table.setStyle(TableStyle([
        ("BACKGROUND", (0, 0), (0, -1), LIGHT_BG),
        ("TEXTCOLOR", (0, 0), (0, -1), PURPLE),
        ("FONTNAME", (0, 0), (0, -1), "Helvetica-Bold"),
        ("FONTNAME", (1, 0), (1, -1), "Helvetica"),
        ("FONTSIZE", (0, 0), (-1, -1), 10),
        ("BOTTOMPADDING", (0, 0), (-1, -1), 6),
        ("TOPPADDING", (0, 0), (-1, -1), 6),
        ("LEFTPADDING", (0, 0), (-1, -1), 10),
        ("GRID", (0, 0), (-1, -1), 0.5, HexColor("#E5E7EB")),
    ]))
    elements.append(ref_table)
    elements.append(PageBreak())

    # =============================================
    # TABLE OF CONTENTS
    # =============================================
    section("Table of Contents")
    toc = [
        "1. Architecture Overview",
        "2. Project Structure (File Tree)",
        "3. App Entry &amp; Lifecycle",
        "4. Data Models",
        "5. Storage Layer",
        "6. Views (UI)",
        "7. Services",
        "8. Resources &amp; Configuration",
        "9. Data Flow Diagrams",
        "10. Permissions &amp; Entitlements",
        "11. Hotkey Reference",
    ]
    for item in toc:
        elements.append(Paragraph(item, body))
    elements.append(PageBreak())

    # =============================================
    # 1. ARCHITECTURE OVERVIEW
    # =============================================
    section("1. Architecture Overview")
    elements.append(Paragraph(
        "Ozzie follows a <b>layered architecture</b> with clear separation of concerns:",
        body
    ))
    elements.append(Spacer(1, 8))

    layers = [
        ["Layer", "Files", "Responsibility"],
        ["Entry", "OzzieApp.swift", "App bootstrap, creates AppDelegate"],
        ["Coordination", "AppDelegate.swift", "Menu bar, popover, hotkey routing"],
        ["Models", "OzzieTask / SubTask / TaskContext", "Data structures, computed properties"],
        ["Storage", "StorageManager.swift", "JSON persistence, CRUD, search"],
        ["Views", "5 SwiftUI views", "All UI: list, detail, creation, picker"],
        ["Services", "4 service singletons", "Hotkeys, screenshots, OCR, notifications"],
        ["Resources", "WizardIcon.swift + config files", "Pixel art icon, plist, entitlements"],
    ]
    t = Table(layers, colWidths=[1.2*inch, 2.2*inch, 2.8*inch])
    t.setStyle(TableStyle([
        ("BACKGROUND", (0, 0), (-1, 0), PURPLE),
        ("TEXTCOLOR", (0, 0), (-1, 0), white),
        ("FONTNAME", (0, 0), (-1, 0), "Helvetica-Bold"),
        ("FONTSIZE", (0, 0), (-1, -1), 9.5),
        ("BOTTOMPADDING", (0, 0), (-1, -1), 5),
        ("TOPPADDING", (0, 0), (-1, -1), 5),
        ("LEFTPADDING", (0, 0), (-1, -1), 8),
        ("GRID", (0, 0), (-1, -1), 0.5, HexColor("#D1D5DB")),
        ("ROWBACKGROUNDS", (0, 1), (-1, -1), [white, LIGHT_BG]),
    ]))
    elements.append(t)
    elements.append(Spacer(1, 12))

    elements.append(Paragraph("<b>Key design decisions:</b>", body))
    bullet_item("<b>No dock icon</b> — LSUIElement=true makes Ozzie menu-bar-only")
    bullet_item("<b>Sandbox disabled</b> — needed for clipboard access, screenshot capture, and app detection")
    bullet_item("<b>Carbon hotkeys</b> — most reliable method for global shortcuts on macOS")
    bullet_item("<b>JSON storage</b> — simple, portable, easy to debug (just open the file)")
    bullet_item("<b>ObservableObject</b> — StorageManager publishes changes, all views react automatically")

    elements.append(PageBreak())

    # =============================================
    # 2. FILE TREE
    # =============================================
    section("2. Project Structure")

    tree = """Ozzie/
├── project.yml                          ← XcodeGen config
├── Assets.xcassets/                     ← App icon assets
└── Sources/
    ├── OzzieApp.swift                   ← @main entry point
    ├── AppDelegate.swift                ← Menu bar + popover coordinator
    ├── Info.plist                       ← App metadata (LSUIElement=true)
    ├── Ozzie.entitlements               ← Security permissions
    ├── Models/
    │   ├── OzzieTask.swift              ← Core task model
    │   ├── SubTask.swift                ← Subtask model
    │   └── TaskContext.swift            ← Context snippet model
    ├── Storage/
    │   └── StorageManager.swift         ← JSON persistence + CRUD
    ├── Views/
    │   ├── TaskListView.swift           ← Main popover (task list)
    │   ├── TaskRowView.swift            ← Compact task row
    │   ├── TaskDetailView.swift         ← Expanded task editor
    │   ├── NewTaskView.swift            ← Create task sheet
    │   └── TaskPickerView.swift         ← Context → task attachment
    ├── Services/
    │   ├── HotkeyManager.swift          ← Cmd+Option+N/A/S
    │   ├── ScreenCaptureService.swift   ← Screenshot + OCR
    │   ├── NotificationManager.swift    ← Deadline reminders
    │   └── ActiveAppService.swift       ← Frontmost app detection
    └── Resources/
        └── WizardIcon.swift             ← 8-bit pixel art icon"""

    for line in tree.split("\n"):
        # Split at ← for coloring
        if "←" in line:
            parts = line.split("←")
            elements.append(Paragraph(
                f"{parts[0].replace('<', '&lt;').replace('>', '&gt;')}← <i><font color='#9B59B6'>{parts[1].strip()}</font></i>",
                code
            ))
        else:
            elements.append(Paragraph(line.replace("<", "&lt;").replace(">", "&gt;"), code))

    elements.append(PageBreak())

    # =============================================
    # 3. APP ENTRY & LIFECYCLE
    # =============================================
    section("3. App Entry &amp; Lifecycle")

    file_header("Sources/OzzieApp.swift", "The <b>@main</b> entry point. Bootstraps the app with no visible windows.")
    bullet_item("Creates <font name='Courier'>AppDelegate</font> via <font name='Courier'>@NSApplicationDelegateAdaptor</font>")
    bullet_item("Returns an empty <font name='Courier'>Settings</font> scene — the app is entirely menu-bar-driven")
    bullet_item("This is the only file with the <font name='Courier'>@main</font> attribute")
    elements.append(Spacer(1, 8))

    file_header("Sources/AppDelegate.swift", "The <b>central coordinator</b>. Manages the status bar item, popover, hotkey routing, and notification setup.")
    elements.append(Paragraph("<b>Startup sequence</b> (applicationDidFinishLaunching):", body))
    steps = [
        "setupMenuBar() — Creates NSStatusItem with wizard icon",
        "setupPopover() — 380×500 NSPopover with TaskListView",
        "setupHotkeys() — Registers Cmd+Option+N/A/S via HotkeyManager",
        "setupEventMonitor() — Click-outside-to-dismiss listener",
        "setupNotifications() — Requests permission, schedules 9AM daily brief",
        "setupPopoverResetObserver() — Listens for .resetPopoverContent to swap views back",
    ]
    for i, s in enumerate(steps, 1):
        bullet_item(f"<b>{i}.</b> {s}")

    elements.append(Spacer(1, 8))
    elements.append(Paragraph("<b>Hotkey handlers:</b>", body))
    bullet_item("<b>handleNewTask()</b> — Gets selected text + source app → creates OzzieTask → opens popover")
    bullet_item("<b>handleAddContext()</b> — Gets selected text → swaps popover to TaskPickerView")
    bullet_item("<b>handleScreenshot()</b> — Launches screencapture → OCR → swaps popover to TaskPickerView")
    elements.append(Spacer(1, 6))
    elements.append(Paragraph(
        "<b>Dependency map:</b> Uses StorageManager, HotkeyManager, ActiveAppService, "
        "ScreenCaptureService, OzzieNotificationManager, WizardIcon, TaskListView, TaskPickerView",
        small
    ))

    elements.append(PageBreak())

    # =============================================
    # 4. DATA MODELS
    # =============================================
    section("4. Data Models")

    # OzzieTask
    file_header("Models/OzzieTask.swift", "The <b>core task model</b>. A Codable struct with status, subtasks, contexts, and due dates.")
    elements.append(Spacer(1, 4))

    task_fields = [
        ["Property", "Type", "Description"],
        ["id", "UUID", "Unique identifier (auto-generated)"],
        ["title", "String", "Task title (max 100 chars from highlighted text)"],
        ["createdAt", "Date", "Creation timestamp"],
        ["dueDate", "Date?", "Optional due date (date only)"],
        ["dueTime", "Date?", "Optional due time"],
        ["status", "TaskStatus", "todo → inProgress → done (cycles)"],
        ["subtasks", "[SubTask]", "Ordered list of checkable subtasks"],
        ["contexts", "[TaskContext]", "All attached text/screenshot context"],
        ["summary", "String?", "AI-generated summary (future use)"],
        ["notificationScheduled", "Bool", "Whether deadline notifications are set"],
    ]
    t = Table(task_fields, colWidths=[1.6*inch, 1.3*inch, 3.3*inch])
    t.setStyle(TableStyle([
        ("BACKGROUND", (0, 0), (-1, 0), PURPLE),
        ("TEXTCOLOR", (0, 0), (-1, 0), white),
        ("FONTNAME", (0, 0), (-1, 0), "Helvetica-Bold"),
        ("FONTNAME", (0, 1), (0, -1), "Courier"),
        ("FONTNAME", (1, 1), (1, -1), "Courier"),
        ("FONTSIZE", (0, 0), (-1, -1), 9),
        ("BOTTOMPADDING", (0, 0), (-1, -1), 4),
        ("TOPPADDING", (0, 0), (-1, -1), 4),
        ("LEFTPADDING", (0, 0), (-1, -1), 6),
        ("GRID", (0, 0), (-1, -1), 0.5, HexColor("#D1D5DB")),
        ("ROWBACKGROUNDS", (0, 1), (-1, -1), [white, LIGHT_BG]),
    ]))
    elements.append(t)
    elements.append(Spacer(1, 8))

    elements.append(Paragraph("<b>Computed properties:</b>", body))
    bullet_item("<font name='Courier'>completedSubtasks</font> — Count of done subtasks")
    bullet_item("<font name='Courier'>progress</font> — 0.0 to 1.0 ratio for progress bar")
    bullet_item("<font name='Courier'>isOverdue</font> — true if past due and not done")
    bullet_item("<font name='Courier'>effectiveDueDate</font> — Merges dueDate + dueTime into one Date")
    elements.append(Spacer(1, 8))

    elements.append(Paragraph("<b>TaskStatus enum:</b> <font name='Courier'>.todo</font> (circle icon) → "
                              "<font name='Courier'>.inProgress</font> (half-circle) → "
                              "<font name='Courier'>.done</font> (checkmark). Cycles on click.", body))
    elements.append(Spacer(1, 12))

    # SubTask
    file_header("Models/SubTask.swift", "A simple <b>checkable subtask</b> nested inside OzzieTask.")
    bullet_item("<font name='Courier'>id: UUID</font> — unique identifier")
    bullet_item("<font name='Courier'>title: String</font> — subtask text")
    bullet_item("<font name='Courier'>isCompleted: Bool</font> — checkbox state")
    bullet_item("<font name='Courier'>createdAt: Date</font> — when it was added")
    elements.append(Spacer(1, 12))

    # TaskContext
    file_header("Models/TaskContext.swift", "Represents <b>context attached to a task</b> — either highlighted text or a screenshot with OCR.")
    bullet_item("<font name='Courier'>content: String</font> — the text (or OCR result for screenshots)")
    bullet_item("<font name='Courier'>sourceApp: String</font> — which app the content came from (e.g. 'Safari', 'VS Code')")
    bullet_item("<font name='Courier'>type: ContextType</font> — <font name='Courier'>.text</font> or <font name='Courier'>.screenshot</font>")
    bullet_item("<font name='Courier'>screenshotPath: String?</font> — file path for screenshot images")
    bullet_item("<font name='Courier'>displayIcon</font> — computed SF Symbol: doc.text or camera.viewfinder")

    elements.append(PageBreak())

    # =============================================
    # 5. STORAGE
    # =============================================
    section("5. Storage Layer")

    file_header("Storage/StorageManager.swift",
                "Singleton <b>ObservableObject</b> managing all task persistence. "
                "Stores JSON at <font name='Courier'>~/Library/Application Support/Ozzie/tasks.json</font>.")
    elements.append(Spacer(1, 8))

    elements.append(Paragraph("<b>Storage paths:</b>", body))
    bullet_item("<font name='Courier'>~/Library/Application Support/Ozzie/tasks.json</font> — all task data")
    bullet_item("<font name='Courier'>~/Library/Application Support/Ozzie/screenshots/</font> — captured images (PNG)")
    elements.append(Spacer(1, 6))

    elements.append(Paragraph("<b>CRUD methods:</b>", body))
    crud = [
        ["Method", "What it does"],
        ["addTask(_:)", "Appends task, saves, triggers @Published update"],
        ["updateTask(_:)", "Finds by ID, replaces, saves"],
        ["deleteTask(_:)", "Removes by ID, saves"],
        ["addContextToTask(taskId:, context:)", "Appends context to specific task"],
        ["addSubtask(taskId:, subtask:)", "Appends subtask to specific task"],
        ["toggleSubtask(taskId:, subtaskId:)", "Flips isCompleted on subtask"],
        ["saveScreenshot(_:) → String?", "Writes PNG data, returns file path"],
        ["searchTasks(query:)", "Searches titles + context content"],
    ]
    t = Table(crud, colWidths=[2.8*inch, 3.4*inch])
    t.setStyle(TableStyle([
        ("BACKGROUND", (0, 0), (-1, 0), PURPLE),
        ("TEXTCOLOR", (0, 0), (-1, 0), white),
        ("FONTNAME", (0, 0), (-1, 0), "Helvetica-Bold"),
        ("FONTNAME", (0, 1), (0, -1), "Courier"),
        ("FONTSIZE", (0, 0), (-1, -1), 9),
        ("BOTTOMPADDING", (0, 0), (-1, -1), 4),
        ("TOPPADDING", (0, 0), (-1, -1), 4),
        ("LEFTPADDING", (0, 0), (-1, -1), 6),
        ("GRID", (0, 0), (-1, -1), 0.5, HexColor("#D1D5DB")),
        ("ROWBACKGROUNDS", (0, 1), (-1, -1), [white, LIGHT_BG]),
    ]))
    elements.append(t)
    elements.append(Spacer(1, 8))

    elements.append(Paragraph("<b>Query properties:</b>", body))
    bullet_item("<font name='Courier'>activeTasks</font> — sorted by creation date, excludes .done")
    bullet_item("<font name='Courier'>completedTasks</font> — only .done tasks")
    elements.append(Spacer(1, 6))
    elements.append(Paragraph(
        "<b>How it works:</b> Every mutation calls <font name='Courier'>saveTasks()</font> which "
        "JSON-encodes the entire tasks array to disk. The <font name='Courier'>@Published var tasks</font> "
        "property triggers SwiftUI view updates automatically via EnvironmentObject.",
        body
    ))

    elements.append(PageBreak())

    # =============================================
    # 6. VIEWS
    # =============================================
    section("6. Views (UI Layer)")

    elements.append(Paragraph(
        "All views receive <font name='Courier'>StorageManager</font> as an "
        "<font name='Courier'>@EnvironmentObject</font>. The popover content starts as "
        "TaskListView and can temporarily swap to TaskPickerView during hotkey flows.",
        body
    ))
    elements.append(Spacer(1, 8))

    # TaskListView
    file_header("Views/TaskListView.swift", "The <b>main popover content</b>. Shows a searchable list of active tasks.")
    elements.append(Paragraph("<b>Layout (top to bottom):</b>", body))
    bullet_item("<b>Header bar</b> — Wizard icon + 'Ozzie' title + New Task button (+)")
    bullet_item("<b>Search bar</b> — Filters tasks by title (magnifying glass icon)")
    bullet_item("<b>Task list</b> — ScrollView of TaskRowView items")
    bullet_item("<b>Completed section</b> — Collapsible, shows done tasks with delete option")
    bullet_item("<b>Empty state</b> — Shown when no tasks exist (wizard icon + hint text)")
    elements.append(Spacer(1, 4))
    elements.append(Paragraph("<b>Navigation:</b> Tapping a task row sets <font name='Courier'>selectedTask</font> "
                              "and shows TaskDetailView inline (replaces the list).", body))
    elements.append(Spacer(1, 4))
    elements.append(Paragraph("<b>Context menu:</b> Right-click any task for status change or delete.", body))
    elements.append(Spacer(1, 12))

    # TaskRowView
    file_header("Views/TaskRowView.swift", "A <b>compact row</b> for a single task in the list.")
    bullet_item("<b>Status button</b> (left) — Cycles todo → inProgress → done on click")
    bullet_item("<b>Title</b> — Bold, single line, strikethrough if done")
    bullet_item("<b>Progress indicator</b> — '2/5' subtask count if subtasks exist")
    bullet_item("<b>Context badge</b> — Number of attached contexts")
    bullet_item("<b>Due date</b> — Red if overdue, orange for today, gray otherwise")
    elements.append(Spacer(1, 12))

    # TaskDetailView
    file_header("Views/TaskDetailView.swift", "The <b>expanded task editor</b>. Shown when you click a task.")
    elements.append(Paragraph("<b>Sections:</b>", body))
    bullet_item("<b>Back button</b> — Returns to task list")
    bullet_item("<b>Title section</b> — Tap to edit inline")
    bullet_item("<b>Status pills</b> — Three buttons to set status directly")
    bullet_item("<b>Date section</b> — Toggle due date on/off, date + time pickers")
    bullet_item("<b>Subtasks</b> — Progress bar + list of toggleable subtasks + 'Add subtask' field")
    bullet_item("<b>Context section</b> — Each context shows source app, timestamp, preview (expandable), screenshots inline")
    elements.append(Spacer(1, 4))
    elements.append(Paragraph(
        "<b>Includes nested ContextItemView</b> — handles expand/collapse of context "
        "previews and renders screenshots from disk.",
        body
    ))
    elements.append(Spacer(1, 12))

    # NewTaskView
    file_header("Views/NewTaskView.swift", "Sheet modal for <b>creating a task from scratch</b>.")
    bullet_item("Title text field")
    bullet_item("Optional due date toggle with date + time pickers")
    bullet_item("Inline subtask creation (type + Enter to add, shows list)")
    bullet_item("Calls <font name='Courier'>storageManager.addTask()</font> and schedules notifications")
    elements.append(Spacer(1, 12))

    # TaskPickerView
    file_header("Views/TaskPickerView.swift", "Shown during <b>Cmd+Option+A</b> and <b>Cmd+Option+S</b> flows. "
                "Lets the user pick which task to attach context to.")
    bullet_item("<b>Context preview</b> — shows the captured text/screenshot and source app")
    bullet_item("<b>Search bar</b> — fuzzy search through existing tasks")
    bullet_item("<b>'Create new task'</b> option — creates a task with the context pre-attached")
    bullet_item("<b>Task list</b> — click any task to attach the context to it")
    bullet_item("Posts <font name='Courier'>.resetPopoverContent</font> notification when done (AppDelegate swaps back to TaskListView)")

    elements.append(PageBreak())

    # =============================================
    # 7. SERVICES
    # =============================================
    section("7. Services")

    elements.append(Paragraph("All services are <b>singletons</b> accessed via <font name='Courier'>.shared</font>.", body))
    elements.append(Spacer(1, 8))

    # HotkeyManager
    file_header("Services/HotkeyManager.swift", "Registers <b>global keyboard shortcuts</b> using the Carbon API.")
    elements.append(Paragraph("<b>How it works:</b>", body))
    bullet_item("Installs a Carbon <font name='Courier'>EventHandler</font> for <font name='Courier'>kEventHotKeyPressed</font>")
    bullet_item("Registers three hotkeys with signature 'OZZI' (0x4F5A5A49)")
    bullet_item("Each hotkey fires a callback: <font name='Courier'>onNewTask</font>, <font name='Courier'>onAddContext</font>, <font name='Courier'>onScreenshot</font>")
    bullet_item("AppDelegate sets these callbacks during <font name='Courier'>setupHotkeys()</font>")
    bullet_item("Requires <b>Accessibility permission</b> in System Settings")
    elements.append(Spacer(1, 12))

    # ScreenCaptureService
    file_header("Services/ScreenCaptureService.swift", "Handles <b>interactive screenshot capture</b> and <b>OCR text recognition</b>.")
    elements.append(Paragraph("<b>Flow:</b>", body))
    bullet_item("<font name='Courier'>captureSelection()</font> runs <font name='Courier'>/usr/sbin/screencapture -i</font> (interactive selection)")
    bullet_item("Saves to a temp file, reads the image data")
    bullet_item("<font name='Courier'>performOCR()</font> uses Vision framework's <font name='Courier'>VNRecognizeTextRequest</font>")
    bullet_item("Uses <font name='Courier'>.accurate</font> recognition level with language correction enabled")
    bullet_item("Returns both the raw image data and extracted text to the callback")
    bullet_item("Requires <b>Screen Recording permission</b> in System Settings")
    elements.append(Spacer(1, 12))

    # NotificationManager
    file_header("Services/NotificationManager.swift", "Schedules <b>deadline reminders</b> and a <b>daily morning brief</b>.")
    elements.append(Paragraph("<b>Notification types:</b>", body))

    notif_data = [
        ["Type", "When", "Content"],
        ["1-hour warning", "60 min before due", "'Task X is due in 1 hour'"],
        ["15-min warning", "15 min before due", "'Task X is due in 15 minutes!'"],
        ["At due time", "Exact due time", "'Task X is due now!'"],
        ["Daily brief", "9:00 AM daily", "'You have N active, M due today, K overdue'"],
    ]
    t = Table(notif_data, colWidths=[1.5*inch, 1.5*inch, 3.2*inch])
    t.setStyle(TableStyle([
        ("BACKGROUND", (0, 0), (-1, 0), PURPLE),
        ("TEXTCOLOR", (0, 0), (-1, 0), white),
        ("FONTNAME", (0, 0), (-1, 0), "Helvetica-Bold"),
        ("FONTSIZE", (0, 0), (-1, -1), 9),
        ("BOTTOMPADDING", (0, 0), (-1, -1), 4),
        ("TOPPADDING", (0, 0), (-1, -1), 4),
        ("LEFTPADDING", (0, 0), (-1, -1), 6),
        ("GRID", (0, 0), (-1, -1), 0.5, HexColor("#D1D5DB")),
        ("ROWBACKGROUNDS", (0, 1), (-1, -1), [white, LIGHT_BG]),
    ]))
    elements.append(t)
    elements.append(Spacer(1, 6))
    bullet_item("Uses <font name='Courier'>UNUserNotificationCenter</font> with calendar-based triggers")
    bullet_item("Notification IDs are <font name='Courier'>ozzie-{taskId}-{1h/15m/due}</font> for easy removal")
    elements.append(Spacer(1, 12))

    # ActiveAppService
    file_header("Services/ActiveAppService.swift", "Detects the <b>frontmost application</b> and <b>grabs selected text</b>.")
    bullet_item("<font name='Courier'>frontmostAppName()</font> — returns the active app's localized name via <font name='Courier'>NSWorkspace</font>")
    bullet_item("<font name='Courier'>getSelectedText()</font> — simulates Cmd+C via <font name='Courier'>CGEvent</font>, reads from <font name='Courier'>NSPasteboard</font>, then restores the previous clipboard content")
    bullet_item("Used by AppDelegate in all three hotkey handlers to capture source context")
    bullet_item("Requires <b>Accessibility permission</b> for CGEvent posting")

    elements.append(PageBreak())

    # =============================================
    # 8. RESOURCES & CONFIG
    # =============================================
    section("8. Resources &amp; Configuration")

    file_header("Resources/WizardIcon.swift", "Generates the <b>8-bit pixel art wizard</b> icon programmatically.")
    bullet_item("<font name='Courier'>pixelMap</font> — 18×18 grid of UInt8 values defining the wizard shape")
    bullet_item("<font name='Courier'>createMenuBarIcon()</font> — Black template image (macOS auto-tints for light/dark)")
    bullet_item("<font name='Courier'>createLargeIcon(size:)</font> — Colored version: purple hat, tan face, dark blue robe, brown staff")
    bullet_item("Template images ensure the icon matches the system menu bar style automatically")
    elements.append(Spacer(1, 12))

    file_header("project.yml", "XcodeGen project definition.")
    bullet_item("Target: macOS application, deployment target 14.0")
    bullet_item("Swift 5.9, automatic code signing")
    bullet_item("References Info.plist and Ozzie.entitlements")
    bullet_item("Run <font name='Courier'>xcodegen generate</font> to create the .xcodeproj")

    elements.append(PageBreak())

    # =============================================
    # 9. DATA FLOW
    # =============================================
    section("9. Data Flow Diagrams")

    elements.append(Paragraph("<b>A. New Task from Highlighted Text (Cmd+Option+N)</b>", h3))
    flow_a = [
        "1. User highlights text in any app",
        "2. Presses Cmd+Option+N",
        "3. Carbon event handler fires → HotkeyManager.onNewTask callback",
        "4. AppDelegate.handleNewTask() runs:",
        "   a. ActiveAppService.frontmostAppName() → gets source app",
        "   b. ActiveAppService.getSelectedText() → simulates Cmd+C → reads clipboard",
        "   c. Creates OzzieTask with title (first line of text)",
        "   d. Creates TaskContext with full text + source app name",
        "   e. StorageManager.addTask() → saves to JSON → @Published triggers UI update",
        "   f. Shows popover with updated TaskListView",
    ]
    for line in flow_a:
        elements.append(Paragraph(line, code))
    elements.append(Spacer(1, 12))

    elements.append(Paragraph("<b>B. Add Context to Existing Task (Cmd+Option+A)</b>", h3))
    flow_b = [
        "1. User highlights text in any app",
        "2. Presses Cmd+Option+A",
        "3. HotkeyManager.onAddContext → AppDelegate.handleAddContext()",
        "4. Gets selected text + source app",
        "5. Swaps popover content to TaskPickerView (with context text pre-loaded)",
        "6. User searches/selects a task (or creates new)",
        "7. TaskContext created and attached → StorageManager.addContextToTask()",
        "8. TaskPickerView posts .resetPopoverContent → AppDelegate swaps back to TaskListView",
    ]
    for line in flow_b:
        elements.append(Paragraph(line, code))
    elements.append(Spacer(1, 12))

    elements.append(Paragraph("<b>C. Screenshot Capture (Cmd+Option+S)</b>", h3))
    flow_c = [
        "1. User presses Cmd+Option+S",
        "2. HotkeyManager.onScreenshot → AppDelegate.handleScreenshot()",
        "3. 0.3s delay (lets UI settle)",
        "4. ScreenCaptureService.captureSelection() → runs /usr/sbin/screencapture -i",
        "5. User drags to select screen region",
        "6. Image saved to temp file → read as Data",
        "7. Vision framework OCR extracts text from image",
        "8. StorageManager.saveScreenshot() → saves PNG to screenshots/ dir",
        "9. TaskPickerView shown with screenshot preview + OCR text",
        "10. User picks task → TaskContext (type: .screenshot) attached",
    ]
    for line in flow_c:
        elements.append(Paragraph(line, code))

    elements.append(PageBreak())

    elements.append(Paragraph("<b>D. Notification Flow</b>", h3))
    flow_d = [
        "1. User sets due date on task (via NewTaskView or TaskDetailView)",
        "2. View calls OzzieNotificationManager.scheduleDeadlineNotifications(for: task)",
        "3. Three UNNotificationRequests created:",
        "   - ozzie-{id}-1h  → fires 60min before due",
        "   - ozzie-{id}-15m → fires 15min before due",
        "   - ozzie-{id}-due → fires at due time",
        "4. On app launch, scheduleDailyBrief() sets recurring 9AM notification",
        "5. When task deleted, removeNotifications(for:) cleans up pending requests",
    ]
    for line in flow_d:
        elements.append(Paragraph(line, code))

    elements.append(PageBreak())

    # =============================================
    # 10. PERMISSIONS
    # =============================================
    section("10. Permissions &amp; Entitlements")

    perm_data = [
        ["Permission", "Why Needed", "Where Configured"],
        ["Accessibility", "Global hotkeys + CGEvent for clipboard", "System Settings > Privacy"],
        ["Screen Recording", "screencapture -i for screenshots", "System Settings > Privacy"],
        ["Notifications", "Deadline reminders + daily brief", "Prompted on first launch"],
        ["App Sandbox: OFF", "Clipboard, automation, file access", "Ozzie.entitlements"],
        ["Automation (AppleEvents)", "Detect frontmost app name", "Ozzie.entitlements + Info.plist"],
        ["File Access (user-selected)", "Read/write screenshots + JSON", "Ozzie.entitlements"],
    ]
    t = Table(perm_data, colWidths=[1.6*inch, 2.4*inch, 2.2*inch])
    t.setStyle(TableStyle([
        ("BACKGROUND", (0, 0), (-1, 0), PURPLE),
        ("TEXTCOLOR", (0, 0), (-1, 0), white),
        ("FONTNAME", (0, 0), (-1, 0), "Helvetica-Bold"),
        ("FONTSIZE", (0, 0), (-1, -1), 9),
        ("BOTTOMPADDING", (0, 0), (-1, -1), 5),
        ("TOPPADDING", (0, 0), (-1, -1), 5),
        ("LEFTPADDING", (0, 0), (-1, -1), 6),
        ("GRID", (0, 0), (-1, -1), 0.5, HexColor("#D1D5DB")),
        ("ROWBACKGROUNDS", (0, 1), (-1, -1), [white, LIGHT_BG]),
    ]))
    elements.append(t)

    elements.append(Spacer(1, 16))

    # =============================================
    # 11. HOTKEY REFERENCE
    # =============================================
    section("11. Hotkey Reference")

    hotkey_data = [
        ["Shortcut", "Action", "Handler", "What Happens"],
        ["Cmd+Option+N", "New Task", "handleNewTask()", "Captures text → creates task → opens popover"],
        ["Cmd+Option+A", "Add Context", "handleAddContext()", "Captures text → opens task picker"],
        ["Cmd+Option+S", "Screenshot", "handleScreenshot()", "Region select → OCR → opens task picker"],
    ]
    t = Table(hotkey_data, colWidths=[1.3*inch, 1.1*inch, 1.5*inch, 2.3*inch])
    t.setStyle(TableStyle([
        ("BACKGROUND", (0, 0), (-1, 0), PURPLE),
        ("TEXTCOLOR", (0, 0), (-1, 0), white),
        ("FONTNAME", (0, 0), (-1, 0), "Helvetica-Bold"),
        ("FONTNAME", (0, 1), (0, -1), "Courier"),
        ("FONTNAME", (2, 1), (2, -1), "Courier"),
        ("FONTSIZE", (0, 0), (-1, -1), 9),
        ("BOTTOMPADDING", (0, 0), (-1, -1), 5),
        ("TOPPADDING", (0, 0), (-1, -1), 5),
        ("LEFTPADDING", (0, 0), (-1, -1), 6),
        ("GRID", (0, 0), (-1, -1), 0.5, HexColor("#D1D5DB")),
        ("ROWBACKGROUNDS", (0, 1), (-1, -1), [white, LIGHT_BG]),
    ]))
    elements.append(t)

    elements.append(Spacer(1, 24))
    elements.append(Paragraph(
        "<b>Carbon key codes used:</b> "
        "kVK_ANSI_N (0x2D), kVK_ANSI_A (0x00), kVK_ANSI_S (0x01). "
        "Modifiers: cmdKey | optionKey.",
        small
    ))

    elements.append(Spacer(1, 40))
    hr()
    elements.append(Paragraph(
        "<i>Ozzie the Wizard — Project Anatomy v1.0 — Generated for development reference</i>",
        ParagraphStyle("Footer", parent=small, alignment=TA_CENTER)
    ))

    # Build
    doc.build(elements)
    print("PDF generated: /home/user/ozzie/Ozzie_Project_Anatomy.pdf")

if __name__ == "__main__":
    build_pdf()
