import AppKit
import Foundation
import StillPointCore
import UniformTypeIdentifiers

@MainActor
final class AppModel: ObservableObject {
    @Published var monitoringEnabled = true
    @Published var language: AppLanguage {
        didSet {
            userDefaults.set(language.rawValue, forKey: Self.languageKey)
        }
    }
    @Published var watchedApps: [WatchedApp] {
        didSet {
            saveWatchedApps()
        }
    }
    @Published var activeAppName = "Unknown"
    @Published var activeBundleIdentifier = ""
    @Published var activeElapsed: TimeInterval = 0
    @Published var activeGateSeconds: TimeInterval = WatchedApp.defaultGateSeconds
    @Published var focusLockUntil: Date?
    @Published var attentionEvents: [AttentionEvent] = []
    @Published var statusMessage = "Watching for unintentional drift."
    @Published var isInterventionPresented = false

    private var timer: Timer?
    private let userDefaults: UserDefaults
    private var activeKey: String?
    private var activeStartedAt: Date?
    private var lastAddableApp: RunningAppCandidate?
    private var purposePassUntilByKey: [String: Date] = [:]
    private var currentContext: InterventionContext?
    private var currentOffendingApp: NSRunningApplication?
    private let presenter = OverlayInterventionPresenter()
    private static let watchedAppsKey = "StillPoint.watchedApps.v1"
    private static let languageKey = "StillPoint.language.v1"
    private static let idleAppName = "No watched app"

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        self.language = Self.loadLanguage(from: userDefaults)
        self.watchedApps = Self.loadWatchedApps(from: userDefaults)
        activeAppName = Self.idleAppName
        statusMessage = language.text(
            "Choose a target or keep a watched app frontmost.",
            "选择一个目标，或把被监控应用放到最前。"
        )

        DispatchQueue.main.async { [weak self] in
            self?.startMonitoring()
        }
    }

    var focusLockActive: Bool {
        guard let focusLockUntil else { return false }
        return focusLockUntil > Date()
    }

    var focusLockRemaining: TimeInterval {
        guard let focusLockUntil else { return 0 }
        return max(0, focusLockUntil.timeIntervalSinceNow)
    }

    var enabledWatchCount: Int {
        watchedApps.filter(\.isEnabled).count
    }

    var dailySummary: DailyAttentionSummary {
        let today = attentionEvents.filter { Calendar.current.isDateInToday($0.date) }
        return today.reduce(into: DailyAttentionSummary()) { summary, event in
            summary.driftChecks += 1
            summary.protectedSeconds += event.protectedSeconds

            switch event.action {
            case .purposePass:
                summary.purposePasses += 1
            case .intentionalBreak:
                summary.intentionalBreaks += 1
            case .closeApp:
                summary.closedDrifts += 1
            case .startLock:
                summary.locksStarted += 1
            }
        }
    }

    var todayEvents: [AttentionEvent] {
        attentionEvents.filter { Calendar.current.isDateInToday($0.date) }
    }

    var visibleTriggerThreshold: TimeInterval {
        activeGateSeconds
    }

    var activeProgress: Double {
        guard visibleTriggerThreshold > 0 else { return 0 }
        return min(activeElapsed / visibleTriggerThreshold, 1)
    }

    var modeLabel: String {
        if focusLockActive {
            return t("Deep Work", "专注锁")
        }

        return t("Custom gates", "自定义阈值")
    }

    var watchStateLabel: String {
        monitoringEnabled ? t("Watching", "监控中") : t("Paused", "已暂停")
    }

    var barSystemImage: String {
        if focusLockActive {
            return "lock.shield.fill"
        }

        return monitoringEnabled ? "scope" : "pause.circle"
    }

    var barTitle: String {
        if focusLockActive {
            return "\(t("Lock", "锁定")) \(focusLockRemaining.shortDurationString)"
        }

        if activeElapsed > 0 {
            return "Still \(activeElapsed.shortDurationString)"
        }

        return monitoringEnabled ? "Still" : t("Paused", "暂停")
    }

    var lastExternalAppForAdding: RunningAppCandidate? {
        lastAddableApp
    }

    func t(_ english: String, _ chinese: String) -> String {
        language.text(english, chinese)
    }

    func startMonitoring() {
        guard timer == nil else { return }

        let timer = Timer(timeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.tick()
            }
        }
        RunLoop.main.add(timer, forMode: .common)
        self.timer = timer
        tick()
    }

    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
        resetActiveCandidate()
        statusMessage = t("Monitoring paused.", "监控已暂停。")
    }

    func runningAppCandidates() -> [RunningAppCandidate] {
        var seen = Set<String>()
        let foregroundApp = currentForegroundApplication()

        return NSWorkspace.shared.runningApplications.compactMap { app in
            guard app.activationPolicy == .regular else { return nil }
            guard let name = app.localizedName?.trimmingCharacters(in: .whitespacesAndNewlines), !name.isEmpty else {
                return nil
            }

            let bundleIdentifier = app.bundleIdentifier ?? ""
            guard !isControlApp(appName: name, bundleIdentifier: bundleIdentifier) else { return nil }

            let candidate = RunningAppCandidate(
                displayName: name,
                bundleIdentifier: bundleIdentifier,
                bundleURL: app.bundleURL,
                isFrontmost: app == foregroundApp
            )
            guard seen.insert(candidate.id).inserted else { return nil }

            return candidate
        }
        .sorted {
            $0.displayName.localizedCaseInsensitiveCompare($1.displayName) == .orderedAscending
        }
    }

    func isAlreadyWatched(_ candidate: RunningAppCandidate) -> Bool {
        indexOfWatchedTarget(applicationName: candidate.displayName, bundleIdentifier: candidate.bundleIdentifier) != nil
    }

    func addWatchedApp(_ candidate: RunningAppCandidate) {
        addWatchedApp(
            applicationName: candidate.displayName,
            bundleIdentifier: candidate.bundleIdentifier,
            detail: candidate.bundleIdentifier.isEmpty ? t("Added from running apps.", "从运行中应用添加。") : candidate.bundleIdentifier
        )
    }

    func addLastExternalApp() {
        guard let lastAddableApp else { return }
        addWatchedApp(lastAddableApp)
    }

    func addApplicationFromPanel() -> Bool {
        let panel = NSOpenPanel()
        panel.title = t("Choose an app to watch", "选择要监控的应用")
        panel.prompt = t("Add", "添加")
        panel.allowedContentTypes = [.applicationBundle]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true

        if let applicationsURL = FileManager.default.urls(for: .applicationDirectory, in: .localDomainMask).first {
            panel.directoryURL = applicationsURL
        }

        guard panel.runModal() == .OK, let url = panel.url else { return false }

        let bundle = Bundle(url: url)
        let displayName = bundle?.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
            ?? bundle?.object(forInfoDictionaryKey: "CFBundleName") as? String
            ?? url.deletingPathExtension().lastPathComponent
        let bundleIdentifier = bundle?.bundleIdentifier ?? ""

        addWatchedApp(
            applicationName: displayName,
            bundleIdentifier: bundleIdentifier,
            detail: bundleIdentifier.isEmpty ? url.lastPathComponent : bundleIdentifier
        )
        return true
    }

    func removeWatchedApp(_ app: WatchedApp) {
        watchedApps.removeAll { $0.id == app.id }
        if watchedApps.isEmpty {
            resetActiveCandidate(clearDisplay: true)
        }
    }

    func restoreDefaultWatchedApps() {
        watchedApps = WatchedApp.defaults
        resetActiveCandidate(clearDisplay: true)
        statusMessage = t("Default watch list restored.", "已恢复默认监控列表。")
    }

    func startFocusLock(minutes: Int) {
        let duration = TimeInterval(minutes * 60)
        focusLockUntil = Date().addingTimeInterval(duration)
        attentionEvents.append(
            AttentionEvent(
                date: Date(),
                appName: "Deep Work Lock",
                action: .startLock,
                elapsedSeconds: 0,
                grantedSeconds: duration,
                protectedSeconds: duration,
                wasFocusLockActive: true
            )
        )
        statusMessage = t(
            "Deep Work Lock is active for \(duration.shortDurationString).",
            "专注锁已开启 \(duration.shortDurationString)。"
        )
    }

    func stopFocusLock() {
        focusLockUntil = nil
        statusMessage = t("Deep Work Lock stopped.", "专注锁已停止。")
    }

    func simulateDouyinDrift() {
        let threshold = watchedApps.first { $0.matches(appName: "Douyin", bundleIdentifier: "com.demo.douyin") }?.gateSeconds
            ?? WatchedApp.defaultGateSeconds
        activeAppName = "Douyin"
        activeBundleIdentifier = "com.demo.douyin"
        activeGateSeconds = threshold
        activeElapsed = threshold + 1
        activeKey = "simulation.douyin"
        activeStartedAt = Date().addingTimeInterval(-activeElapsed)

        let context = InterventionContext(
            appName: "Douyin",
            bundleIdentifier: "com.demo.douyin",
            elapsedSeconds: activeElapsed,
            isFocusLock: focusLockActive,
            triggerReason: focusLockActive
                ? t("Deep Work Lock is active.", "专注锁正在生效。")
                : t("App gate reached.", "应用阈值已到。")
        )
        presentIntervention(context: context, offendingApp: nil)
    }

    private func tick() {
        guard monitoringEnabled else {
            statusMessage = t("Monitoring paused.", "监控已暂停。")
            resetActiveCandidate()
            return
        }

        if let focusLockUntil, focusLockUntil <= Date() {
            self.focusLockUntil = nil
            statusMessage = t("Deep Work Lock finished.", "专注锁已结束。")
        }

        guard let app = currentForegroundApplication() else {
            resetActiveCandidate(clearDisplay: true)
            return
        }

        let appName = app.localizedName ?? "Unknown"
        let bundleIdentifier = app.bundleIdentifier ?? ""

        guard !isControlApp(appName: appName, bundleIdentifier: bundleIdentifier) else {
            resetActiveCandidate(clearDisplay: false)
            return
        }

        lastAddableApp = RunningAppCandidate(
            displayName: appName,
            bundleIdentifier: bundleIdentifier,
            bundleURL: app.bundleURL,
            isFrontmost: true
        )

        guard let watchedApp = watchedApps.first(where: { $0.matches(appName: appName, bundleIdentifier: bundleIdentifier) }) else {
            resetActiveCandidate(clearDisplay: true)
            statusMessage = t(
                "\(appName) is not watched. Add it from Watch List if this is a feed risk.",
                "\(appName) 暂未监控。如果它容易让你刷起来，可以在监控列表里添加。"
            )
            return
        }

        activeAppName = appName
        activeBundleIdentifier = bundleIdentifier
        activeGateSeconds = watchedApp.gateSeconds

        let key = bundleIdentifier.isEmpty ? appName : bundleIdentifier
        if activeKey != key {
            activeKey = key
            activeStartedAt = Date()
            activeElapsed = 0
            currentOffendingApp = app
        }

        let startedAt = activeStartedAt ?? Date()
        activeElapsed = Date().timeIntervalSince(startedAt)

        if let passUntil = purposePassUntilByKey[key], passUntil > Date() {
            statusMessage = t(
                "\(appName) is covered by a purpose pass for \(passUntil.timeIntervalSinceNow.shortDurationString).",
                "\(appName) 仍处于查找通行中，剩余 \(passUntil.timeIntervalSinceNow.shortDurationString)。"
            )
            return
        }

        let threshold = watchedApp.gateSeconds
        statusMessage = t(
            "\(appName) watched for \(activeElapsed.shortDurationString). Gate: \(threshold.shortDurationString).",
            "\(appName) 已持续 \(activeElapsed.shortDurationString)，阈值 \(threshold.shortDurationString)。"
        )

        guard activeElapsed >= threshold, !isInterventionPresented else { return }

        let context = InterventionContext(
            appName: appName,
            bundleIdentifier: bundleIdentifier,
            elapsedSeconds: activeElapsed,
            isFocusLock: focusLockActive,
            triggerReason: focusLockActive
                ? t("Deep Work Lock is active.", "专注锁正在生效。")
                : t("App gate reached.", "应用阈值已到。")
        )
        presentIntervention(context: context, offendingApp: app)
    }

    private func currentForegroundApplication() -> NSRunningApplication? {
        guard let frontmostApp = NSWorkspace.shared.frontmostApplication else { return nil }
        let frontmostName = frontmostApp.localizedName ?? ""
        let frontmostBundleIdentifier = frontmostApp.bundleIdentifier ?? ""

        if isControlApp(appName: frontmostName, bundleIdentifier: frontmostBundleIdentifier) {
            return frontmostApp
        }

        let visiblePIDs = visibleWindowOwnerPIDsInFrontToBackOrder()
        if visiblePIDs.contains(frontmostApp.processIdentifier) {
            return frontmostApp
        }

        for pid in visiblePIDs {
            guard let app = NSRunningApplication(processIdentifier: pid),
                  app.activationPolicy == .regular
            else { continue }

            return app
        }

        return nil
    }

    private func visibleWindowOwnerPIDsInFrontToBackOrder() -> [pid_t] {
        let options: CGWindowListOption = [.optionOnScreenOnly, .excludeDesktopElements]
        guard let windowInfos = CGWindowListCopyWindowInfo(options, kCGNullWindowID) as? [[String: Any]] else {
            return []
        }

        var seen = Set<pid_t>()
        return windowInfos.compactMap { info in
            guard let layer = info[kCGWindowLayer as String] as? NSNumber, layer.intValue == 0,
                  let ownerPID = info[kCGWindowOwnerPID as String] as? NSNumber,
                  let bounds = info[kCGWindowBounds as String] as? NSDictionary,
                  let rect = CGRect(dictionaryRepresentation: bounds),
                  rect.width > 24,
                  rect.height > 24
            else {
                return nil
            }

            let pid = pid_t(ownerPID.int32Value)
            guard seen.insert(pid).inserted else { return nil }

            return pid
        }
    }

    private func presentIntervention(context: InterventionContext, offendingApp: NSRunningApplication?) {
        currentContext = context
        currentOffendingApp = offendingApp
        isInterventionPresented = true
        presenter.show(context: context) { [weak self] action in
            Task { @MainActor in
                self?.handleIntervention(action)
            }
        }
    }

    private func handleIntervention(_ action: InterventionAction) {
        guard let context = currentContext else { return }

        presenter.dismiss()
        isInterventionPresented = false

        let key = activeKey ?? context.bundleIdentifier
        let now = Date()
        var grantedSeconds: TimeInterval = 0
        var protectedSeconds: TimeInterval = 0

        switch action {
        case .purposePass:
            grantedSeconds = max(activeGateSeconds, 2 * 60)
            purposePassUntilByKey[key] = now.addingTimeInterval(grantedSeconds)
            statusMessage = t(
                "Purpose pass granted for \(context.appName): \(grantedSeconds.shortDurationString).",
                "\(context.appName) 已获得查找通行：\(grantedSeconds.shortDurationString)。"
            )
        case .intentionalBreak:
            grantedSeconds = max(activeGateSeconds, 5 * 60)
            purposePassUntilByKey[key] = now.addingTimeInterval(grantedSeconds)
            statusMessage = t(
                "Intentional break granted for \(context.appName): \(grantedSeconds.shortDurationString).",
                "\(context.appName) 已获得有意休息：\(grantedSeconds.shortDurationString)。"
            )
        case .closeApp:
            protectedSeconds = max(activeGateSeconds, 10 * 60)
            hideOffendingApp()
            statusMessage = t("Closed a drift in \(context.appName).", "已中断 \(context.appName) 的走神。")
        case .startLock:
            grantedSeconds = 25 * 60
            protectedSeconds = grantedSeconds
            focusLockUntil = now.addingTimeInterval(grantedSeconds)
            hideOffendingApp()
            statusMessage = t(
                "Deep Work Lock started for \(grantedSeconds.shortDurationString).",
                "专注锁已开启 \(grantedSeconds.shortDurationString)。"
            )
        }

        attentionEvents.append(
            AttentionEvent(
                date: now,
                appName: context.appName,
                action: action,
                elapsedSeconds: context.elapsedSeconds,
                grantedSeconds: grantedSeconds,
                protectedSeconds: protectedSeconds,
                wasFocusLockActive: context.isFocusLock
            )
        )

        activeStartedAt = Date()
        activeElapsed = 0
        currentContext = nil
    }

    private func hideOffendingApp() {
        guard let currentOffendingApp else {
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        if !isStillPoint(
            appName: currentOffendingApp.localizedName ?? "",
            bundleIdentifier: currentOffendingApp.bundleIdentifier ?? ""
        ) {
            _ = currentOffendingApp.hide()
        }
        NSApp.activate(ignoringOtherApps: true)
    }

    private func resetActiveCandidate(clearDisplay: Bool = false) {
        activeKey = nil
        activeStartedAt = nil
        activeElapsed = 0
        activeGateSeconds = WatchedApp.defaultGateSeconds
        currentOffendingApp = nil

        if clearDisplay {
            activeAppName = Self.idleAppName
            activeBundleIdentifier = ""
        }
    }

    private func isStillPoint(appName: String, bundleIdentifier: String) -> Bool {
        appName == "StillPoint" || bundleIdentifier == "com.changxinhai.StillPoint"
    }

    private func isControlApp(appName: String, bundleIdentifier: String) -> Bool {
        if isStillPoint(appName: appName, bundleIdentifier: bundleIdentifier) {
            return true
        }

        let ignoredBundleIdentifiers: Set<String> = [
            "com.apple.finder",
            "com.apple.systempreferences",
            "com.apple.SystemSettings",
            "com.apple.controlcenter",
            "com.jordanbaird.Ice"
        ]
        let ignoredNames: Set<String> = [
            "Finder",
            "System Settings",
            "System Preferences",
            "Control Center",
            "Ice"
        ]

        return ignoredBundleIdentifiers.contains(bundleIdentifier)
            || ignoredNames.contains(appName)
    }

    private func addWatchedApp(applicationName: String, bundleIdentifier: String, detail: String) {
        if let index = indexOfWatchedTarget(applicationName: applicationName, bundleIdentifier: bundleIdentifier) {
            watchedApps[index].isEnabled = true
            statusMessage = t(
                "\(watchedApps[index].displayName) is already on the watch list.",
                "\(watchedApps[index].displayName) 已经在监控列表中。"
            )
            return
        }

        let app = WatchedApp(
            applicationName: applicationName,
            bundleIdentifier: bundleIdentifier,
            detail: detail,
            isEnabled: true
        )
        watchedApps.append(app)
        statusMessage = t(
            "\(app.displayName) added to Watch List.",
            "\(app.displayName) 已添加到监控列表。"
        )
    }

    private func indexOfWatchedTarget(applicationName: String, bundleIdentifier: String) -> Int? {
        let incomingTerms = Set(
            WatchedApp.matchTerms(applicationName: applicationName, bundleIdentifier: bundleIdentifier)
                .map { $0.lowercased() }
        )
        guard !incomingTerms.isEmpty else { return nil }

        return watchedApps.firstIndex { app in
            let existingTerms = Set(app.matchTerms.map { $0.lowercased() })
            return !existingTerms.isDisjoint(with: incomingTerms)
        }
    }

    private static func loadWatchedApps(from userDefaults: UserDefaults) -> [WatchedApp] {
        guard let data = userDefaults.data(forKey: watchedAppsKey),
              let decoded = try? JSONDecoder().decode([WatchedApp].self, from: data),
              !decoded.isEmpty
        else {
            return WatchedApp.defaults
        }

        return decoded
    }

    private static func loadLanguage(from userDefaults: UserDefaults) -> AppLanguage {
        guard let rawValue = userDefaults.string(forKey: languageKey),
              let language = AppLanguage(rawValue: rawValue)
        else {
            return .chinese
        }

        return language
    }

    private func saveWatchedApps() {
        guard let data = try? JSONEncoder().encode(watchedApps) else { return }
        userDefaults.set(data, forKey: Self.watchedAppsKey)
    }
}
