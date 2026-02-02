import SwiftUI

@main
struct OzzieApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // No windows — Ozzie lives in the menu bar only
        Settings {
            EmptyView()
        }
    }
}
