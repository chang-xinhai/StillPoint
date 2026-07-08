import SwiftUI

struct FocusLockView: View {
    @ObservedObject var model: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                WorkspaceHeader(
                    eyebrow: model.t("Shield", "保护"),
                    title: model.t("Deep Work Lock", "专注锁"),
                    subtitle: model.t(
                        "A lock for coding sessions, build waits, and agent waits.",
                        "给编程、构建等待、等待 agent 回复时使用的锁定模式。"
                    )
                )

                PlainPanel(minHeight: 232) {
                    VStack(alignment: .leading, spacing: 18) {
                        HStack(alignment: .center, spacing: 14) {
                            IconRoundel(
                                systemImage: model.focusLockActive ? "lock.shield.fill" : "lock.open",
                                tint: model.focusLockActive ? .orange : .secondary
                            )

                            VStack(alignment: .leading, spacing: 3) {
                                Text(model.focusLockActive ? model.t("Lock is active", "锁定生效中") : model.t("Ready when you are", "准备就绪"))
                                    .font(.title2.weight(.semibold))
                                Text(model.focusLockActive ? model.t("\(model.focusLockRemaining.shortDurationString) remaining", "剩余 \(model.focusLockRemaining.shortDurationString)") : model.t("Watched feeds keep their per-app gates.", "被监控信息流会使用各自的应用阈值。"))
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                        }

                        ProgressLine(
                            value: model.focusLockActive ? 1 - (model.focusLockRemaining / TimeInterval(25 * 60)) : 0,
                            tint: .orange,
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
            .frame(maxWidth: 860, alignment: .leading)
            .padding(.horizontal, 32)
            .padding(.vertical, 28)
        }
    }
}
