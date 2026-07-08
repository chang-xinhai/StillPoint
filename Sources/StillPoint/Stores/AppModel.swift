import AppKit
import Foundation
import StillPointCore

@MainActor
final class AppModel: ObservableObject {
    @Published var monitoringEnabled = true
    @Published var demoMode = true
    @Published var watchedApps = WatchedApp.defaults
    @Published var activeAppName = "Unknown"
    @Published var activeBundleIdentifier = ""
    @Published var activeElapsed: TimeInterval = 0
    @Published var focusLockUntil: Date?
    @Published var attentionEvents: [AttentionEvent] = []
    @Published var statusMessage = "Watching for unintentional drift."
    @Published var isInterventionPresented = false

    private var timer: Timer?
    private var activeKey: String?
    private var activeStartedAt: Date?
    private var purposePassUntilByKey: [String: Date] = [:]
    private var currentContext: InterventionContext?
    private var currentOffendingApp: NSRunningApplication?
    private let presenter = OverlayInterventionPresenter()

    init() {
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
        triggerThreshold()
    }

    var activeProgress: Double {
        guard visibleTriggerThreshold > 0 else { return 0 }
        return min(activeElapsed / visibleTriggerThreshold, 1)
    }

    var modeLabel: String {
        if focusLockActive {
            return "Deep Work"
        }

        return demoMode ? "Demo" : "Normal"
    }

    var watchStateLabel: String {
        monitoringEnabled ? "Watching" : "Paused"
    }

    var barSystemImage: String {
        if focusLockActive {
            return "lock.shield.fill"
        }

        return monitoringEnabled ? "scope" : "pause.circle"
    }

    var barTitle: String {
        if focusLockActive {
            return "Lock \(focusLockRemaining.shortDurationString)"
        }

        if activeElapsed > 0 {
            return "Still \(activeElapsed.shortDurationString)"
        }

        return monitoringEnabled ? "Still" : "Paused"
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
        statusMessage = "Monitoring paused."
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
        statusMessage = "Deep Work Lock is active for \(duration.shortDurationString)."
    }

    func stopFocusLock() {
        focusLockUntil = nil
        statusMessage = "Deep Work Lock stopped."
    }

    func simulateDouyinDrift() {
        let threshold = triggerThreshold()
        activeAppName = "Douyin"
        activeBundleIdentifier = "com.demo.douyin"
        activeElapsed = threshold + 1
        activeKey = "simulation.douyin"
        activeStartedAt = Date().addingTimeInterval(-activeElapsed)

        let context = InterventionContext(
            appName: "Douyin",
            bundleIdentifier: "com.demo.douyin",
            elapsedSeconds: activeElapsed,
            isFocusLock: focusLockActive,
            triggerReason: focusLockActive ? "Deep Work Lock is active." : "Demo drift threshold reached."
        )
        presentIntervention(context: context, offendingApp: nil)
    }

    private func tick() {
        guard monitoringEnabled else {
            statusMessage = "Monitoring paused."
            resetActiveCandidate()
            return
        }

        if let focusLockUntil, focusLockUntil <= Date() {
            self.focusLockUntil = nil
            statusMessage = "Deep Work Lock finished."
        }

        guard let app = NSWorkspace.shared.frontmostApplication else {
            resetActiveCandidate()
            return
        }

        let appName = app.localizedName ?? "Unknown"
        let bundleIdentifier = app.bundleIdentifier ?? ""
        activeAppName = appName
        activeBundleIdentifier = bundleIdentifier

        guard !isStillPoint(appName: appName, bundleIdentifier: bundleIdentifier) else {
            resetActiveCandidate()
            return
        }

        guard watchedApps.contains(where: { $0.matches(appName: appName, bundleIdentifier: bundleIdentifier) }) else {
            resetActiveCandidate()
            return
        }

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
            statusMessage = "\(appName) is covered by a purpose pass for \(passUntil.timeIntervalSinceNow.shortDurationString)."
            return
        }

        let threshold = triggerThreshold()
        statusMessage = "\(appName) watched for \(activeElapsed.shortDurationString). Threshold: \(threshold.shortDurationString)."

        guard activeElapsed >= threshold, !isInterventionPresented else { return }

        let context = InterventionContext(
            appName: appName,
            bundleIdentifier: bundleIdentifier,
            elapsedSeconds: activeElapsed,
            isFocusLock: focusLockActive,
            triggerReason: focusLockActive ? "Deep Work Lock is active." : "Grace window ended."
        )
        presentIntervention(context: context, offendingApp: app)
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
            grantedSeconds = demoMode ? 20 : 180
            purposePassUntilByKey[key] = now.addingTimeInterval(grantedSeconds)
            statusMessage = "Purpose pass granted for \(context.appName): \(grantedSeconds.shortDurationString)."
        case .intentionalBreak:
            grantedSeconds = demoMode ? 30 : 300
            purposePassUntilByKey[key] = now.addingTimeInterval(grantedSeconds)
            statusMessage = "Intentional break granted for \(context.appName): \(grantedSeconds.shortDurationString)."
        case .closeApp:
            protectedSeconds = demoMode ? 120 : 600
            hideOffendingApp()
            statusMessage = "Closed a drift in \(context.appName)."
        case .startLock:
            grantedSeconds = demoMode ? 60 : 25 * 60
            protectedSeconds = grantedSeconds
            focusLockUntil = now.addingTimeInterval(grantedSeconds)
            hideOffendingApp()
            statusMessage = "Deep Work Lock started for \(grantedSeconds.shortDurationString)."
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

    private func resetActiveCandidate() {
        activeKey = nil
        activeStartedAt = nil
        activeElapsed = 0
        currentOffendingApp = nil
    }

    private func isStillPoint(appName: String, bundleIdentifier: String) -> Bool {
        appName == "StillPoint" || bundleIdentifier == "com.changxinhai.StillPoint"
    }

    private func triggerThreshold() -> TimeInterval {
        if focusLockActive {
            return demoMode ? 4 : 10
        }
        return demoMode ? 8 : 90
    }
}
