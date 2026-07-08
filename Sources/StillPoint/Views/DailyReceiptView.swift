import SwiftUI

struct DailyReceiptView: View {
    @ObservedObject var model: AppModel

    var body: some View {
        let summary = model.dailySummary

        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                PageHeader(
                    eyebrow: "Today",
                    title: "Daily Attention Receipt",
                    subtitle: "A single low-pressure review, never a per-exit interruption."
                )

                HStack(spacing: 12) {
                    MetricTile(
                        title: "Checks",
                        value: "\(summary.driftChecks)",
                        caption: "Intent moments",
                        systemImage: "figure.mind.and.body",
                        tint: .blue
                    )
                    MetricTile(
                        title: "Closed",
                        value: "\(summary.closedDrifts)",
                        caption: "Feeds left",
                        systemImage: "xmark.circle",
                        tint: .red
                    )
                    MetricTile(
                        title: "Protected",
                        value: summary.protectedSeconds.shortDurationString,
                        caption: "Estimated return",
                        systemImage: "shield",
                        tint: .green
                    )
                }

                SurfaceCard {
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Timeline")
                            .font(.headline)

                        if summary.hasData {
                            VStack(spacing: 0) {
                                ForEach(model.todayEvents) { event in
                                    ReceiptEventRow(event: event)
                                    if event.id != model.todayEvents.last?.id {
                                        QuietDivider()
                                    }
                                }
                            }
                        } else {
                            HStack(spacing: 12) {
                                IconRoundel(systemImage: "text.page", tint: .secondary)
                                VStack(alignment: .leading, spacing: 3) {
                                    Text("No receipt yet")
                                        .font(.headline)
                                    Text("Run the demo or use a watched target long enough to create the first check.")
                                        .font(.callout)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .padding(.vertical, 8)
                        }
                    }
                }
            }
            .padding(30)
        }
    }
}

private struct ReceiptEventRow: View {
    var event: AttentionEvent

    var body: some View {
        HStack(spacing: 12) {
            IconRoundel(systemImage: icon, tint: tint)
            VStack(alignment: .leading, spacing: 3) {
                Text(event.appName)
                    .font(.headline)
                Text(event.action.rawValue)
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

