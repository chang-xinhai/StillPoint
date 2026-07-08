import StillPointCore
import SwiftUI

struct WatchListView: View {
    @ObservedObject var model: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                WorkspaceHeader(
                    eyebrow: "Targets",
                    title: "Watch List",
                    subtitle: "Explicit high-risk feeds only. Work tools stay out of the net by default."
                )

                PlainPanel {
                    VStack(spacing: 0) {
                        HStack {
                            SectionKicker("Explicit targets", systemImage: "eye")
                            Spacer()
                            Text("\(model.enabledWatchCount) enabled")
                                .font(.caption.monospacedDigit())
                                .foregroundStyle(.secondary)
                        }
                        .padding(.bottom, 10)

                        ForEach($model.watchedApps) { $app in
                            WatchTargetRow(app: $app)
                            if app.id != model.watchedApps.last?.id {
                                HairlineDivider()
                            }
                        }
                    }
                }
            }
            .frame(maxWidth: 860, alignment: .leading)
            .padding(.horizontal, 32)
            .padding(.vertical, 28)
        }
    }
}

private struct WatchTargetRow: View {
    @Binding var app: WatchedApp

    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            Image(systemName: app.isEnabled ? "checkmark.circle.fill" : "circle")
                .font(.title3)
                .foregroundStyle(app.isEnabled ? .green : .secondary)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 4) {
                Text(app.displayName)
                    .font(.headline)
                    .lineLimit(1)

                Text(app.detail)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                Text(app.matchTerms.joined(separator: "  /  "))
                    .font(.caption.monospaced())
                    .foregroundStyle(.tertiary)
                    .lineLimit(1)
            }

            Spacer()

            Toggle("", isOn: $app.isEnabled)
                .labelsHidden()
                .toggleStyle(.switch)
        }
        .padding(.vertical, 13)
    }
}
