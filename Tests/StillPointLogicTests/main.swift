import Darwin
import Foundation
import StillPointCore

@main
struct StillPointLogicTests {
    static func main() {
        var failures = 0

        func expect(_ condition: @autoclosure () -> Bool, _ message: String) {
            if !condition() {
                failures += 1
                print("FAIL: \(message)")
            }
        }

        let douyin = WatchedApp(
            displayName: "Douyin",
            detail: "Short video",
            matchTerms: ["douyin", "抖音"],
            isEnabled: true
        )
        expect(douyin.matches(appName: "Douyin", bundleIdentifier: "com.example.player"), "matches app name")
        expect(douyin.matches(appName: "抖音", bundleIdentifier: ""), "matches Chinese app name")

        let tiktok = WatchedApp(
            displayName: "TikTok",
            detail: "Short video",
            matchTerms: ["tiktok"],
            isEnabled: true
        )
        expect(tiktok.matches(appName: "Video", bundleIdentifier: "com.example.tiktok.desktop"), "matches bundle id")

        let browserDomains = WatchedApp(
            displayName: "Browser domains",
            detail: "Planned",
            matchTerms: ["douyin.com"],
            isEnabled: false
        )
        expect(
            !browserDomains.matches(appName: "Safari", bundleIdentifier: "com.apple.Safari.douyin.com"),
            "disabled rules do not match"
        )

        let bilibili = WatchedApp(
            displayName: "Bilibili",
            detail: "Video",
            matchTerms: ["bilibili", "哔哩"],
            isEnabled: true
        )
        expect(
            !bilibili.matches(appName: "Visual Studio Code", bundleIdentifier: "com.microsoft.VSCode"),
            "unrelated work app does not match"
        )

        let generatedTerms = WatchedApp.matchTerms(
            applicationName: "Douyin",
            bundleIdentifier: "com.ss.iphone.ugc.Aweme"
        )
        expect(
            generatedTerms == ["com.ss.iphone.ugc.Aweme", "Douyin"],
            "custom app terms keep bundle id before display name"
        )

        let customApp = WatchedApp(
            applicationName: "Douyin",
            bundleIdentifier: "com.ss.iphone.ugc.Aweme"
        )
        expect(
            customApp.matches(appName: "Anything", bundleIdentifier: "com.ss.iphone.ugc.Aweme"),
            "custom app matches generated bundle id term"
        )
        expect(
            customApp.gateSeconds == WatchedApp.defaultGateSeconds,
            "custom app uses the default two-minute gate"
        )

        let customGateApp = WatchedApp(
            displayName: "Rednote",
            detail: "Lifestyle feed",
            matchTerms: ["rednote"],
            isEnabled: true,
            gateSeconds: 5 * 60
        )
        expect(customGateApp.gateSeconds == 5 * 60, "watched app can store a custom gate")

        guard failures == 0 else {
            print("\(failures) StillPoint logic test(s) failed.")
            exit(1)
        }

        print("All StillPoint logic tests passed.")
    }
}
