import SwiftUI

struct FocusLockView: View {
    @ObservedObject var model: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                PageHeader(
                    eyebrow: "Shield",
                    title: "Deep Work Lock",
                    subtitle: "A stricter gate for coding sessions, build waits, and agent waits."
                )

                SurfaceCard(minHeight: 230) {
                    VStack(alignment: .leading, spacing: 18) {
                        HStack(alignment: .center, spacing: 14) {
                            IconRoundel(
                                systemImage: model.focusLockActive ? "lock.shield.fill" : "lock.open",
                                tint: model.focusLockActive ? .orange : .secondary
                            )

                            VStack(alignment: .leading, spacing: 3) {
                                Text(model.focusLockActive ? "Lock is active" : "Ready when you are")
                                    .font(.title2.weight(.semibold))
                                Text(model.focusLockActive ? "\(model.focusLockRemaining.shortDurationString) remaining" : "Watched feeds will get a stricter gate.")
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                        }

                        HStack(spacing: 12) {
                            MetricTile(
                                title: "Threshold",
                                value: model.demoMode ? "4s" : "10s",
                                caption: "During active lock",
                                systemImage: "bolt",
                                tint: .orange
                            )
                            MetricTile(
                                title: "Mode",
                                value: model.demoMode ? "Demo" : "Normal",
                                caption: "Presentation pacing",
                                systemImage: "switch.2",
                                tint: .blue
                            )
                        }
                    }
                }

                HStack(spacing: 10) {
                    Button {
                        model.startFocusLock(minutes: model.demoMode ? 1 : 25)
                    } label: {
                        Label(model.demoMode ? "1 min" : "25 min", systemImage: "lock.fill")
                    }
                    .buttonStyle(.borderedProminent)

                    Button {
                        model.startFocusLock(minutes: 45)
                    } label: {
                        Label("45 min", systemImage: "clock")
                    }

                    Button {
                        model.startFocusLock(minutes: 90)
                    } label: {
                        Label("90 min", systemImage: "moon")
                    }

                    Spacer()

                    Button(role: .destructive) {
                        model.stopFocusLock()
                    } label: {
                        Label("Stop", systemImage: "lock.open")
                    }
                    .disabled(!model.focusLockActive)
                }

                Text("MVP: StillPoint proves the intervention loop. System-level anti-bypass belongs to the later Android / permissions pass.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
            .padding(30)
        }
    }
}
