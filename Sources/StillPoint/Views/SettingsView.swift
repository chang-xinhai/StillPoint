import StillPointCore
import SwiftUI

struct SettingsView: View {
    @ObservedObject var model: AppModel

    var body: some View {
        Form {
            Section {
                Picker(model.t("Language", "语言"), selection: $model.language) {
                    ForEach(AppLanguage.allCases) { language in
                        Text(language.displayName)
                            .tag(language)
                    }
                }
                .pickerStyle(.segmented)
            } header: {
                Label(model.t("Appearance", "外观"), systemImage: "textformat")
            }

            Section {
                Toggle(isOn: $model.monitoringEnabled) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(model.t("Watch chosen targets", "监控已选目标"))
                        Text(model.t(
                            "Pause this without quitting the menu bar app.",
                            "无需退出菜单栏应用，也可以暂停监控。"
                        ))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                }
                .tint(StillPointPalette.accent)

                LabeledContent(model.t("Default checkpoint", "默认检查点")) {
                    Text(WatchedApp.defaultGateSeconds.shortDurationString)
                        .monospacedDigit()
                        .foregroundStyle(.secondary)
                }

                LabeledContent(model.t("Per-app timing", "逐应用时间")) {
                    Text(model.t("Watch List", "监控列表"))
                        .foregroundStyle(.secondary)
                }
            } header: {
                Label(model.t("Attention gates", "注意力检查"), systemImage: "scope")
            } footer: {
                Text(model.t(
                    "Deep Work always uses a three-second checkpoint while active.",
                    "专注锁生效时始终使用三秒检查点。"
                ))
            }

            Section {
                LabeledContent(model.t("Storage", "存储")) {
                    Label(model.t("On this Mac", "仅此 Mac"), systemImage: "checkmark.circle.fill")
                        .foregroundStyle(StillPointPalette.accent)
                }
                LabeledContent(model.t("Network", "网络")) {
                    Text(model.t("Not used", "未使用"))
                        .foregroundStyle(.secondary)
                }
            } header: {
                Label(model.t("Privacy", "隐私"), systemImage: "hand.raised")
            }
        }
        .formStyle(.grouped)
        .tint(StillPointPalette.accent)
    }
}
