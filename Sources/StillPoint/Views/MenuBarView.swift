import AppKit
import SwiftUI

struct MenuBarView: View {
    @ObservedObject var model: AppModel
    @Environment(\.openWindow) private var openWindow
    @State private var panel: MenuPanel = .overview

    var body: some View {
        VStack(spacing: 0) {
            MenuTabStrip(selection: $panel)
                .padding(.horizontal, 14)
                .padding(.top, 10)
                .padding(.bottom, 8)

            HairlineDivider()

            Group {
                switch panel {
                case .overview:
                    OverviewMenuPanel(model: model)
                case .gate:
                    GateMenuPanel(model: model)
                case .lock:
                    LockMenuPanel(model: model)
                case .receipt:
                    ReceiptMenuPanel(model: model)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)

            HairlineDivider()

            VStack(spacing: 0) {
                MenuCommandRow(title: "Open Control Center", detail: "Show window", systemImage: "macwindow") {
                    openWindow(id: "control")
                    NSApp.activate(ignoringOtherApps: true)
                }

                MenuCommandRow(
                    title: model.monitoringEnabled ? "Pause watching" : "Resume watching",
                    detail: model.monitoringEnabled ? "Temporarily stop checks" : "Start checks again",
                    systemImage: model.monitoringEnabled ? "pause.circle" : "play.circle"
                ) {
                    model.monitoringEnabled.toggle()
                }

                MenuCommandRow(title: "Quit StillPoint", detail: "Stop menu bar agent", systemImage: "xmark.circle") {
                    NSApp.terminate(nil)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
        }
        .frame(width: 398)
        .background(.regularMaterial)
    }
}

private enum MenuPanel: String, CaseIterable, Identifiable {
    case overview
    case gate
    case lock
    case receipt

    var id: String { rawValue }

    var title: String {
        switch self {
        case .overview: "Overview"
        case .gate: "Gate"
        case .lock: "Lock"
        case .receipt: "Receipt"
        }
    }

    var systemImage: String {
        switch self {
        case .overview: "square.grid.2x2"
        case .gate: "scope"
        case .lock: "lock.shield"
        case .receipt: "text.page"
        }
    }
}

private struct MenuTabStrip: View {
    @Binding var selection: MenuPanel

    var body: some View {
        HStack(spacing: 6) {
            ForEach(MenuPanel.allCases) { panel in
                Button {
                    selection = panel
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: panel.systemImage)
                            .font(.system(size: 17, weight: .semibold))
                        Text(panel.title)
                            .font(.caption.weight(.semibold))
                    }
                    .foregroundStyle(selection == panel ? .white : .secondary)
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background {
                        if selection == panel {
                            RoundedRectangle(cornerRadius: 9, style: .continuous)
                                .fill(.blue.gradient)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }
}

private struct OverviewMenuPanel: View {
    @ObservedObject var model: AppModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            MenuIdentityHeader(model: model)
            MenuGateSection(model: model)
            MenuTodaySection(model: model)
        }
    }
}

private struct GateMenuPanel: View {
    @ObservedObject var model: AppModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            MenuGateSection(model: model)
            MenuSection(title: "Policy") {
                MenuDataRow(title: "Threshold", value: model.visibleTriggerThreshold.shortDurationString, caption: model.focusLockActive ? "Strict lock gate" : "Grace before interruption")
                MenuDataRow(title: "Targets", value: "\(model.enabledWatchCount)", caption: "Explicitly watched")
                MenuDataRow(title: "Mode", value: model.demoMode ? "Demo" : "Normal", caption: model.demoMode ? "Short timings" : "Everyday timings")
            }
        }
    }
}

private struct LockMenuPanel: View {
    @ObservedObject var model: AppModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            MenuSection(title: "Deep Work Lock") {
                MenuDataRow(
                    title: model.focusLockActive ? "Active" : "Ready",
                    value: model.focusLockActive ? model.focusLockRemaining.shortDurationString : "Off",
                    caption: model.focusLockActive ? "Remaining" : "Watched feeds get a stricter gate"
                )

                Button {
                    if model.focusLockActive {
                        model.stopFocusLock()
                    } else {
                        model.startFocusLock(minutes: model.demoMode ? 1 : 25)
                    }
                } label: {
                    Label(model.focusLockActive ? "Stop work lock" : "Start work lock", systemImage: model.focusLockActive ? "lock.open" : "lock.shield")
                        .font(.callout.weight(.semibold))
                        .frame(maxWidth: .infinity, minHeight: 34)
                }
                .buttonStyle(.borderedProminent)
            }

            MenuSection(title: "Presets") {
                HStack(spacing: 8) {
                    PresetButton(title: model.demoMode ? "1m" : "25m") {
                        model.startFocusLock(minutes: model.demoMode ? 1 : 25)
                    }
                    PresetButton(title: "45m") {
                        model.startFocusLock(minutes: 45)
                    }
                    PresetButton(title: "90m") {
                        model.startFocusLock(minutes: 90)
                    }
                }
            }
        }
    }
}

private struct ReceiptMenuPanel: View {
    @ObservedObject var model: AppModel

    var body: some View {
        let recent = Array(model.todayEvents.suffix(3).reversed())

        VStack(alignment: .leading, spacing: 16) {
            MenuTodaySection(model: model)

            MenuSection(title: "Latest") {
                if model.todayEvents.isEmpty {
                    Text("No checkpoints yet today.")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .padding(.vertical, 6)
                } else {
                    ForEach(recent) { event in
                        MenuDataRow(title: event.action.rawValue, value: event.date.shortTimeString, caption: event.appName)
                        if event.id != recent.last?.id {
                            HairlineDivider()
                        }
                    }
                }
            }
        }
    }
}

private struct MenuIdentityHeader: View {
    @ObservedObject var model: AppModel

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text("StillPoint")
                    .font(.title3.weight(.semibold))
                Text(model.monitoringEnabled ? "Watching from the menu bar" : "Monitoring paused")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 3) {
                Text(model.modeLabel)
                    .font(.callout.weight(.semibold))
                Text(model.demoMode ? "Demo timing" : "Normal timing")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

private struct MenuGateSection: View {
    @ObservedObject var model: AppModel

    var body: some View {
        MenuSection(title: "Current gate") {
            HStack(alignment: .firstTextBaseline) {
                Text(model.activeAppName)
                    .font(.headline)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
                Spacer()
                Text("\(model.activeElapsed.shortDurationString) / \(model.visibleTriggerThreshold.shortDurationString)")
                    .font(.callout.monospacedDigit().weight(.semibold))
                    .foregroundStyle(.secondary)
            }

            ProgressLine(value: model.activeProgress, tint: model.focusLockActive ? .orange : .cyan, marker: 0.86)

            Text(model.activeBundleIdentifier.isEmpty ? model.statusMessage : model.activeBundleIdentifier)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

private struct MenuTodaySection: View {
    @ObservedObject var model: AppModel

    var body: some View {
        let summary = model.dailySummary

        MenuSection(title: "Today") {
            MenuDataRow(title: "Checks", value: "\(summary.driftChecks)", caption: "Intent moments")
            HairlineDivider()
            MenuDataRow(title: "Closed", value: "\(summary.closedDrifts)", caption: "Feeds left")
            HairlineDivider()
            MenuDataRow(title: "Protected", value: summary.protectedSeconds.shortDurationString, caption: "Estimated time returned")
        }
    }
}

private struct MenuSection<Content: View>: View {
    var title: String
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            Text(title)
                .font(.headline)
            VStack(alignment: .leading, spacing: 0) {
                content
            }
        }
    }
}

private struct MenuDataRow: View {
    var title: String
    var value: String
    var caption: String

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.callout.weight(.medium))
                Text(caption)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            Text(value)
                .font(.callout.monospacedDigit().weight(.semibold))
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .padding(.vertical, 8)
    }
}

private struct MenuCommandRow: View {
    var title: String
    var detail: String
    var systemImage: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: systemImage)
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .frame(width: 18)
                VStack(alignment: .leading, spacing: 1) {
                    Text(title)
                        .font(.callout.weight(.medium))
                    Text(detail)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            .contentShape(Rectangle())
            .padding(.horizontal, 8)
            .padding(.vertical, 7)
        }
        .buttonStyle(.plain)
    }
}

private struct PresetButton: View {
    var title: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.callout.monospacedDigit().weight(.semibold))
                .frame(maxWidth: .infinity, minHeight: 30)
        }
        .buttonStyle(.bordered)
    }
}
