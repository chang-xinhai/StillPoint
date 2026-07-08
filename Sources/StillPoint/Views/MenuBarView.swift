import AppKit
import SwiftUI

struct MenuBarView: View {
    @ObservedObject var model: AppModel
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            header
            activeStatus
            todayStrip
            actionGrid
            footer
        }
        .padding(16)
        .frame(width: 360)
        .background(.regularMaterial)
    }

    private var header: some View {
        HStack(spacing: 12) {
            IconRoundel(systemImage: model.barSystemImage, tint: model.focusLockActive ? .orange : .blue)

            VStack(alignment: .leading, spacing: 2) {
                Text("StillPoint")
                    .font(.headline)
                Text("Protect the pause before the feed")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            StatusPill(
                text: model.watchStateLabel,
                systemImage: model.monitoringEnabled ? "eye" : "eye.slash",
                tint: model.monitoringEnabled ? .green : .secondary
            )
        }
    }

    private var activeStatus: some View {
        SurfaceCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(model.activeAppName)
                            .font(.system(size: 22, weight: .semibold, design: .rounded))
                            .lineLimit(1)
                        Text(model.activeBundleIdentifier.isEmpty ? model.statusMessage : model.activeBundleIdentifier)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                    Spacer()
                    Text(model.activeElapsed.shortDurationString)
                        .font(.caption.monospacedDigit().weight(.semibold))
                        .foregroundStyle(.secondary)
                }

                ProgressView(value: model.activeProgress)
                    .controlSize(.small)
                    .tint(model.focusLockActive ? .orange : .blue)

                HStack {
                    StatusPill(
                        text: model.modeLabel,
                        systemImage: model.focusLockActive ? "lock.shield" : "bolt",
                        tint: model.focusLockActive ? .orange : .blue
                    )
                    Spacer()
                    Text("Gate at \(model.visibleTriggerThreshold.shortDurationString)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private var todayStrip: some View {
        let summary = model.dailySummary

        return HStack(spacing: 8) {
            MenuMetric(title: "Checks", value: "\(summary.driftChecks)", tint: .blue)
            MenuMetric(title: "Closed", value: "\(summary.closedDrifts)", tint: .red)
            MenuMetric(title: "Saved", value: summary.protectedSeconds.shortDurationString, tint: .green)
        }
    }

    private var actionGrid: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                PrimaryActionButton(title: "Simulate", systemImage: "play.fill") {
                    model.simulateDouyinDrift()
                }

                QuietActionButton(
                    title: model.focusLockActive ? "Stop Lock" : "Work Lock",
                    systemImage: model.focusLockActive ? "lock.open" : "lock.shield",
                    tint: model.focusLockActive ? .red : .primary
                ) {
                    if model.focusLockActive {
                        model.stopFocusLock()
                    } else {
                        model.startFocusLock(minutes: model.demoMode ? 1 : 25)
                    }
                }
            }

            HStack(spacing: 8) {
                QuietActionButton(
                    title: model.monitoringEnabled ? "Pause" : "Resume",
                    systemImage: model.monitoringEnabled ? "pause.fill" : "play.fill",
                    tint: .primary
                ) {
                    model.monitoringEnabled.toggle()
                }

                QuietActionButton(title: "Control", systemImage: "slider.horizontal.3", tint: .primary) {
                    openWindow(id: "control")
                    NSApp.activate(ignoringOtherApps: true)
                }
            }
        }
    }

    private var footer: some View {
        HStack {
            Toggle("Demo Mode", isOn: $model.demoMode)
                .toggleStyle(.switch)
                .font(.caption)

            Spacer()

            Button("Quit") {
                NSApp.terminate(nil)
            }
            .font(.caption)
        }
    }
}

private struct MenuMetric: View {
    var title: String
    var value: String
    var tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.secondary)
            Text(value)
                .font(.callout.monospacedDigit().weight(.semibold))
                .foregroundStyle(tint)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(tint.opacity(0.09), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .strokeBorder(tint.opacity(0.12), lineWidth: 1)
        }
    }
}

