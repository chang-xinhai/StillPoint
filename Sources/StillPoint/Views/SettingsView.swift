import SwiftUI

struct SettingsView: View {
    @ObservedObject var model: AppModel

    var body: some View {
        Form {
            Section("Monitoring") {
                Toggle("Enable monitoring", isOn: $model.monitoringEnabled)
                Toggle("Demo mode", isOn: $model.demoMode)
            }

            Section("Thresholds") {
                LabeledContent("Normal") {
                    Text(model.demoMode ? "8s demo" : "90s")
                        .foregroundStyle(.secondary)
                }
                LabeledContent("Lock") {
                    Text(model.demoMode ? "4s demo" : "10s")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .formStyle(.grouped)
    }
}

