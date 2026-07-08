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
                    eyebrow: "Targets",
                    title: "Watch List",
                    subtitle: "Explicit high-risk feeds only. Work tools stay out of the net by default."
                ) {
                    Button {
                        isAddingTarget = true
                    } label: {
                        Label("Add target", systemImage: "plus")
                    }
                    .buttonStyle(.borderedProminent)
                    .keyboardShortcut("n", modifiers: [.command])
                }

                PlainPanel {
                    VStack(spacing: 0) {
                        HStack {
                            SectionKicker("Explicit targets", systemImage: "eye")
                            Spacer()
                            Text("\(model.enabledWatchCount) enabled")
                                .font(.caption.monospacedDigit())
                                .foregroundStyle(.secondary)
                        }
                        .padding(.bottom, 10)

                        ForEach($model.watchedApps) { $app in
                            WatchTargetRow(app: $app) {
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
                            Text("StillPoint only gates enabled targets. Add work apps manually only when you truly want them blocked.")
                                .font(.callout)
                                .foregroundStyle(.secondary)
                            Spacer()
                            Button("Restore defaults") {
                                model.restoreDefaultWatchedApps()
                            }
                            .buttonStyle(.link)
                        }
                        .padding(.top, 14)
                    }
                }
            }
            .frame(maxWidth: 860, alignment: .leading)
            .padding(.horizontal, 32)
            .padding(.vertical, 28)
        }
        .sheet(isPresented: $isAddingTarget) {
            AddWatchedAppSheet(model: model)
        }
    }
}

private struct WatchTargetRow: View {
    @Binding var app: WatchedApp
    var remove: () -> Void

    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            Image(systemName: app.isEnabled ? "checkmark.circle.fill" : "circle")
                .font(.title3)
                .foregroundStyle(app.isEnabled ? .green : .secondary)
                .frame(width: 24)

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
            }

            Spacer()

            Toggle("", isOn: $app.isEnabled)
                .labelsHidden()
                .toggleStyle(.switch)

            Button(role: .destructive) {
                remove()
            } label: {
                Image(systemName: "trash")
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)
            .help("Remove target")
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
        .background(.regularMaterial)
        .onAppear {
            refreshCandidates()
        }
    }

    private var sheetHeader: some View {
        HStack(alignment: .center, spacing: 12) {
            IconRoundel(systemImage: "plus", tint: .blue)
            VStack(alignment: .leading, spacing: 2) {
                Text("Add Watched App")
                    .font(.title3.weight(.semibold))
                Text("Pick only apps that reliably pull you into a feed.")
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
            .help("Close")
        }
        .padding(20)
    }

    @ViewBuilder
    private var frontmostSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionKicker("Last external app", systemImage: "scope")

            if let app = model.lastExternalAppForAdding {
                CandidateRow(
                    candidate: app,
                    isAlreadyWatched: model.isAlreadyWatched(app),
                    actionTitle: model.isAlreadyWatched(app) ? "Added" : "Add"
                ) {
                    model.addWatchedApp(app)
                    dismiss()
                }
            } else {
                EmptyHintRow(
                    systemImage: "rectangle.dashed",
                    title: "No external app captured yet",
                    subtitle: "Open the app you want to watch once, then return here."
                )
            }
        }
    }

    private var runningAppsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                SectionKicker("Running apps", systemImage: "list.bullet.rectangle")
                Spacer()
                Button {
                    refreshCandidates()
                } label: {
                    Label("Refresh", systemImage: "arrow.clockwise")
                }
                .labelStyle(.iconOnly)
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
                .help("Refresh running apps")
            }

            TextField("Search app name or bundle id", text: $searchText)
                .textFieldStyle(.roundedBorder)

            ScrollView {
                LazyVStack(spacing: 0) {
                    if filteredCandidates.isEmpty {
                        EmptyHintRow(
                            systemImage: "magnifyingglass",
                            title: "No matching running apps",
                            subtitle: "Launch the app first, or choose an .app from Applications."
                        )
                        .padding(.vertical, 18)
                    } else {
                        ForEach(filteredCandidates) { candidate in
                            CandidateRow(
                                candidate: candidate,
                                isAlreadyWatched: model.isAlreadyWatched(candidate),
                                actionTitle: model.isAlreadyWatched(candidate) ? "Added" : "Add"
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
                Text("Choose from Applications")
                    .font(.callout.weight(.medium))
                Text("Use this when the app is installed but not currently running.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button {
                if model.addApplicationFromPanel() {
                    dismiss()
                }
            } label: {
                Label("Choose .app", systemImage: "plus")
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
                        Text("Frontmost")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(.cyan)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(.cyan.opacity(0.11), in: Capsule())
                    }
                }

                Text(candidate.bundleIdentifier.isEmpty ? "No bundle identifier" : candidate.bundleIdentifier)
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
