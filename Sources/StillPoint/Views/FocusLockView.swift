import SwiftUI

struct FocusLockView: View {
    @ObservedObject var model: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                WorkspaceHeader(
                    eyebrow: "Shield",
                    title: "Deep Work Lock",
                    subtitle: "A stricter gate for coding sessions, build waits, and agent waits."
                )

                PlainPanel(minHeight: 232) {
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

                        ProgressLine(
                            value: model.focusLockActive ? 1 - (model.focusLockRemaining / TimeInterval(model.demoMode ? 60 : 25 * 60)) : 0,
                            tint: .orange,
                            marker: nil
                        )

                        VStack(spacing: 0) {
                            DataRow("Strict gate", value: model.demoMode ? "4s" : "10s", caption: "Threshold during active lock")
                            HairlineDivider()
                            DataRow("Mode", value: model.demoMode ? "Demo" : "Normal", caption: "Presentation pacing")
                            HairlineDivider()
                            DataRow("Watched targets", value: "\(model.enabledWatchCount)", caption: "Apps covered by the shield")
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
            .frame(maxWidth: 860, alignment: .leading)
            .padding(.horizontal, 32)
            .padding(.vertical, 28)
        }
    }
}
