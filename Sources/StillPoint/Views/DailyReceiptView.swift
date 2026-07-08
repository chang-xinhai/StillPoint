import SwiftUI

struct DailyReceiptView: View {
    @ObservedObject var model: AppModel

    var body: some View {
        let summary = model.dailySummary

        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Daily Attention Receipt")
                    .font(.largeTitle.weight(.semibold))
                Text("A daily review, not a per-exit interruption.")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 16) {
                MetricTile(
                    title: "Drift checks",
                    value: "\(summary.driftChecks)",
                    caption: "Moments StillPoint asked for intent",
                    systemImage: "figure.mind.and.body"
                )
                MetricTile(
                    title: "Closed drifts",
                    value: "\(summary.closedDrifts)",
                    caption: "Times you chose to leave the feed",
                    systemImage: "xmark.circle"
                )
                MetricTile(
                    title: "Protected",
                    value: summary.protectedSeconds.shortDurationString,
                    caption: "Estimated deep-work time protected",
                    systemImage: "shield"
                )
            }

            if summary.hasData {
                List(model.attentionEvents.filter { Calendar.current.isDateInToday($0.date) }) { event in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(event.appName)
                                .font(.headline)
                            Text(event.action.rawValue)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text(event.date.shortTimeString)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }
                .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                ContentUnavailableView(
                    "No receipt yet",
                    systemImage: "text.page",
                    description: Text("Run the demo or use a watched app long enough to create today's first attention check.")
                )
            }
        }
        .padding(28)
    }
}

