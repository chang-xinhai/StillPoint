import AppKit
import SwiftUI

@main
struct StillPointApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var model = AppModel()

    var body: some Scene {
        WindowGroup("StillPoint", id: "main") {
            ContentView(model: model)
                .frame(minWidth: 980, minHeight: 660)
                .onAppear {
                    model.startMonitoring()
                }
        }

        MenuBarExtra("StillPoint", systemImage: "pause.circle") {
            MenuBarView(model: model)
        }

        Settings {
            SettingsView(model: model)
                .frame(width: 460)
                .padding()
        }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        DispatchQueue.main.async {
            NSApp.activate(ignoringOtherApps: true)
        }
    }
}

