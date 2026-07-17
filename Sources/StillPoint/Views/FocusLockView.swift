import StillPointCore
import SwiftUI

struct FocusLockView: View {
    @ObservedObject var model: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                WorkspaceHeader(
                    eyebrow: model.t("Deep Work", "深度工作"),
                    title: model.t("Hold the boundary.", "守住这段边界。"),
                    subtitle: model.t(
                        "Use a three-second checkpoint during coding, build waits, and agent waits.",
                        "在编程、构建等待和等待 agent 回复时，用三秒检查守住注意力。"
                    )
                )

                SurfaceCard(minHeight: 248) {
                    VStack(alignment: .leading, spacing: 18) {
                        HStack(alignment: .center, spacing: 14) {
                            IconRoundel(
                                systemImage: model.focusLockActive ? "lock.shield.fill" : "lock.open",
                                tint: model.focusLockActive ? StillPointPalette.warm : StillPointPalette.accent
                            )

                            VStack(alignment: .leading, spacing: 3) {
                                Text(model.focusLockActive ? model.t("Boundary is active", "边界已生效") : model.t("Choose a focus window", "选择专注时段"))
                                    .font(.title2.weight(.semibold))
                                Text(model.focusLockActive ? model.t("\(model.focusLockRemaining.shortDurationString) remaining", "剩余 \(model.focusLockRemaining.shortDurationString)") : model.t("Watched feeds switch to a 3s checkpoint during lock.", "锁定期间，被监控信息流会切换为 3 秒检查点。"))
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                        }

                        ProgressLine(
                            value: model.focusLockActive ? 1 - (model.focusLockRemaining / AttentionGatePolicy.overlayFocusLockSeconds) : 0,
                            tint: StillPointPalette.warm,
                            marker: nil
                        )

                        VStack(spacing: 0) {
                            DataRow(model.t("Current gate", "当前阈值"), value: model.visibleTriggerThreshold.shortDurationString, caption: model.t("From the active watched app", "来自当前被监控应用"))
                            HairlineDivider()
                            DataRow(model.t("Mode", "模式"), value: model.modeLabel, caption: model.t("Per-app timing", "逐应用计时"))
                            HairlineDivider()
                            DataRow(model.t("Watched targets", "监控目标"), value: "\(model.enabledWatchCount)", caption: model.t("Apps covered by the shield", "被保护机制覆盖的应用"))
                        }
                    }
                }

                HStack(spacing: 10) {
                    Button {
                        model.startFocusLock(minutes: 25)
                    } label: {
                        Label(model.t("25 min", "25 分钟"), systemImage: "lock.fill")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(StillPointPalette.accent)

                    Button {
                        model.startFocusLock(minutes: 45)
                    } label: {
                        Label(model.t("45 min", "45 分钟"), systemImage: "clock")
                    }

                    Button {
                        model.startFocusLock(minutes: 90)
                    } label: {
                        Label(model.t("90 min", "90 分钟"), systemImage: "moon")
                    }

                    Spacer()

                    Button(role: .destructive) {
                        model.stopFocusLock()
                    } label: {
                        Label(model.t("Stop", "停止"), systemImage: "lock.open")
                    }
                    .disabled(!model.focusLockActive)
                }

                Text(model.t(
                    "MVP: StillPoint proves the intervention loop. System-level anti-bypass belongs to the later Android / permissions pass.",
                    "MVP 阶段先验证干预闭环。系统级防绕过会放到后续 Android / 权限版本。"
                ))
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: 900, alignment: .leading)
            .padding(.horizontal, 34)
            .padding(.top, 30)
            .padding(.bottom, 42)
        }
    }
}
