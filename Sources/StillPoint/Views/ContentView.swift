import SwiftUI

struct ContentView: View {
    @ObservedObject var model: AppModel
    @State private var selection: AppSection? = .dashboard
    @State private var inspectorPresented = true

    var body: some View {
        NavigationSplitView {
            ControlSidebar(model: model, selection: $selection)
                .navigationSplitViewColumnWidth(min: 210, ideal: 238, max: 280)
        } detail: {
            ZStack {
                ControlCenterBackground()
                detail
            }
            .inspector(isPresented: $inspectorPresented) {
                ControlInspector(model: model)
                    .inspectorColumnWidth(min: 260, ideal: 292, max: 340)
            }
        }
        .background(WindowMaterialConfigurator())
        .navigationTitle((selection ?? .dashboard).title(language: model.language))
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Button {
                    inspectorPresented.toggle()
                } label: {
                    Label(model.t("Inspector", "检查器"), systemImage: "sidebar.right")
                }
                .help(inspectorPresented ? model.t("Hide inspector", "隐藏检查器") : model.t("Show inspector", "显示检查器"))

                Toggle(isOn: $model.monitoringEnabled) {
                    Label(model.watchStateLabel, systemImage: model.monitoringEnabled ? "eye" : "eye.slash")
                }
                .toggleStyle(.button)
                .help(model.monitoringEnabled ? model.t("Pause watching", "暂停监控") : model.t("Resume watching", "继续监控"))

                SettingsLink {
                    Label(model.t("Settings", "设置"), systemImage: "gearshape")
                }
                .help(model.t("Open settings", "打开设置"))

                Button {
                    model.simulateDouyinDrift()
                } label: {
                    Label(model.t("Simulate", "模拟"), systemImage: "play.circle")
                }
                .help(model.t("Simulate a Douyin drift", "模拟一次抖音走神"))
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

private struct ControlSidebar: View {
    @ObservedObject var model: AppModel
    @Binding var selection: AppSection?

    var body: some View {
        List(selection: $selection) {
            Section(model.t("Control", "控制")) {
                ForEach(AppSection.allCases) { section in
                    SidebarRow(section: section, language: model.language)
                        .tag(section)
                }
            }

            Section(model.t("Watched", "监控中")) {
                ForEach(model.watchedApps.prefix(4)) { app in
                    HStack(spacing: 10) {
                        Image(systemName: app.isEnabled ? "checkmark.circle.fill" : "circle")
                            .font(.callout)
                            .foregroundStyle(app.isEnabled ? .green : .secondary)
                            .frame(width: 18)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(app.displayName)
                                .lineLimit(1)
                            Text(app.isEnabled ? model.t("Active target", "已启用") : model.t("Ignored", "已忽略"))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                    }
                }
            }
        }
        .listStyle(.sidebar)
        .navigationTitle("StillPoint")
        .safeAreaInset(edge: .bottom) {
            VStack(alignment: .leading, spacing: 12) {
                HairlineDivider()
                HStack(spacing: 10) {
                    AppMark(size: 30)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(model.monitoringEnabled ? model.t("Menu bar active", "菜单栏运行中") : model.t("Monitoring paused", "监控已暂停"))
                            .font(.callout.weight(.medium))
                            .lineLimit(1)
                        Text(model.t("Close the window anytime", "可以随时关闭窗口"))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.top, 8)
            .padding(.bottom, 12)
            .background(.bar)
        }
    }
}

private struct SidebarRow: View {
    var section: AppSection
    var language: AppLanguage

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: section.systemImage)
                .foregroundStyle(.secondary)
                .frame(width: 18)

            VStack(alignment: .leading, spacing: 2) {
                Text(section.title(language: language))
                    .lineLimit(1)
                Text(section.detail(language: language))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
    }
}

private struct ControlInspector: View {
    @ObservedObject var model: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 8) {
                    SectionKicker(model.t("Now", "当前"), systemImage: "waveform.path.ecg")
                    Text(model.activeAppName)
                        .font(.system(size: 24, weight: .semibold, design: .rounded))
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)
                    Text(model.activeBundleIdentifier.isEmpty ? model.t("Waiting for an explicit target", "等待明确目标") : model.activeBundleIdentifier)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)

                    ProgressLine(value: model.activeProgress, tint: model.focusLockActive ? .orange : .cyan, marker: 0.86)
                    HStack {
                        Text(model.activeElapsed.shortDurationString)
                        Spacer()
                        Text("\(model.t("gate", "阈值")) \(model.visibleTriggerThreshold.shortDurationString)")
                    }
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
                }

                HairlineDivider()

                VStack(alignment: .leading, spacing: 2) {
                    SectionKicker(model.t("Session", "会话"), systemImage: "chart.bar.xaxis")
                    DataRow(model.t("State", "状态"), value: model.watchStateLabel)
                    DataRow(model.t("Gate", "阈值"), value: model.visibleTriggerThreshold.shortDurationString)
                    DataRow(model.t("Targets", "目标"), value: "\(model.enabledWatchCount)")
                    DataRow(model.t("Saved", "保护"), value: model.dailySummary.protectedSeconds.shortDurationString)
                }

                HairlineDivider()

                VStack(alignment: .leading, spacing: 10) {
                    SectionKicker(model.t("Actions", "操作"), systemImage: "bolt")
                    Button {
                        model.simulateDouyinDrift()
                    } label: {
                        Label(model.t("Simulate drift", "模拟走神"), systemImage: "play.fill")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .buttonStyle(.borderedProminent)

                    Button {
                        if model.focusLockActive {
                            model.stopFocusLock()
                        } else {
                            model.startFocusLock(minutes: 25)
                        }
                    } label: {
                        Label(model.focusLockActive ? model.t("Stop work lock", "停止专注锁") : model.t("Start work lock", "开启专注锁"), systemImage: model.focusLockActive ? "lock.open" : "lock.shield")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }

                HairlineDivider()

                Text(model.statusMessage)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(18)
        }
        .background(.regularMaterial)
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
