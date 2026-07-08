import AppKit
import StillPointCore
import SwiftUI

struct MenuBarView: View {
    @ObservedObject var model: AppModel
    var openControlCenter: () -> Void

    private var activeModeText: String {
        if model.focusLockActive {
            return model.t("Deep Work · 3s checkpoint", "专注锁 · 3 秒检查")
        }

        return model.monitoringEnabled
            ? model.t("Active", "监控中")
            : model.t("Paused", "已暂停")
    }

    private var gateSubtitle: String {
        if model.focusLockActive {
            return model.t(
                "Deep Work Lock overrides normal app gates.",
                "专注锁会覆盖普通应用阈值。"
            )
        }

        return model.activeBundleIdentifier.isEmpty ? model.statusMessage : model.activeBundleIdentifier
    }

    private var tunableWatchedAppIndex: Int? {
        if let activeIndex = model.watchedApps.firstIndex(where: {
            $0.matches(appName: model.activeAppName, bundleIdentifier: model.activeBundleIdentifier)
        }) {
            return activeIndex
        }

        return model.watchedApps.firstIndex(where: \.isEnabled) ?? model.watchedApps.indices.first
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 17) {
                header
                MenuPanelRule()
                gateSection
                tuningSection
                MenuPanelRule()
                todaySection
                MenuPanelRule()
                actionsSection
            }
            .padding(22)
        }
        .frame(width: 382)
        .background {
            LinearGradient(
                colors: [
                    Color(red: 0.10, green: 0.12, blue: 0.16),
                    Color(red: 0.05, green: 0.06, blue: 0.09)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        .foregroundStyle(.white)
        .preferredColorScheme(.dark)
    }

    private var header: some View {
        HStack(spacing: 12) {
            Image(nsImage: NSApp.applicationIconImage)
                .resizable()
                .frame(width: 42, height: 42)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .shadow(color: .blue.opacity(0.28), radius: 16, x: 0, y: 8)

            VStack(alignment: .leading, spacing: 3) {
                Text("StillPoint")
                    .font(.system(size: 18, weight: .semibold))
                HStack(spacing: 7) {
                    Circle()
                        .fill(model.focusLockActive ? .orange : .blue)
                        .frame(width: 7, height: 7)
                    Text(activeModeText)
                        .font(.callout)
                        .foregroundStyle(.white.opacity(0.68))
                        .lineLimit(1)
                }
            }

            Spacer()

            Text(model.visibleTriggerThreshold.shortDurationString)
                .font(.callout.monospacedDigit().weight(.semibold))
                .foregroundStyle(.white.opacity(0.72))
        }
    }

    private var gateSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(model.t("Current gate", "当前检查点"))
                .font(.caption.weight(.medium))
                .foregroundStyle(.white.opacity(0.52))

            HStack(alignment: .firstTextBaseline) {
                Text(model.activeAppName)
                    .font(.system(size: 18, weight: .semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
                Spacer()
                Text("\(model.activeElapsed.shortDurationString) / \(model.visibleTriggerThreshold.shortDurationString)")
                    .font(.callout.monospacedDigit().weight(.semibold))
                    .foregroundStyle(.white.opacity(0.74))
            }

            MenuMeter(value: model.activeProgress, tint: model.focusLockActive ? .orange : .cyan)

            Text(gateSubtitle)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.46))
                .lineLimit(1)
        }
    }

    @ViewBuilder
    private var tuningSection: some View {
        if let index = tunableWatchedAppIndex {
            let target = model.watchedApps[index]

            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .firstTextBaseline) {
                    Text(model.t("Normal gate", "普通阈值"))
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.white.opacity(0.52))
                    Spacer()
                    Text(target.gateSeconds.shortDurationString)
                        .font(.caption.monospacedDigit().weight(.semibold))
                        .foregroundStyle(.white.opacity(0.70))
                }

                Slider(
                    value: gateBinding(for: index),
                    in: WatchedApp.minimumGateSeconds...WatchedApp.maximumGateSeconds,
                    step: WatchedApp.gateStepSeconds
                )
                .tint(.cyan)
                .controlSize(.small)

                HStack(spacing: 6) {
                    Image(systemName: model.focusLockActive ? "lock.shield" : "slider.horizontal.3")
                        .font(.caption.weight(.semibold))
                    Text(tuningCaption(for: target))
                        .font(.caption)
                        .lineLimit(1)
                }
                .foregroundStyle(.white.opacity(0.46))
            }
        }
    }

    private var todaySection: some View {
        let summary = model.dailySummary

        return HStack(alignment: .top, spacing: 16) {
            MenuMetricColumn(
                title: model.t("Checks", "检查"),
                value: "\(summary.driftChecks)"
            )
            MenuMetricColumn(
                title: model.t("Closed", "关闭"),
                value: "\(summary.closedDrifts)"
            )
            MenuMetricColumn(
                title: model.t("Protected", "保护"),
                value: summary.protectedSeconds.shortDurationString
            )
        }
    }

    private var actionsSection: some View {
        VStack(spacing: 2) {
            MenuCommandRow(title: model.t("Open Control Center", "打开控制中心"), shortcut: "⌘ O", systemImage: "macwindow") {
                openControlCenter()
            }

            MenuCommandRow(
                title: model.focusLockActive ? model.t("Stop Deep Work", "停止专注锁") : model.t("Start 25m Deep Work", "开启 25 分钟专注"),
                shortcut: nil,
                systemImage: model.focusLockActive ? "lock.open" : "lock.shield"
            ) {
                if model.focusLockActive {
                    model.stopFocusLock()
                } else {
                    model.startFocusLock(minutes: 25)
                }
            }

            MenuCommandRow(
                title: model.monitoringEnabled ? model.t("Pause watching", "暂停监控") : model.t("Resume watching", "继续监控"),
                shortcut: "⌘ P",
                systemImage: model.monitoringEnabled ? "pause.circle" : "play.circle"
            ) {
                model.monitoringEnabled.toggle()
            }

            MenuCommandRow(title: model.t("Quit StillPoint", "退出 StillPoint"), shortcut: "⌘ Q", systemImage: "xmark") {
                NSApp.terminate(nil)
            }
        }
    }

    private func tuningCaption(for app: WatchedApp) -> String {
        if model.focusLockActive {
            return model.t(
                "Lock stays 3s; this changes \(app.displayName) after lock.",
                "锁定期间仍为 3 秒；这里调整锁定后的 \(app.displayName)。"
            )
        }

        return model.t(
            "Adjusting \(app.displayName)",
            "正在调整 \(app.displayName)"
        )
    }

    private func gateBinding(for index: Int) -> Binding<TimeInterval> {
        Binding(
            get: {
                guard model.watchedApps.indices.contains(index) else {
                    return WatchedApp.defaultGateSeconds
                }

                return model.watchedApps[index].gateSeconds
            },
            set: { newValue in
                guard model.watchedApps.indices.contains(index) else { return }

                model.watchedApps[index].gateSeconds = newValue
                if model.watchedApps[index].matches(
                    appName: model.activeAppName,
                    bundleIdentifier: model.activeBundleIdentifier
                ) {
                    model.activeGateSeconds = AttentionGatePolicy.effectiveGateSeconds(
                        appGateSeconds: newValue,
                        focusLockActive: model.focusLockActive
                    )
                }
            }
        )
    }
}

private struct MenuPanelRule: View {
    var body: some View {
        Rectangle()
            .fill(.white.opacity(0.12))
            .frame(height: 1)
    }
}

private struct MenuMeter: View {
    var value: Double
    var tint: Color

    var body: some View {
        GeometryReader { proxy in
            let clamped = min(max(value, 0), 1)

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(.white.opacity(0.13))
                Capsule()
                    .fill(tint)
                    .frame(width: max(7, proxy.size.width * clamped))
                Rectangle()
                    .fill(.green)
                    .frame(width: 2)
                    .offset(x: proxy.size.width * 0.82)
            }
        }
        .frame(height: 7)
    }
}

private struct MenuMetricColumn: View {
    var title: String
    var value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title.uppercased())
                .font(.caption2.weight(.bold))
                .foregroundStyle(.white.opacity(0.50))
            Text(value)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundStyle(.white.opacity(0.88))
                .lineLimit(1)
                .minimumScaleFactor(0.70)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct MenuCommandRow: View {
    var title: String
    var shortcut: String?
    var systemImage: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: systemImage)
                    .font(.callout.weight(.medium))
                    .foregroundStyle(.white.opacity(0.56))
                    .frame(width: 20)

                Text(title)
                    .font(.callout.weight(.medium))
                    .foregroundStyle(.white.opacity(0.84))
                    .lineLimit(1)

                Spacer()

                if let shortcut {
                    Text(shortcut)
                        .font(.callout.monospacedDigit())
                        .foregroundStyle(.white.opacity(0.34))
                }
            }
            .contentShape(Rectangle())
            .padding(.vertical, 6)
        }
        .buttonStyle(.plain)
    }
}
