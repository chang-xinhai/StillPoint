import AppKit
import StillPointCore
import SwiftUI

struct MenuBarView: View {
    @ObservedObject var model: AppModel
    var openControlCenter: () -> Void

    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    private var statusTint: Color {
        if model.focusLockActive { return StillPointPalette.warm }
        return model.monitoringEnabled ? StillPointPalette.accent : .secondary
    }

    private var activeModeText: String {
        if model.focusLockActive {
            return model.t("Deep Work", "专注锁")
        }
        return model.monitoringEnabled ? model.t("Watching", "监控中") : model.t("Paused", "已暂停")
    }

    private var gateSubtitle: String {
        if model.focusLockActive {
            return model.t("Three-second pause is active", "三秒暂停已生效")
        }
        return model.activeBundleIdentifier.isEmpty ? model.statusMessage : model.activeBundleIdentifier
    }

    private var activeDisplayName: String {
        model.activeBundleIdentifier.isEmpty
            ? model.t("No watched target", "暂无监控目标")
            : model.activeAppName
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            header
            gateSection
            focusAction
            todaySection
            MenuPanelRule()
            actionsSection
        }
        .padding(18)
        .frame(width: 356)
        .background {
            ZStack {
                if reduceTransparency {
                    Color(nsColor: .windowBackgroundColor)
                } else {
                    Rectangle().fill(.ultraThickMaterial)
                }

                LinearGradient(
                    colors: [
                        StillPointPalette.accent.opacity(0.075),
                        .clear,
                        Color.primary.opacity(0.018)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        }
        .tint(StillPointPalette.accent)
    }

    private var header: some View {
        HStack(spacing: 11) {
            Image(nsImage: NSApp.applicationIconImage)
                .resizable()
                .frame(width: 34, height: 34)
                .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
                .shadow(color: StillPointPalette.accent.opacity(0.16), radius: 9, x: 0, y: 5)

            VStack(alignment: .leading, spacing: 2) {
                Text("StillPoint")
                    .font(.system(size: 16, weight: .semibold))
                HStack(spacing: 6) {
                    Circle()
                        .fill(statusTint)
                        .frame(width: 6, height: 6)
                    Text(activeModeText)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Text(model.focusLockActive ? model.focusLockRemaining.shortDurationString : model.visibleTriggerThreshold.shortDurationString)
                .font(.callout.monospacedDigit().weight(.semibold))
                .foregroundStyle(statusTint)
                .contentTransition(.numericText())
        }
    }

    private var gateSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(model.t("Now", "当前"))
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)
                    Text(activeDisplayName)
                        .font(.system(size: 20, weight: .semibold))
                        .tracking(-0.3)
                        .lineLimit(1)
                }

                Spacer()

                Text("\(model.activeElapsed.shortDurationString) / \(model.visibleTriggerThreshold.shortDurationString)")
                    .font(.caption.monospacedDigit().weight(.medium))
                    .foregroundStyle(.secondary)
            }

            ProgressLine(value: model.activeProgress, tint: statusTint, marker: 0.86)

            Text(gateSubtitle)
                .font(.caption)
                .foregroundStyle(.tertiary)
                .lineLimit(1)
        }
        .padding(14)
        .background(.primary.opacity(0.04), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(.primary.opacity(0.07), lineWidth: 1)
        }
    }

    private var focusAction: some View {
        Button {
            if model.focusLockActive {
                model.stopFocusLock()
            } else {
                model.startFocusLock(minutes: 25)
            }
        } label: {
            HStack(spacing: 10) {
                Image(systemName: model.focusLockActive ? "lock.open" : "lock.shield")
                    .foregroundStyle(model.focusLockActive ? StillPointPalette.warm : StillPointPalette.accent)
                    .frame(width: 20)

                VStack(alignment: .leading, spacing: 2) {
                    Text(model.focusLockActive
                         ? model.t("End Deep Work", "结束专注锁")
                         : model.t("Start 25 min Deep Work", "开始 25 分钟专注"))
                        .font(.callout.weight(.medium))
                    Text(model.t("A firm three-second checkpoint", "使用明确的三秒检查点"))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(MenuPressButtonStyle())
    }

    private var todaySection: some View {
        let summary = model.dailySummary

        return VStack(alignment: .leading, spacing: 9) {
            Text(model.t("Today", "今天"))
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)

            HStack(spacing: 0) {
                MenuMetricColumn(title: model.t("Checks", "检查"), value: "\(summary.driftChecks)")
                MenuMetricColumn(title: model.t("Returned", "返回"), value: "\(summary.closedDrifts)")
                MenuMetricColumn(title: model.t("Protected", "保护"), value: summary.protectedSeconds.shortDurationString)
            }
        }
    }

    private var actionsSection: some View {
        VStack(spacing: 2) {
            MenuCommandRow(title: model.t("Open Control Center", "打开控制中心"), systemImage: "macwindow") {
                openControlCenter()
            }

            MenuCommandRow(
                title: model.monitoringEnabled ? model.t("Pause watching", "暂停监控") : model.t("Resume watching", "继续监控"),
                systemImage: model.monitoringEnabled ? "pause" : "play"
            ) {
                model.monitoringEnabled.toggle()
            }

            MenuCommandRow(title: model.t("Preview checkpoint", "预览检查点"), systemImage: "play.rectangle") {
                model.simulateDouyinDrift()
            }

            MenuCommandRow(title: model.t("Quit StillPoint", "退出 StillPoint"), systemImage: "power") {
                NSApp.terminate(nil)
            }
        }
    }
}

private struct MenuPanelRule: View {
    var body: some View {
        Rectangle()
            .fill(.primary.opacity(0.075))
            .frame(height: 1)
    }
}

private struct MenuMetricColumn: View {
    var title: String
    var value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value)
                .font(.system(size: 17, weight: .semibold, design: .rounded).monospacedDigit())
                .contentTransition(.numericText())
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct MenuCommandRow: View {
    var title: String
    var systemImage: String
    var action: () -> Void

    @State private var hovering = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: systemImage)
                    .font(.callout.weight(.medium))
                    .foregroundStyle(.secondary)
                    .frame(width: 20)

                Text(title)
                    .font(.callout.weight(.medium))
                    .lineLimit(1)

                Spacer()
            }
            .contentShape(Rectangle())
            .padding(.horizontal, 8)
            .padding(.vertical, 7)
            .background(
                hovering ? Color.primary.opacity(0.065) : .clear,
                in: RoundedRectangle(cornerRadius: 8, style: .continuous)
            )
        }
        .buttonStyle(PressableButtonStyle())
        .onHover { hovering = $0 }
    }
}

private struct MenuPressButtonStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var hovering = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(10)
            .background(
                Color.primary.opacity(configuration.isPressed ? 0.09 : (hovering ? 0.06 : 0.035)),
                in: RoundedRectangle(cornerRadius: 11, style: .continuous)
            )
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.985 : 1)
            .animation(reduceMotion ? nil : .easeOut(duration: 0.10), value: configuration.isPressed)
            .onHover { hovering = $0 }
    }
}
