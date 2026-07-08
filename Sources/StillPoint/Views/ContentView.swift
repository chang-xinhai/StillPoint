import SwiftUI

struct ContentView: View {
    @ObservedObject var model: AppModel
    @State private var selection: AppSection? = .dashboard

    var body: some View {
        NavigationSplitView {
            List(AppSection.allCases, selection: $selection) { section in
                Label(section.title, systemImage: section.systemImage)
                    .tag(section)
            }
            .navigationTitle("StillPoint")
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
                Toggle("Demo", isOn: $model.demoMode)
                    .toggleStyle(.switch)
                Toggle("Watch", isOn: $model.monitoringEnabled)
                    .toggleStyle(.switch)
                Button {
                    model.simulateDouyinDrift()
                } label: {
                    Label("Simulate Drift", systemImage: "play.circle")
                }
            }
        }
    }
}

