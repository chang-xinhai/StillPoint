import SwiftUI

struct DashboardView: View {
    @ObservedObject var model: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                header

                HStack(spacing: 16) {
                    MetricTile(
                        title: "Current app",
                        value: model.activeAppName,
                        caption: model.activeBundleIdentifier.isEmpty ? "No bundle id" : model.activeBundleIdentifier,
                        systemImage: "macwindow"
                    )
                    MetricTile(
                        title: "Watched time",
                        value: model.activeElapsed.shortDurationString,
                        caption: model.statusMessage,
                        systemImage: "timer"
                    )
                    MetricTile(
                        title: "Rules",
                        value: "\(model.enabledWatchCount)",
                        caption: "Enabled watched targets",
                        systemImage: "eye"
                    )
                }

                VStack(alignment: .leading, spacing: 14) {
                    Text("Fast demo")
                        .font(.headline)
                    Text("Use the simulation button to show the full interruption loop even if Douyin is not installed on this Mac.")
                        .foregroundStyle(.secondary)
                    HStack {
                        Button {
                            model.simulateDouyinDrift()
                        } label: {
                            Label("Simulate Douyin drift", systemImage: "play.circle.fill")
                        }
                        .buttonStyle(.borderedProminent)

                        Button {
                            model.startFocusLock(minutes: model.demoMode ? 1 : 25)
                        } label: {
                            Label("Start Deep Work Lock", systemImage: "lock.shield.fill")
                        }
                    }
                }
                .padding()
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .padding(28)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Protect the pause before the feed.")
                .font(.largeTitle.weight(.semibold))
            Text("StillPoint watches only the apps you choose, gives purposeful use a grace window, and interrupts when a session starts to drift.")
                .foregroundStyle(.secondary)
                .font(.title3)
        }
    }
}

struct MetricTile: View {
    var title: String
    var value: String
    var caption: String
    var systemImage: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: systemImage)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title2.weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.65)
            Text(caption)
                .font(.callout)
                .foregroundStyle(.secondary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, minHeight: 132, alignment: .topLeading)
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

