import AppKit
import SwiftUI

struct MenuBarView: View {
    @ObservedObject var model: AppModel

    var body: some View {
        Button("Open StillPoint") {
            NSApp.activate(ignoringOtherApps: true)
        }
        Divider()
        Button(model.monitoringEnabled ? "Pause watching" : "Resume watching") {
            model.monitoringEnabled.toggle()
        }
        Button("Simulate drift") {
            model.simulateDouyinDrift()
        }
        Button(model.demoMode ? "Demo mode on" : "Demo mode off") {
            model.demoMode.toggle()
        }
        Divider()
        Button(model.focusLockActive ? "Stop work lock" : "Start work lock") {
            if model.focusLockActive {
                model.stopFocusLock()
            } else {
                model.startFocusLock(minutes: model.demoMode ? 1 : 25)
            }
        }
    }
}

