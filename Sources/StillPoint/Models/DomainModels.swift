import Foundation

struct InterventionContext: Identifiable, Equatable {
    let id = UUID()
    var appName: String
    var bundleIdentifier: String
    var elapsedSeconds: TimeInterval
    var isFocusLock: Bool
    var triggerReason: String
}

enum InterventionAction: String, Codable {
    case purposePass = "Purpose pass"
    case intentionalBreak = "Intentional break"
    case closeApp = "Closed drift"
    case startLock = "Started lock"
}

struct AttentionEvent: Identifiable, Codable {
    var id = UUID()
    var date: Date
    var appName: String
    var action: InterventionAction
    var elapsedSeconds: TimeInterval
    var grantedSeconds: TimeInterval
    var protectedSeconds: TimeInterval
    var wasFocusLockActive: Bool
}

struct DailyAttentionSummary {
    var driftChecks: Int = 0
    var purposePasses: Int = 0
    var intentionalBreaks: Int = 0
    var closedDrifts: Int = 0
    var locksStarted: Int = 0
    var protectedSeconds: TimeInterval = 0

    var hasData: Bool {
        driftChecks > 0 || purposePasses > 0 || intentionalBreaks > 0 || closedDrifts > 0 || locksStarted > 0
    }
}

enum AppSection: String, CaseIterable, Identifiable, Hashable {
    case dashboard
    case rules
    case focusLock
    case receipt

    var id: String { rawValue }

    var title: String {
        switch self {
        case .dashboard: "Dashboard"
        case .rules: "Watch List"
        case .focusLock: "Deep Work Lock"
        case .receipt: "Daily Receipt"
        }
    }

    var detail: String {
        switch self {
        case .dashboard: "Live state"
        case .rules: "Targets"
        case .focusLock: "Shield"
        case .receipt: "Today"
        }
    }

    var systemImage: String {
        switch self {
        case .dashboard: "gauge.with.dots.needle.67percent"
        case .rules: "eye"
        case .focusLock: "lock.shield"
        case .receipt: "text.page"
        }
    }
}
