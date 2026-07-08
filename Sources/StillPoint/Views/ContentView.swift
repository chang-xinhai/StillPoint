import SwiftUI

struct ContentView: View {
    @ObservedObject var model: AppModel
    @State private var selection: AppSection? = .dashboard

    var body: some View {
        NavigationSplitView {
            List(AppSection.allCases, selection: $selection) { section in
                HStack(spacing: 10) {
                    Image(systemName: section.systemImage)
                        .foregroundStyle(.secondary)
                        .frame(width: 16)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(section.title)
                            .lineLimit(1)
                        Text(section.detail)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
                .tag(section)
            }
            .listStyle(.sidebar)
            .navigationTitle("StillPoint")
            .navigationSplitViewColumnWidth(min: 210, ideal: 230)
        } detail: {
            switch selection ?? .dashboard {
            case .dashboard:
                DashboardView(model: model)
            case .rules:
                WatchListView(model: model)
            case .focusLock:
                FocusLockView(model: model)
            case .receipt:
                DailyReceiptView(model: model)
            }
        }
        .toolbar {
            ToolbarItemGroup {
                Toggle(isOn: $model.monitoringEnabled) {
                    Label(model.monitoringEnabled ? "Watching" : "Paused", systemImage: model.monitoringEnabled ? "eye" : "eye.slash")
                }
                .toggleStyle(.button)
                .help(model.monitoringEnabled ? "Pause watching" : "Resume watching")

                Toggle(isOn: $model.demoMode) {
                    Label("Demo mode", systemImage: "bolt")
                }
                .toggleStyle(.button)
                .help("Toggle demo thresholds")

                Button {
                    model.simulateDouyinDrift()
                } label: {
                    Label("Simulate", systemImage: "play.circle")
                }
                .help("Simulate a Douyin drift")
            }
        }
    }
}

