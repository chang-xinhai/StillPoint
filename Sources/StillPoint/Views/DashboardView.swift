import SwiftUI

struct DashboardView: View {
    @ObservedObject var model: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                PageHeader(
                    eyebrow: "StillPoint",
                    title: "A quiet checkpoint for attention.",
                    subtitle: "Watch explicit targets, allow purposeful use, and step in when a feed starts pulling."
                )

                HStack(alignment: .top, spacing: 16) {
                    LiveStatusPanel(model: model)
                        .frame(minWidth: 420)

                    QuickActionsPanel(model: model)
                        .frame(width: 280)
                }

                HStack(spacing: 12) {
                    let summary = model.dailySummary

                    MetricTile(
                        title: "Drift checks",
                        value: "\(summary.driftChecks)",
                        caption: "Intent checks today",
                        systemImage: "figure.mind.and.body",
                        tint: .blue
                    )
                    MetricTile(
                        title: "Protected",
                        value: summary.protectedSeconds.shortDurationString,
                        caption: "Estimated time returned",
                        systemImage: "shield",
                        tint: .green
                    )
                    MetricTile(
                        title: "Targets",
                        value: "\(model.enabledWatchCount)",
                        caption: "Explicitly watched",
                        systemImage: "eye",
                        tint: .orange
                    )
                }
            }
            .padding(30)
        }
    }
}

private struct LiveStatusPanel: View {
    @ObservedObject var model: AppModel

    var body: some View {
        SurfaceCard(minHeight: 244) {
            VStack(alignment: .leading, spacing: 18) {
                HStack {
                    StatusPill(
                        text: model.watchStateLabel,
                        systemImage: model.monitoringEnabled ? "eye" : "eye.slash",
                        tint: model.monitoringEnabled ? .green : .secondary
                    )
                    StatusPill(
                        text: model.modeLabel,
                        systemImage: model.focusLockActive ? "lock.shield" : "bolt",
                        tint: model.focusLockActive ? .orange : .blue
                    )
                    Spacer()
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text(model.activeAppName)
                        .font(.system(size: 34, weight: .semibold, design: .rounded))
                        .lineLimit(1)
                        .minimumScaleFactor(0.58)

                    Text(model.activeBundleIdentifier.isEmpty ? "Waiting for a watched target" : model.activeBundleIdentifier)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(model.activeElapsed.shortDurationString)
                            .font(.title3.weight(.semibold))
                        Text("of \(model.visibleTriggerThreshold.shortDurationString)")
                            .foregroundStyle(.secondary)
                        Spacer()
                    }

                    ProgressView(value: model.activeProgress)
                        .controlSize(.small)
                        .tint(model.focusLockActive ? .orange : .accentColor)
                }

                QuietDivider()

                Text(model.statusMessage)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

private struct QuickActionsPanel: View {
    @ObservedObject var model: AppModel

    var body: some View {
        SurfaceCard(minHeight: 244) {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 10) {
                    IconRoundel(systemImage: "pause.circle", tint: .blue)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Demo flow")
                            .font(.headline)
                        Text("One-minute proof loop")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                PrimaryActionButton(title: "Simulate drift", systemImage: "play.fill") {
                    model.simulateDouyinDrift()
                }

                QuietActionButton(title: model.focusLockActive ? "Extend work lock" : "Start work lock", systemImage: "lock.shield", tint: .primary) {
                    model.startFocusLock(minutes: model.demoMode ? 1 : 25)
                }

                Spacer(minLength: 0)

                Text(model.demoMode ? "Demo thresholds are short." : "Normal thresholds are active.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
