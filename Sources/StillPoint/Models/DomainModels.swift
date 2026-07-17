import Foundation

enum AppLanguage: String, CaseIterable, Identifiable, Codable {
    case chinese
    case english

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .chinese: "中文"
        case .english: "English"
        }
    }

    func text(_ english: String, _ chinese: String) -> String {
        self == .chinese ? chinese : english
    }
}

struct InterventionContext: Identifiable, Equatable {
    let id = UUID()
    var appName: String
    var bundleIdentifier: String
    var elapsedSeconds: TimeInterval
    var isFocusLock: Bool
    var triggerReason: String
    var language: AppLanguage = .english
}

enum InterventionAction: String, Codable {
    case purposePass = "Purpose pass"
    case intentionalBreak = "Intentional break"
    case closeApp = "Closed drift"
    case startLock = "Started lock"

    func title(language: AppLanguage) -> String {
        switch self {
        case .purposePass:
            language.text("Purpose pass", "查找通行")
        case .intentionalBreak:
            language.text("Intentional break", "有意休息")
        case .closeApp:
            language.text("Closed drift", "关闭走神")
        case .startLock:
            language.text("Started lock", "开启锁定")
        }
    }
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
        title(language: .english)
    }

    func title(language: AppLanguage) -> String {
        switch self {
        case .dashboard: language.text("Now", "此刻")
        case .rules: language.text("Targets", "目标")
        case .focusLock: language.text("Deep Work", "深度工作")
        case .receipt: language.text("Today’s Receipt", "今天的小票")
        }
    }

    var detail: String {
        detail(language: .english)
    }

    func detail(language: AppLanguage) -> String {
        switch self {
        case .dashboard: language.text("Live attention", "实时注意力")
        case .rules: language.text("Chosen apps", "已选应用")
        case .focusLock: language.text("Focus boundary", "专注边界")
        case .receipt: language.text("One calm review", "一次轻量回顾")
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
