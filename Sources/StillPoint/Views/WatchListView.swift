import AppKit
import StillPointCore
import SwiftUI

struct WatchListView: View {
    @ObservedObject var model: AppModel
    @State private var isAddingTarget = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                WorkspaceHeader(
                    eyebrow: model.t("Chosen targets", "已选目标"),
                    title: model.t("Watch less, on purpose.", "只监控真正需要的。"),
                    subtitle: model.t(
                        "Explicit high-risk feeds only. Work tools stay out of the net by default.",
                        "只监控明确高风险的信息流。工作工具默认不进入拦截网。"
                    )
                ) {
                    Button {
                        isAddingTarget = true
                    } label: {
                        Label(model.t("Add target", "添加目标"), systemImage: "plus")
                    }
                    .buttonStyle(.borderedProminent)
                    .keyboardShortcut("n", modifiers: [.command])
                }

                PlainPanel {
                    VStack(spacing: 0) {
                        HStack {
                            SectionKicker(model.t("Explicit targets", "明确目标"), systemImage: "eye")
                            Spacer()
                            Text(model.t("\(model.enabledWatchCount) enabled", "已启用 \(model.enabledWatchCount) 个"))
                                .font(.caption.monospacedDigit())
                                .foregroundStyle(.secondary)
                        }
                        .padding(.bottom, 10)

                        ForEach($model.watchedApps) { $app in
                            WatchTargetRow(app: $app, language: model.language) {
                                model.removeWatchedApp(app)
                            }
                            if app.id != model.watchedApps.last?.id {
                                HairlineDivider()
                            }
                        }

                        HairlineDivider()
                            .padding(.top, 4)

                        HStack(spacing: 10) {
                            Image(systemName: "info.circle")
                                .foregroundStyle(.secondary)
                            Text(model.t(
                                "StillPoint only gates enabled targets. Add work apps manually only when you truly want them blocked.",
                                "StillPoint 只拦截已启用目标。只有当你真的想限制某个工作应用时，才手动添加它。"
                            ))
                                .font(.callout)
                                .foregroundStyle(.secondary)
                            Spacer()
                            Button(model.t("Restore defaults", "恢复默认")) {
                                model.restoreDefaultWatchedApps()
                            }
                            .buttonStyle(.link)
                        }
                        .padding(.top, 14)
                    }
                }
            }
            .frame(maxWidth: 900, alignment: .leading)
            .padding(.horizontal, 34)
            .padding(.top, 30)
            .padding(.bottom, 42)
        }
        .sheet(isPresented: $isAddingTarget) {
            AddWatchedAppSheet(model: model)
        }
    }
}

private struct WatchTargetRow: View {
    @Binding var app: WatchedApp
    var language: AppLanguage
    var remove: () -> Void

    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            IconRoundel(
                systemImage: app.isEnabled ? "eye.fill" : "eye.slash",
                tint: app.isEnabled ? StillPointPalette.accent : .secondary
            )

            VStack(alignment: .leading, spacing: 4) {
                Text(app.displayName)
                    .font(.headline)
                    .lineLimit(1)

                Text(app.detail)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                Text(app.matchTerms.joined(separator: "  /  "))
                    .font(.caption.monospaced())
                    .foregroundStyle(.tertiary)
                    .lineLimit(1)

                HStack(spacing: 10) {
                    Text(language.text("Gate", "阈值"))
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)
                    Slider(
                        value: $app.gateSeconds,
                        in: WatchedApp.minimumGateSeconds...WatchedApp.maximumGateSeconds,
                        step: WatchedApp.gateStepSeconds
                    )
                    .frame(maxWidth: 220)
                    Text(app.gateSeconds.shortDurationString)
                        .font(.caption.monospacedDigit().weight(.semibold))
                        .foregroundStyle(.secondary)
                        .frame(width: 48, alignment: .trailing)
                }
            }

            Spacer()

            Toggle("", isOn: $app.isEnabled)
                .labelsHidden()
                .toggleStyle(.switch)
                .tint(StillPointPalette.accent)
                .help(app.isEnabled ? language.text("Pause this target", "暂停此目标") : language.text("Watch this target", "监控此目标"))

            Button(role: .destructive) {
                remove()
            } label: {
                Image(systemName: "trash")
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)
            .help(language.text("Remove target", "移除目标"))
        }
        .padding(.vertical, 13)
    }
}

private struct AddWatchedAppSheet: View {
    @ObservedObject var model: AppModel
    @Environment(\.dismiss) private var dismiss
    @State private var candidates: [RunningAppCandidate] = []
    @State private var searchText = ""

    private var filteredCandidates: [RunningAppCandidate] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return candidates }

        return candidates.filter { candidate in
            candidate.displayName.localizedCaseInsensitiveContains(query)
                || candidate.bundleIdentifier.localizedCaseInsensitiveContains(query)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            sheetHeader

            HairlineDivider()

            VStack(alignment: .leading, spacing: 16) {
                frontmostSection
                runningAppsSection
                chooseAppSection
            }
            .padding(20)
        }
        .frame(width: 560, height: 620)
        .background(.ultraThickMaterial)
        .onAppear {
            refreshCandidates()
        }
    }

    private var sheetHeader: some View {
        HStack(alignment: .center, spacing: 12) {
            IconRoundel(systemImage: "plus", tint: .blue)
            VStack(alignment: .leading, spacing: 2) {
                Text(model.t("Add Watched App", "添加监控应用"))
                    .font(.title3.weight(.semibold))
                Text(model.t("Pick only apps that reliably pull you into a feed.", "只选择那些确实容易把你拉进信息流的应用。"))
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)
            .help(model.t("Close", "关闭"))
        }
        .padding(20)
    }

    @ViewBuilder
    private var frontmostSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionKicker(model.t("Last external app", "最近外部应用"), systemImage: "scope")

            if let app = model.lastExternalAppForAdding {
                CandidateRow(
                    candidate: app,
                    isAlreadyWatched: model.isAlreadyWatched(app),
                    actionTitle: model.isAlreadyWatched(app) ? model.t("Added", "已添加") : model.t("Add", "添加"),
                    language: model.language
                ) {
                    model.addWatchedApp(app)
                    dismiss()
                }
            } else {
                EmptyHintRow(
                    systemImage: "rectangle.dashed",
                    title: model.t("No external app captured yet", "还没有捕获到外部应用"),
                    subtitle: model.t("Open the app you want to watch once, then return here.", "先打开一次你想监控的应用，再回到这里。")
                )
            }
        }
    }

    private var runningAppsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                SectionKicker(model.t("Running apps", "运行中的应用"), systemImage: "list.bullet.rectangle")
                Spacer()
                Button {
                    refreshCandidates()
                } label: {
                    Label(model.t("Refresh", "刷新"), systemImage: "arrow.clockwise")
                }
                .labelStyle(.iconOnly)
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
                .help(model.t("Refresh running apps", "刷新运行中的应用"))
            }

            TextField(model.t("Search app name or bundle id", "搜索应用名或 bundle id"), text: $searchText)
                .textFieldStyle(.roundedBorder)

            ScrollView {
                LazyVStack(spacing: 0) {
                    if filteredCandidates.isEmpty {
                        EmptyHintRow(
                            systemImage: "magnifyingglass",
                            title: model.t("No matching running apps", "没有匹配的运行中应用"),
                            subtitle: model.t("Launch the app first, or choose an .app from Applications.", "先启动应用，或从 Applications 里选择 .app。")
                        )
                        .padding(.vertical, 18)
                    } else {
                        ForEach(filteredCandidates) { candidate in
                            CandidateRow(
                                candidate: candidate,
                                isAlreadyWatched: model.isAlreadyWatched(candidate),
                                actionTitle: model.isAlreadyWatched(candidate) ? model.t("Added", "已添加") : model.t("Add", "添加"),
                                language: model.language
                            ) {
                                model.addWatchedApp(candidate)
                                dismiss()
                            }

                            if candidate.id != filteredCandidates.last?.id {
                                HairlineDivider()
                            }
                        }
                    }
                }
            }
            .frame(minHeight: 220, maxHeight: 280)
            .background(Color(nsColor: .controlBackgroundColor).opacity(0.46), in: RoundedRectangle(cornerRadius: 9, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 9, style: .continuous)
                    .strokeBorder(.primary.opacity(0.07), lineWidth: 1)
            }
        }
    }

    private var chooseAppSection: some View {
        HStack(spacing: 12) {
            IconRoundel(systemImage: "folder", tint: .orange)
            VStack(alignment: .leading, spacing: 2) {
                Text(model.t("Choose from Applications", "从 Applications 选择"))
                    .font(.callout.weight(.medium))
                Text(model.t("Use this when the app is installed but not currently running.", "应用已安装但当前没有运行时，用这个入口。"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button {
                if model.addApplicationFromPanel() {
                    dismiss()
                }
            } label: {
                Label(model.t("Choose .app", "选择 .app"), systemImage: "plus")
            }
        }
        .padding(14)
        .background(Color(nsColor: .controlBackgroundColor).opacity(0.46), in: RoundedRectangle(cornerRadius: 9, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 9, style: .continuous)
                .strokeBorder(.primary.opacity(0.07), lineWidth: 1)
        }
    }

    private func refreshCandidates() {
        candidates = model.runningAppCandidates()
    }
}

private struct CandidateRow: View {
    var candidate: RunningAppCandidate
    var isAlreadyWatched: Bool
    var actionTitle: String
    var language: AppLanguage
    var add: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            CandidateIcon(bundleURL: candidate.bundleURL)

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(candidate.displayName)
                        .font(.callout.weight(.medium))
                        .lineLimit(1)
                    if candidate.isFrontmost {
                        Text(language.text("Frontmost", "最前台"))
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(StillPointPalette.accent)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(StillPointPalette.accent.opacity(0.10), in: Capsule())
                    }
                }

                Text(candidate.bundleIdentifier.isEmpty ? language.text("No bundle identifier", "无 bundle identifier") : candidate.bundleIdentifier)
                    .font(.caption.monospaced())
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            Button(actionTitle) {
                add()
            }
            .disabled(isAlreadyWatched)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
    }
}

private struct CandidateIcon: View {
    var bundleURL: URL?

    var body: some View {
        Group {
            if let bundleURL {
                Image(nsImage: NSWorkspace.shared.icon(forFile: bundleURL.path))
                    .resizable()
                    .scaledToFit()
            } else {
                Image(systemName: "app.dashed")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: 30, height: 30)
        .padding(5)
        .background(.primary.opacity(0.06), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

private struct EmptyHintRow: View {
    var systemImage: String
    var title: String
    var subtitle: String

    var body: some View {
        HStack(spacing: 12) {
            IconRoundel(systemImage: systemImage, tint: .gray)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.callout.weight(.medium))
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
        }
        .padding(14)
    }
}
