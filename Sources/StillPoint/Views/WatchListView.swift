import StillPointCore
import SwiftUI

struct WatchListView: View {
    @ObservedObject var model: AppModel

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Watch List")
                    .font(.largeTitle.weight(.semibold))
                Text("StillPoint only watches explicitly enabled targets. Work tools and the whole browser stay unmonitored by default.")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }

            List {
                ForEach($model.watchedApps) { $app in
                    Toggle(isOn: $app.isEnabled) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(app.displayName)
                                .font(.headline)
                            Text(app.detail)
                                .font(.callout)
                                .foregroundStyle(.secondary)
                            Text(app.matchTerms.joined(separator: ", "))
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                        .padding(.vertical, 6)
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .padding(28)
    }
}
