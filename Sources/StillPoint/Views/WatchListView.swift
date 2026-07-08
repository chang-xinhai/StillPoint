import StillPointCore
import SwiftUI

struct WatchListView: View {
    @ObservedObject var model: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                PageHeader(
                    eyebrow: "Targets",
                    title: "Watch List",
                    subtitle: "Explicit high-risk feeds only. Work tools stay out of the net by default."
                )

                VStack(spacing: 10) {
                    ForEach($model.watchedApps) { $app in
                        WatchTargetRow(app: $app)
                    }
                }
            }
            .padding(30)
        }
    }
}

private struct WatchTargetRow: View {
    @Binding var app: WatchedApp

    var body: some View {
        SurfaceCard {
            HStack(alignment: .top, spacing: 14) {
                IconRoundel(systemImage: app.isEnabled ? "eye.fill" : "eye.slash", tint: app.isEnabled ? .green : .secondary)

                VStack(alignment: .leading, spacing: 7) {
                    HStack(spacing: 8) {
                        Text(app.displayName)
                            .font(.headline)
                        StatusPill(
                            text: app.isEnabled ? "On" : "Off",
                            systemImage: app.isEnabled ? "checkmark" : "minus",
                            tint: app.isEnabled ? .green : .secondary
                        )
                    }

                    Text(app.detail)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(app.matchTerms.joined(separator: "  ·  "))
                        .font(.caption.monospaced())
                        .foregroundStyle(.tertiary)
                        .lineLimit(1)
                }

                Spacer()

                Toggle("", isOn: $app.isEnabled)
                    .labelsHidden()
                    .toggleStyle(.switch)
            }
        }
    }
}

