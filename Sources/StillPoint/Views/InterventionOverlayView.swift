import SwiftUI

struct InterventionOverlayView: View {
    var context: InterventionContext
    var onAction: (InterventionAction) -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.72)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                VStack(spacing: 22) {
                    HStack {
                        StatusPill(
                            text: context.isFocusLock
                                ? context.language.text("Deep Work Lock", "专注锁")
                                : context.language.text("App gate reached", "应用阈值已到"),
                            systemImage: context.isFocusLock ? "lock.shield" : "pause.circle",
                            tint: context.isFocusLock ? .orange : .blue
                        )
                        Spacer()
                        Text(context.elapsedSeconds.shortDurationString)
                            .font(.callout.monospacedDigit().weight(.semibold))
                            .foregroundStyle(.secondary)
                    }

                    VStack(spacing: 9) {
                        Text("StillPoint")
                            .font(.system(size: 38, weight: .semibold))
                        Text(context.language.text("Are you still here for the reason you came?", "你还在为刚才进来的理由而停留吗？"))
                            .font(.title2.weight(.semibold))
                            .multilineTextAlignment(.center)
                        Text(context.language.text(
                            "\(context.appName) has held focus long enough to check intent.",
                            "\(context.appName) 已经停留到需要确认意图的时间。"
                        ))
                            .font(.callout)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: 560)

                    QuietDivider()

                    VStack(spacing: 10) {
                        HStack(spacing: 10) {
                            OverlayChoiceButton(
                                title: context.language.text("Looking something up", "我在查东西"),
                                detail: context.language.text("Purpose pass", "查找通行"),
                                systemImage: "magnifyingglass",
                                tint: .blue
                            ) {
                                onAction(.purposePass)
                            }

                            OverlayChoiceButton(
                                title: context.language.text("Intentional break", "有意休息"),
                                detail: context.language.text("Bounded pause", "有边界的暂停"),
                                systemImage: "cup.and.saucer",
                                tint: .purple
                            ) {
                                onAction(.intentionalBreak)
                            }
                        }

                        HStack(spacing: 10) {
                            OverlayChoiceButton(
                                title: context.language.text("I drifted", "我走神了"),
                                detail: context.language.text("Close the feed", "关闭信息流"),
                                systemImage: "xmark.circle",
                                tint: .red
                            ) {
                                onAction(.closeApp)
                            }

                            OverlayChoiceButton(
                                title: context.language.text("Lock this", "锁住这次"),
                                detail: context.language.text("Protect focus", "保护专注"),
                                systemImage: "lock.shield",
                                tint: .orange
                            ) {
                                onAction(.startLock)
                            }
                        }
                    }
                }
                .padding(26)
            }
            .frame(width: 700)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .strokeBorder(.white.opacity(0.14), lineWidth: 1)
            }
            .shadow(color: .black.opacity(0.34), radius: 30, x: 0, y: 18)
            .padding(40)
        }
        .preferredColorScheme(.dark)
    }
}

private struct OverlayChoiceButton: View {
    var title: String
    var detail: String
    var systemImage: String
    var tint: Color
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 11) {
                IconRoundel(systemImage: systemImage, tint: tint)

                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.headline)
                    Text(detail)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }
            .padding(13)
            .frame(maxWidth: .infinity, minHeight: 72)
            .background(.primary.opacity(0.055), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .strokeBorder(.primary.opacity(0.08), lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
    }
}
