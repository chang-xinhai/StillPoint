import SwiftUI

struct ContentView: View {
    @ObservedObject var model: AppModel
    @State private var selection: AppSection? = .dashboard

    var body: some View {
        ZStack {
            ControlCenterBackground()

            HStack(spacing: 16) {
                ControlCenterRail(selection: $selection)
                    .frame(width: 198)

                detail
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .padding(18)
        }
        .background(WindowMaterialConfigurator())
        .toolbar {
            ToolbarItemGroup {
                Toggle(isOn: $model.monitoringEnabled) {
                    Label(model.monitoringEnabled ? "Watching" : "Paused", systemImage: model.monitoringEnabled ? "eye" : "eye.slash")
                }
                .toggleStyle(.button)
                .help(model.monitoringEnabled ? "Pause watching" : "Resume watching")

                Toggle(isOn: $model.demoMode) {
                    Label("Demo", systemImage: "bolt")
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

    @ViewBuilder
    private var detail: some View {
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
}

private struct ControlCenterRail: View {
    @Binding var selection: AppSection?

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                AppMark(size: 34)
                VStack(alignment: .leading, spacing: 1) {
                    Text("StillPoint")
                        .font(.headline)
                    Text("menu bar guardian")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.bottom, 6)

            VStack(spacing: 6) {
                ForEach(AppSection.allCases) { section in
                    RailButton(
                        section: section,
                        isSelected: (selection ?? .dashboard) == section
                    ) {
                        selection = section
                    }
                }
            }

            Spacer()

            Text("Close this window anytime. StillPoint keeps watching from the menu bar.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .background {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(.regularMaterial)
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(nsColor: .controlBackgroundColor).opacity(0.62))
        }
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(.primary.opacity(0.08), lineWidth: 1)
        }
    }
}

private struct RailButton: View {
    var section: AppSection
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: section.systemImage)
                    .frame(width: 18)
                VStack(alignment: .leading, spacing: 1) {
                    Text(section.title)
                        .font(.callout.weight(.semibold))
                    Text(section.detail)
                        .font(.caption)
                        .foregroundStyle(isSelected ? .white.opacity(0.74) : .secondary)
                }
                Spacer()
            }
            .foregroundStyle(isSelected ? .white : .primary)
            .padding(.horizontal, 11)
            .padding(.vertical, 10)
            .background {
                if isSelected {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(.blue.gradient)
                        .shadow(color: .blue.opacity(0.22), radius: 14, x: 0, y: 8)
                } else {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(.white.opacity(0.001))
                }
            }
        }
        .buttonStyle(.plain)
    }
}

private struct ControlCenterBackground: View {
    var body: some View {
        ZStack {
            Color(nsColor: .windowBackgroundColor)

            LinearGradient(
                colors: [
                    Color(nsColor: .textBackgroundColor).opacity(0.96),
                    Color(nsColor: .controlBackgroundColor).opacity(0.92),
                    Color(nsColor: .windowBackgroundColor).opacity(0.98)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            RadialGradient(
                colors: [
                    Color.blue.opacity(0.08),
                    Color.clear
                ],
                center: .topTrailing,
                startRadius: 80,
                endRadius: 620
            )

            RadialGradient(
                colors: [
                    Color.green.opacity(0.035),
                    Color.clear
                ],
                center: .bottomLeading,
                startRadius: 60,
                endRadius: 520
            )
        }
        .ignoresSafeArea()
    }
}
