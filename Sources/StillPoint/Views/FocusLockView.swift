import SwiftUI

struct FocusLockView: View {
    @ObservedObject var model: AppModel

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Deep Work Lock")
                    .font(.largeTitle.weight(.semibold))
                Text("For coding sessions, build waits, and agent waits. Watched apps get a much shorter grace window.")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 16) {
                MetricTile(
                    title: "Lock status",
                    value: model.focusLockActive ? "Active" : "Off",
                    caption: model.focusLockActive ? "\(model.focusLockRemaining.shortDurationString) remaining" : "No lock is running",
                    systemImage: "lock.shield"
                )
                MetricTile(
                    title: "Demo threshold",
                    value: model.demoMode ? "4s" : "10s",
                    caption: "Watched apps trigger faster during lock.",
                    systemImage: "bolt"
                )
            }

            HStack {
                Button {
                    model.startFocusLock(minutes: model.demoMode ? 1 : 25)
                } label: {
                    Label(model.demoMode ? "Lock for 1 min" : "Lock for 25 min", systemImage: "lock.fill")
                }
                .buttonStyle(.borderedProminent)

                Button {
                    model.startFocusLock(minutes: 45)
                } label: {
                    Label("45 min", systemImage: "clock")
                }

                Button {
                    model.stopFocusLock()
                } label: {
                    Label("Stop lock", systemImage: "lock.open")
                }
                .disabled(!model.focusLockActive)
            }

            Text("MVP note: this prototype does not promise system-level anti-bypass. It proves the loop: detect, cover the screen, force a deliberate choice, then record the outcome.")
                .foregroundStyle(.secondary)

            Spacer()
        }
        .padding(28)
    }
}

