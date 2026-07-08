import AppKit
import SwiftUI

@main
struct StillPointApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var model = AppModel()

    var body: some Scene {
        WindowGroup("StillPoint", id: "control") {
            ContentView(model: model)
                .frame(width: 1120, height: 700)
        }
        .defaultSize(width: 1120, height: 700)

        MenuBarExtra {
            MenuBarView(model: model)
        } label: {
            Label(model.barTitle, systemImage: model.barSystemImage)
                .symbolRenderingMode(.hierarchical)
        }
        .menuBarExtraStyle(.window)

        Settings {
            SettingsView(model: model)
                .frame(width: 460)
                .padding()
        }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            NSApp.activate(ignoringOtherApps: true)
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }
}
