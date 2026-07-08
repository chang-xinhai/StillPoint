import Foundation

public struct WatchedApp: Identifiable, Codable, Hashable, Sendable {
    public static let defaultGateSeconds: TimeInterval = 120
    public static let minimumGateSeconds: TimeInterval = 30
    public static let maximumGateSeconds: TimeInterval = 15 * 60
    public static let gateStepSeconds: TimeInterval = 30

    public var id = UUID()
    public var displayName: String
    public var detail: String
    public var matchTerms: [String]
    public var isEnabled: Bool
    public var gateSeconds: TimeInterval

    public init(
        id: UUID = UUID(),
        displayName: String,
        detail: String,
        matchTerms: [String],
        isEnabled: Bool,
        gateSeconds: TimeInterval = Self.defaultGateSeconds
    ) {
        self.id = id
        self.displayName = displayName
        self.detail = detail
        self.matchTerms = matchTerms
        self.isEnabled = isEnabled
        self.gateSeconds = gateSeconds
    }

    public init(
        applicationName: String,
        bundleIdentifier: String,
        detail: String = "Added from the macOS app list.",
        isEnabled: Bool = true
    ) {
        self.init(
            displayName: applicationName,
            detail: detail,
            matchTerms: Self.matchTerms(applicationName: applicationName, bundleIdentifier: bundleIdentifier),
            isEnabled: isEnabled
        )
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        displayName = try container.decode(String.self, forKey: .displayName)
        detail = try container.decode(String.self, forKey: .detail)
        matchTerms = try container.decode([String].self, forKey: .matchTerms)
        isEnabled = try container.decode(Bool.self, forKey: .isEnabled)
        gateSeconds = try container.decodeIfPresent(TimeInterval.self, forKey: .gateSeconds) ?? Self.defaultGateSeconds
    }

    public func matches(appName: String, bundleIdentifier: String) -> Bool {
        guard isEnabled else { return false }
        let haystack = "\(appName) \(bundleIdentifier)".lowercased()
        return matchTerms.contains { haystack.contains($0.lowercased()) }
    }

    public static func matchTerms(applicationName: String, bundleIdentifier: String) -> [String] {
        var seen = Set<String>()

        return [bundleIdentifier, applicationName].compactMap { rawTerm in
            let term = rawTerm.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !term.isEmpty else { return nil }

            let key = term.lowercased()
            guard seen.insert(key).inserted else { return nil }

            return term
        }
    }

    public static let defaults: [WatchedApp] = [
        WatchedApp(
            displayName: "Douyin / TikTok",
            detail: "Standalone short-video apps; browser domain support is planned.",
            matchTerms: ["douyin", "tiktok", "抖音"],
            isEnabled: true
        ),
        WatchedApp(
            displayName: "Bilibili",
            detail: "Useful for tutorials, risky when drifting into recommendations.",
            matchTerms: ["bilibili", "哔哩", "b站"],
            isEnabled: true
        ),
        WatchedApp(
            displayName: "Xiaohongshu",
            detail: "Lifestyle search is valid; endless feed is the risk zone.",
            matchTerms: ["xiaohongshu", "rednote", "小红书"],
            isEnabled: true
        ),
        WatchedApp(
            displayName: "Browser social domains",
            detail: "Planned: douyin.com, tiktok.com, youtube.com/shorts, bilibili.com.",
            matchTerms: ["browser-domain-placeholder"],
            isEnabled: false
        )
    ]
}
