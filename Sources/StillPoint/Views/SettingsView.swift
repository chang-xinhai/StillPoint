import StillPointCore
import SwiftUI

struct SettingsView: View {
    @ObservedObject var model: AppModel

    var body: some View {
        Form {
            Section(model.t("Language", "语言")) {
                Picker(model.t("App language", "应用语言"), selection: $model.language) {
                    ForEach(AppLanguage.allCases) { language in
                        Text(language.displayName)
                            .tag(language)
                    }
                }
                .pickerStyle(.segmented)
            }

            Section(model.t("Monitoring", "监控")) {
                Toggle(model.t("Enable monitoring", "启用监控"), isOn: $model.monitoringEnabled)
            }

            Section(model.t("Gate timing", "阈值时间")) {
                LabeledContent(model.t("Default for new targets", "新目标默认值")) {
                    Text(WatchedApp.defaultGateSeconds.shortDurationString)
                        .foregroundStyle(.secondary)
                }
                LabeledContent(model.t("Per-app control", "逐应用控制")) {
                    Text(model.t("Adjust in Watch List", "在监控列表中调整"))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .formStyle(.grouped)
    }
}
