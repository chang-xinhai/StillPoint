import Foundation

public struct WatchedApp: Identifiable, Codable, Hashable, Sendable {
    public var id = UUID()
    public var displayName: String
    public var detail: String
    public var matchTerms: [String]
    public var isEnabled: Bool

    public init(
        id: UUID = UUID(),
        displayName: String,
        detail: String,
        matchTerms: [String],
        isEnabled: Bool
    ) {
        self.id = id
        self.displayName = displayName
        self.detail = detail
        self.matchTerms = matchTerms
        self.isEnabled = isEnabled
    }

    public func matches(appName: String, bundleIdentifier: String) -> Bool {
        guard isEnabled else { return false }
        let haystack = "\(appName) \(bundleIdentifier)".lowercased()
        return matchTerms.contains { haystack.contains($0.lowercased()) }
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
