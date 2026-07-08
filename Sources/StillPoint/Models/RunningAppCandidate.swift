import Foundation

struct RunningAppCandidate: Identifiable, Hashable {
    var displayName: String
    var bundleIdentifier: String
    var bundleURL: URL?
    var isFrontmost: Bool

    var id: String {
        if !bundleIdentifier.isEmpty {
            return bundleIdentifier
        }

        return [displayName, bundleURL?.path ?? ""]
            .filter { !$0.isEmpty }
            .joined(separator: "::")
    }
}
