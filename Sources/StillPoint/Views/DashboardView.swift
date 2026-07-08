import SwiftUI

struct DashboardView: View {
    @ObservedObject var model: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                WorkspaceHeader(
                    eyebrow: "Live monitor",
                    title: "Attention Control Center",
                    subtitle: "A menu bar guardian that waits quietly until a feed starts pulling."
                ) {
                    StatusCluster(model: model)
                }

                IntentCheckpointPanel(model: model)

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 170), spacing: 12)], spacing: 12) {
                    SummaryTile(
                        title: "Checks",
                        value: "\(model.dailySummary.driftChecks)",
                        caption: "Intent moments today",
                        systemImage: "figure.mind.and.body",
                        tint: .cyan
                    )
                    SummaryTile(
                        title: "Protected",
                        value: model.dailySummary.protectedSeconds.shortDurationString,
                        caption: "Estimated time returned",
                        systemImage: "shield",
                        tint: .green
                    )
                    SummaryTile(
                        title: "Targets",
                        value: "\(model.enabledWatchCount)",
                        caption: "Explicitly watched apps",
                        systemImage: "eye",
                        tint: .orange
                    )
                }

                RecentActivityPanel(model: model)
            }
            .frame(maxWidth: 860, alignment: .leading)
            .padding(.horizontal, 32)
            .padding(.vertical, 28)
        }
    }
}

private struct StatusCluster: View {
    @ObservedObject var model: AppModel

    var body: some View {
        HStack(spacing: 8) {
            StatusPill(
                text: model.watchStateLabel,
                systemImage: model.monitoringEnabled ? "eye" : "eye.slash",
                tint: model.monitoringEnabled ? .green : .secondary
            )
            StatusPill(
                text: model.modeLabel,
                systemImage: model.focusLockActive ? "lock.shield" : "bolt",
                tint: model.focusLockActive ? .orange : .cyan
            )
        }
    }
}

private struct IntentCheckpointPanel: View {
    @ObservedObject var model: AppModel

    var body: some View {
        PlainPanel(minHeight: 214) {
            VStack(alignment: .leading, spacing: 18) {
                HStack(alignment: .top, spacing: 14) {
                    IconRoundel(systemImage: model.focusLockActive ? "lock.shield.fill" : "scope", tint: model.focusLockActive ? .orange : .cyan)
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Current gate")
                            .font(.headline)
                        Text("StillPoint watches the frontmost app, then asks for intent before a feed becomes autopilot.")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer()
                }

                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .firstTextBaseline) {
                        Text(model.activeAppName)
                            .font(.system(size: 34, weight: .semibold, design: .rounded))
                            .lineLimit(1)
                            .minimumScaleFactor(0.62)
                        Spacer()
                        Text("\(model.activeElapsed.shortDurationString) / \(model.visibleTriggerThreshold.shortDurationString)")
                            .font(.callout.monospacedDigit().weight(.semibold))
                            .foregroundStyle(.secondary)
                    }

                    ProgressLine(value: model.activeProgress, tint: model.focusLockActive ? .orange : .cyan, marker: 0.86)
                }

                Text(model.activeBundleIdentifier.isEmpty ? model.statusMessage : model.activeBundleIdentifier)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)

                HStack(spacing: 10) {
                    Button {
                        model.simulateDouyinDrift()
                    } label: {
                        Label("Simulate drift", systemImage: "play.fill")
                    }
                    .buttonStyle(.borderedProminent)

                    Button {
                        model.startFocusLock(minutes: 25)
                    } label: {
                        Label(model.focusLockActive ? "Extend lock" : "Start work lock", systemImage: "lock.shield")
                    }

                    Spacer()
                }
            }
        }
    }
}

private struct RecentActivityPanel: View {
    @ObservedObject var model: AppModel

    var body: some View {
        let recent = Array(model.todayEvents.suffix(4).reversed())

        PlainPanel {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    SectionKicker("Today", systemImage: "text.page")
                    Spacer()
                    Text(model.todayEvents.isEmpty ? "No receipt yet" : "\(model.todayEvents.count) events")
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(.secondary)
                }

                if model.todayEvents.isEmpty {
                    Text("Run the demo once or keep a watched feed open long enough to create the first checkpoint.")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                } else {
                    VStack(spacing: 0) {
                        ForEach(recent) { event in
                            DataRow(event.action.rawValue, value: event.date.shortTimeString, caption: event.appName)
                            if event.id != recent.last?.id {
                                HairlineDivider()
                            }
                        }
                    }
                }
            }
        }
    }
}
