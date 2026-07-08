import AppKit
import SwiftUI

@main
struct StillPointApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var model = AppModel()

    var body: some Scene {
        WindowGroup("StillPoint", id: "control") {
            ControlCenterScene(model: model)
                .frame(width: 1120, height: 700)
        }
        .defaultSize(width: 1120, height: 700)

        Settings {
            SettingsView(model: model)
                .frame(width: 460)
                .padding()
        }
    }
}

private struct ControlCenterScene: View {
    @ObservedObject var model: AppModel
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        ContentView(model: model)
            .onAppear {
                StatusItemController.shared.install(model: model)
                StatusItemController.shared.setOpenControlCenterAction {
                    openWindow(id: "control")
                    NSApp.activate(ignoringOtherApps: true)
                }
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
