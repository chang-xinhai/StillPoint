import SwiftUI

struct SettingsView: View {
    @ObservedObject var model: AppModel

    var body: some View {
        Form {
            Toggle("Enable monitoring", isOn: $model.monitoringEnabled)
            Toggle("Demo mode", isOn: $model.demoMode)
            LabeledContent("Normal threshold") {
                Text(model.demoMode ? "8s" : "90s")
            }
            LabeledContent("Lock threshold") {
                Text(model.demoMode ? "4s" : "10s")
            }
        }
    }
}

