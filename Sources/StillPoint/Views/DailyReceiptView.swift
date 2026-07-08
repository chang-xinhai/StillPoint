import SwiftUI

struct DailyReceiptView: View {
    @ObservedObject var model: AppModel

    var body: some View {
        let summary = model.dailySummary

        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                WorkspaceHeader(
                    eyebrow: model.t("Today", "今天"),
                    title: model.t("Daily Attention Receipt", "每日注意力小票"),
                    subtitle: model.t(
                        "A single low-pressure review, never a per-exit interruption.",
                        "每天一次轻量回顾，而不是每次退出都打扰你。"
                    )
                )

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 170), spacing: 12)], spacing: 12) {
                    SummaryTile(
                        title: model.t("Checks", "检查"),
                        value: "\(summary.driftChecks)",
                        caption: model.t("Intent moments", "意图检查"),
                        systemImage: "figure.mind.and.body",
                        tint: .cyan
                    )
                    SummaryTile(
                        title: model.t("Closed", "关闭"),
                        value: "\(summary.closedDrifts)",
                        caption: model.t("Feeds left", "离开的信息流"),
                        systemImage: "xmark.circle",
                        tint: .red
                    )
                    SummaryTile(
                        title: model.t("Protected", "保护"),
                        value: summary.protectedSeconds.shortDurationString,
                        caption: model.t("Estimated return", "估算找回"),
                        systemImage: "shield",
                        tint: .green
                    )
                }

                PlainPanel {
                    VStack(alignment: .leading, spacing: 14) {
                        SectionKicker(model.t("Timeline", "时间线"), systemImage: "clock")

                        if summary.hasData {
                            VStack(spacing: 0) {
                                ForEach(model.todayEvents.reversed()) { event in
                                    ReceiptEventRow(event: event, language: model.language)
                                    if event.id != model.todayEvents.first?.id {
                                        HairlineDivider()
                                    }
                                }
                            }
                        } else {
                            HStack(spacing: 12) {
                                IconRoundel(systemImage: "text.page", tint: .secondary)
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(model.t("No receipt yet", "还没有小票"))
                                        .font(.headline)
                                    Text(model.t(
                                        "Simulate once or use a watched target long enough to create the first check.",
                                        "模拟一次，或使用被监控目标足够久，以生成第一次检查。"
                                    ))
                                        .font(.callout)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .padding(.vertical, 8)
                        }
                    }
                }
            }
            .frame(maxWidth: 860, alignment: .leading)
            .padding(.horizontal, 32)
            .padding(.vertical, 28)
        }
    }
}

private struct ReceiptEventRow: View {
    var event: AttentionEvent
    var language: AppLanguage

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.callout.weight(.semibold))
                .foregroundStyle(tint)
                .frame(width: 22)
            VStack(alignment: .leading, spacing: 3) {
                Text(event.appName)
                    .font(.headline)
                Text(event.action.title(language: language))
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(event.date.shortTimeString)
                .font(.callout.monospacedDigit())
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 10)
    }

    private var icon: String {
        switch event.action {
        case .purposePass: "magnifyingglass"
        case .intentionalBreak: "cup.and.saucer"
        case .closeApp: "xmark.circle"
        case .startLock: "lock.shield"
        }
    }

    private var tint: Color {
        switch event.action {
        case .purposePass: .blue
        case .intentionalBreak: .purple
        case .closeApp: .red
        case .startLock: .orange
        }
    }
}
