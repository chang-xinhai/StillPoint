import AppKit
import SwiftUI

struct MenuBarView: View {
    @ObservedObject var model: AppModel
    var openControlCenter: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 14) {
                header
                gateSection
                lockSection
                todaySection
            }
            .padding(.horizontal, 18)
            .padding(.top, 18)
            .padding(.bottom, 14)

            HairlineDivider()

            VStack(spacing: 0) {
                MenuCommandRow(title: model.t("Open Control Center", "打开控制中心"), shortcut: nil, systemImage: "macwindow") {
                    openControlCenter()
                }
                MenuCommandRow(
                    title: model.monitoringEnabled ? model.t("Pause Watching", "暂停监控") : model.t("Resume Watching", "继续监控"),
                    shortcut: "⌘ P",
                    systemImage: model.monitoringEnabled ? "pause.circle" : "play.circle"
                ) {
                    model.monitoringEnabled.toggle()
                }
                MenuCommandRow(title: model.t("Quit StillPoint", "退出 StillPoint"), shortcut: "⌘ Q", systemImage: "xmark.square") {
                    NSApp.terminate(nil)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 7)
        }
        .frame(width: 398)
        .background(.regularMaterial)
    }

    private var header: some View {
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
                Text("\(model.visibleTriggerThreshold.shortDurationString) gate")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var gateSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            MenuSectionTitle("Gate")
            QuotaProgressRow(
                title: model.activeAppName,
                subtitle: model.activeBundleIdentifier.isEmpty ? model.statusMessage : model.activeBundleIdentifier,
                leadingValue: "\(Int(max(0, 1 - model.activeProgress) * 100))% safe",
                trailingValue: "\(model.visibleTriggerThreshold.shortDurationString) gate",
                value: model.activeProgress,
                tint: model.focusLockActive ? .orange : .cyan
            )
        }
    }

    private var lockSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            MenuSectionTitle("Deep Work")
            QuotaProgressRow(
                title: "Lock",
                subtitle: model.focusLockActive ? "\(model.focusLockRemaining.shortDurationString) remaining" : "Off",
                leadingValue: model.focusLockActive ? "active" : "ready",
                trailingValue: "25 min",
                value: model.focusLockActive ? 0.72 : 0,
                tint: .orange
            )
        }
    }

    private var todaySection: some View {
        let summary = model.dailySummary

        return VStack(alignment: .leading, spacing: 8) {
            MenuSectionTitle("Today")
            CompactDataBlock(rows: [
                ("Checks", "\(summary.driftChecks)", "Intent moments"),
                ("Closed", "\(summary.closedDrifts)", "Feeds left"),
                ("Protected", summary.protectedSeconds.shortDurationString, "Estimated time returned")
            ])
        }
    }
}

private struct MenuSectionTitle: View {
    var title: String

    init(_ title: String) {
        self.title = title
    }

    var body: some View {
        Text(title)
            .font(.headline.weight(.semibold))
    }
}

private struct QuotaProgressRow: View {
    var title: String
    var subtitle: String
    var leadingValue: String
    var trailingValue: String
    var value: Double
    var tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline) {
                Text(title)
                    .font(.callout.weight(.semibold))
                    .lineLimit(1)
                Spacer()
                Text(trailingValue)
                    .font(.callout.monospacedDigit().weight(.medium))
                    .foregroundStyle(.secondary)
            }

            ProgressLine(value: value, tint: tint, marker: value > 0 ? 0.86 : nil)
                .frame(height: 7)

            HStack(alignment: .firstTextBaseline) {
                Text(leadingValue)
                    .font(.caption.weight(.medium))
                Spacer()
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
    }
}

private struct CompactDataBlock: View {
    var rows: [(title: String, value: String, detail: String)]

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(rows.enumerated()), id: \.offset) { index, row in
                HStack(alignment: .firstTextBaseline, spacing: 12) {
                    VStack(alignment: .leading, spacing: 1) {
                        Text(row.title)
                            .font(.callout.weight(.medium))
                        Text(row.detail)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }

                    Spacer()

                    Text(row.value)
                        .font(.callout.monospacedDigit().weight(.semibold))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                .padding(.vertical, 6)

                if index < rows.count - 1 {
                    HairlineDivider()
                }
            }
        }
    }
}

private struct MenuCommandRow: View {
    var title: String
    var shortcut: String?
    var systemImage: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 9) {
                Image(systemName: systemImage)
                    .font(.callout.weight(.medium))
                    .foregroundStyle(.secondary)
                    .frame(width: 18)

                Text(title)
                    .font(.callout.weight(.medium))
                    .lineLimit(1)

                Spacer()

                if let shortcut {
                    Text(shortcut)
                        .font(.callout.monospacedDigit())
                        .foregroundStyle(.tertiary)
                } else {
                    Image(systemName: "chevron.right")
                        .font(.callout.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
            }
            .contentShape(Rectangle())
            .padding(.horizontal, 6)
            .padding(.vertical, 6)
        }
        .buttonStyle(.plain)
    }
}
