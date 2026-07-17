import SwiftUI

struct DailyReceiptView: View {
    @ObservedObject var model: AppModel

    var body: some View {
        let summary = model.dailySummary

        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                WorkspaceHeader(
                    eyebrow: model.t("Today", "今天"),
                    title: model.t("A receipt, not a score.", "一张小票，不是成绩单。"),
                    subtitle: model.t(
                        "One calm review of the moments when you chose what happened next.",
                        "只回顾那些你重新选择下一步的片刻。"
                    )
                )

                SurfaceCard {
                    VStack(alignment: .leading, spacing: 22) {
                        HStack(alignment: .firstTextBaseline) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(Date.now, format: .dateTime.weekday(.wide).month(.wide).day())
                                    .font(.headline)
                                Text(model.t("Attention receipt", "注意力小票"))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            Image(systemName: "leaf.fill")
                                .foregroundStyle(StillPointPalette.accent)
                                .accessibilityHidden(true)
                        }

                        HairlineDivider()

                        HStack(spacing: 0) {
                            ReceiptMetric(
                                title: model.t("Checkpoints", "检查点"),
                                value: "\(summary.driftChecks)"
                            )
                            ReceiptMetric(
                                title: model.t("Feeds closed", "离开信息流"),
                                value: "\(summary.closedDrifts)"
                            )
                            ReceiptMetric(
                                title: model.t("Protected", "已保护"),
                                value: summary.protectedSeconds.shortDurationString
                            )
                        }

                        HairlineDivider()

                        VStack(alignment: .leading, spacing: 10) {
                            SectionKicker(model.t("Moments", "片刻"), systemImage: "clock")

                            if summary.hasData {
                                VStack(spacing: 0) {
                                    ForEach(model.todayEvents.reversed()) { event in
                                        ReceiptEventRow(event: event, language: model.language)
                                        if event.id != model.todayEvents.first?.id {
                                            HairlineDivider()
                                                .padding(.leading, 34)
                                        }
                                    }
                                }
                            } else {
                                HStack(spacing: 12) {
                                    IconRoundel(systemImage: "checkmark", tint: StillPointPalette.accent)
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text(model.t("Nothing to review yet", "暂时无需回顾"))
                                            .font(.headline)
                                        Text(model.t(
                                            "StillPoint will add a line only when it asks you to pause.",
                                            "只有在 StillPoint 请你暂停时，这里才会新增一行。"
                                        ))
                                        .font(.callout)
                                        .foregroundStyle(.secondary)
                                    }
                                }
                                .padding(.vertical, 10)
                            }
                        }

                        HairlineDivider()

                        Text(model.t(
                            "Your data stays on this Mac. Tomorrow begins with a clean page.",
                            "数据只保留在这台 Mac 上。明天会从新的一页开始。"
                        ))
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                    }
                }
            }
            .frame(maxWidth: 820, alignment: .leading)
            .padding(.horizontal, 34)
            .padding(.top, 30)
            .padding(.bottom, 42)
        }
    }
}

private struct ReceiptMetric: View {
    var title: String
    var value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(value)
                .font(.system(size: 28, weight: .semibold, design: .rounded).monospacedDigit())
                .tracking(-0.45)
                .contentTransition(.numericText())
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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
                Text(event.action.title(language: language))
                    .font(.callout.weight(.medium))
                Text(event.appName)
                    .font(.caption)
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
        case .closeApp: "arrow.uturn.backward"
        case .startLock: "lock.shield"
        }
    }

    private var tint: Color {
        switch event.action {
        case .purposePass, .intentionalBreak: StillPointPalette.accent
        case .closeApp: StillPointPalette.danger
        case .startLock: StillPointPalette.warm
        }
    }
}
