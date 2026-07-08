import SwiftUI

struct DashboardView: View {
    @ObservedObject var model: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                WorkspaceHeader(
                    eyebrow: model.t("Live monitor", "实时监控"),
                    title: model.t("Attention Control Center", "注意力控制中心"),
                    subtitle: model.t(
                        "A menu bar guardian that waits quietly until a feed starts pulling.",
                        "一个安静待在菜单栏里的守门人，只在信息流开始拉走你时出现。"
                    )
                ) {
                    StatusCluster(model: model)
                }

                IntentCheckpointPanel(model: model)

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 170), spacing: 12)], spacing: 12) {
                    SummaryTile(
                        title: model.t("Checks", "检查"),
                        value: "\(model.dailySummary.driftChecks)",
                        caption: model.t("Intent moments today", "今天的意图检查"),
                        systemImage: "figure.mind.and.body",
                        tint: .cyan
                    )
                    SummaryTile(
                        title: model.t("Protected", "保护"),
                        value: model.dailySummary.protectedSeconds.shortDurationString,
                        caption: model.t("Estimated time returned", "估算找回时间"),
                        systemImage: "shield",
                        tint: .green
                    )
                    SummaryTile(
                        title: model.t("Targets", "目标"),
                        value: "\(model.enabledWatchCount)",
                        caption: model.t("Explicitly watched apps", "明确监控的应用"),
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
                        Text(model.t("Current gate", "当前阈值"))
                            .font(.headline)
                        Text(model.t(
                            "StillPoint watches the frontmost app, then asks for intent before a feed becomes autopilot.",
                            "StillPoint 会观察最前台应用，并在信息流进入自动驾驶前询问你的意图。"
                        ))
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
                        Label(model.t("Simulate drift", "模拟走神"), systemImage: "play.fill")
                    }
                    .buttonStyle(.borderedProminent)

                    Button {
                        model.startFocusLock(minutes: 25)
                    } label: {
                        Label(model.focusLockActive ? model.t("Extend lock", "延长锁定") : model.t("Start work lock", "开启专注锁"), systemImage: "lock.shield")
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
                    SectionKicker(model.t("Today", "今天"), systemImage: "text.page")
                    Spacer()
                    Text(model.todayEvents.isEmpty ? model.t("No receipt yet", "还没有小票") : model.t("\(model.todayEvents.count) events", "\(model.todayEvents.count) 条记录"))
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(.secondary)
                }

                if model.todayEvents.isEmpty {
                    Text(model.t(
                        "Simulate once or keep a watched feed open long enough to create the first checkpoint.",
                        "模拟一次，或让被监控的信息流停留足够久，以生成第一次检查。"
                    ))
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                } else {
                    VStack(spacing: 0) {
                        ForEach(recent) { event in
                            DataRow(event.action.title(language: model.language), value: event.date.shortTimeString, caption: event.appName)
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
