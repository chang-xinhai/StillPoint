import Foundation

public enum AttentionGatePolicy {
    public static let focusLockGateSeconds: TimeInterval = 3
    public static let purposePassMinimumSeconds: TimeInterval = 2 * 60
    public static let intentionalBreakMinimumSeconds: TimeInterval = 5 * 60
    public static let closedDriftMinimumProtectedSeconds: TimeInterval = 10 * 60
    public static let overlayFocusLockSeconds: TimeInterval = 25 * 60

    public static func effectiveGateSeconds(appGateSeconds: TimeInterval, focusLockActive: Bool) -> TimeInterval {
        focusLockActive ? focusLockGateSeconds : appGateSeconds
    }

    public static func purposePassSeconds(activeGateSeconds: TimeInterval) -> TimeInterval {
        max(activeGateSeconds, purposePassMinimumSeconds)
    }

    public static func intentionalBreakSeconds(activeGateSeconds: TimeInterval) -> TimeInterval {
        max(activeGateSeconds, intentionalBreakMinimumSeconds)
    }

    public static func closedDriftProtectedSeconds(activeGateSeconds: TimeInterval) -> TimeInterval {
        max(activeGateSeconds, closedDriftMinimumProtectedSeconds)
    }
}
