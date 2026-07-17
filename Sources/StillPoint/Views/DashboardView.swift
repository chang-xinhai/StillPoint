import SwiftUI

struct DashboardView: View {
    @ObservedObject var model: AppModel
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                WorkspaceHeader(
                    eyebrow: model.t("Live attention", "实时注意力"),
                    title: model.t("A quiet place to notice.", "安静地，注意到。"),
                    subtitle: model.t(
                        "StillPoint stays out of the way until a chosen feed starts becoming automatic.",
                        "StillPoint 平时不打扰，只在你选择的信息流开始变成无意识滑动时出现。"
                    )
                ) {
                    StatusCluster(model: model)
                }

                IntentCheckpointPanel(model: model)

                TodaySummaryStrip(model: model)

                RecentActivityPanel(model: model)
            }
            .frame(maxWidth: 900, alignment: .leading)
            .padding(.horizontal, 34)
            .padding(.top, 30)
            .padding(.bottom, 42)
        }
        .animation(
            reduceMotion ? nil : .spring(response: 0.40, dampingFraction: 1),
            value: model.focusLockActive
        )
    }
}

private struct StatusCluster: View {
    @ObservedObject var model: AppModel

    var body: some View {
        VStack(alignment: .trailing, spacing: 7) {
            StatusPill(
                text: model.watchStateLabel,
                systemImage: model.monitoringEnabled ? "eye" : "eye.slash",
                tint: model.monitoringEnabled ? StillPointPalette.accent : .secondary
            )

            if model.focusLockActive {
                Label(
                    model.t("Locked for (model.focusLockRemaining.shortDurationString)", "专注锁剩余 (model.focusLockRemaining.shortDurationString)"),
                    systemImage: "lock.fill"
                )
                .font(.caption.monospacedDigit().weight(.medium))
                .foregroundStyle(StillPointPalette.warm)
                .contentTransition(.numericText())
            }
        }
    }
}

private struct IntentCheckpointPanel: View {
    @ObservedObject var model: AppModel

    private var gateTint: Color {
        model.focusLockActive ? StillPointPalette.warm : StillPointPalette.accent
    }

    private var activeDisplayName: String {
        model.activeBundleIdentifier.isEmpty
            ? model.t("No watched target", "暂无监控目标")
            : model.activeAppName
    }

    var body: some View {
        SurfaceCard(minHeight: 270) {
            VStack(alignment: .leading, spacing: 22) {
                HStack(alignment: .center, spacing: 12) {
                    IconRoundel(
                        systemImage: model.focusLockActive ? "lock.shield.fill" : "scope",
                        tint: gateTint
                    )

                    VStack(alignment: .leading, spacing: 3) {
                        Text(model.t("Current checkpoint", "当前检查点"))
                            .font(.headline)
                        Text(model.focusLockActive
                             ? model.t("Deep Work uses a firm three-second pause.", "专注锁使用明确的三秒暂停。")
                             : model.t("Watching only the targets you chose.", "只观察你主动选择的目标。"))
                            .font(.callout)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Text(model.modeLabel)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(gateTint)
                }

                VStack(alignment: .leading, spacing: 10) {
                    HStack(alignment: .firstTextBaseline, spacing: 18) {
                        Text(activeDisplayName)
                            .font(.system(size: 38, weight: .semibold, design: .rounded))
                            .tracking(-0.8)
                            .lineLimit(1)
                            .minimumScaleFactor(0.65)

                        Spacer()

                        Text(model.activeElapsed.shortDurationString)
                            .font(.system(size: 20, weight: .semibold, design: .rounded).monospacedDigit())
                            .foregroundStyle(.secondary)
                            .contentTransition(.numericText())
                    }

                    ProgressLine(value: model.activeProgress, tint: gateTint, marker: 0.86)

                    HStack {
                        Text(model.activeBundleIdentifier.isEmpty
                             ? model.t("Waiting for a chosen feed", "等待已选信息流")
                             : model.activeBundleIdentifier)
                            .lineLimit(1)
                        Spacer()
                        Text("\(model.t("pause at", "暂停于")) \(model.visibleTriggerThreshold.shortDurationString)")
                            .monospacedDigit()
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }

                HStack(spacing: 10) {
                    Button {
                        model.simulateDouyinDrift()
                    } label: {
                        Label(model.t("Preview checkpoint", "预览检查点"), systemImage: "play.fill")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(StillPointPalette.accent)
                    .keyboardShortcut(.space, modifiers: [.command])

                    Button {
                        if model.focusLockActive {
                            model.stopFocusLock()
                        } else {
                            model.startFocusLock(minutes: 25)
                        }
                    } label: {
                        Label(
                            model.focusLockActive ? model.t("End Deep Work", "结束专注锁") : model.t("Start 25 min Deep Work", "开始 25 分钟专注"),
                            systemImage: model.focusLockActive ? "lock.open" : "lock.shield"
                        )
                    }

                    Spacer()
                }
            }
        }
    }
}

private struct TodaySummaryStrip: View {
    @ObservedObject var model: AppModel

    var body: some View {
        PlainPanel {
            HStack(spacing: 0) {
                SummaryItem(
                    title: model.t("Checkpoints", "检查点"),
                    value: "\(model.dailySummary.driftChecks)",
                    detail: model.t("today", "今天")
                )
                SummaryDivider()
                SummaryItem(
                    title: model.t("Returned", "已返回"),
                    value: "\(model.dailySummary.closedDrifts)",
                    detail: model.t("feeds closed", "次离开信息流")
                )
                SummaryDivider()
                SummaryItem(
                    title: model.t("Protected", "已保护"),
                    value: model.dailySummary.protectedSeconds.shortDurationString,
                    detail: model.t("estimated", "估算时间")
                )
            }
        }
    }
}

private struct SummaryItem: View {
    var title: String
    var value: String
    var detail: String

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)
            Text(value)
                .font(.system(size: 24, weight: .semibold, design: .rounded).monospacedDigit())
                .tracking(-0.35)
                .contentTransition(.numericText())
            Text(detail)
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 8)
    }
}

private struct SummaryDivider: View {
    var body: some View {
        Rectangle()
            .fill(.primary.opacity(0.075))
            .frame(width: 1, height: 58)
            .padding(.horizontal, 14)
    }
}

private struct RecentActivityPanel: View {
    @ObservedObject var model: AppModel

    var body: some View {
        let recent = Array(model.todayEvents.suffix(4).reversed())

        VStack(alignment: .leading, spacing: 12) {
            HStack {
                SectionKicker(model.t("Today’s receipt", "今天的小票"), systemImage: "text.page")
                Spacer()
                Text(model.todayEvents.isEmpty
                     ? model.t("Nothing to review", "暂无内容")
                     : model.t("\(model.todayEvents.count) moments", "\(model.todayEvents.count) 个片刻"))
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
            }

            if model.todayEvents.isEmpty {
                HStack(spacing: 12) {
                    Image(systemName: "leaf")
                        .font(.title3)
                        .foregroundStyle(StillPointPalette.accent)
                        .frame(width: 36, height: 36)
                        .background(StillPointPalette.accent.opacity(0.09), in: RoundedRectangle(cornerRadius: 10, style: .continuous))

                    Text(model.t(
                        "A quiet day so far. Your first checkpoint will appear here.",
                        "今天目前很安静。第一次检查会出现在这里。"
                    ))
                    .font(.callout)
                    .foregroundStyle(.secondary)
                }
                .padding(.vertical, 8)
            } else {
                VStack(spacing: 0) {
                    ForEach(recent) { event in
                        DataRow(
                            event.action.title(language: model.language),
                            value: event.date.shortTimeString,
                            caption: event.appName
                        )
                        if event.id != recent.last?.id {
                            HairlineDivider()
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 2)
    }
}
