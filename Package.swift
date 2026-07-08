// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "StillPoint",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .library(name: "StillPointCore", targets: ["StillPointCore"]),
        .executable(name: "StillPoint", targets: ["StillPoint"]),
        .executable(name: "StillPointLogicTests", targets: ["StillPointLogicTests"])
    ],
    targets: [
        .target(
            name: "StillPointCore",
            path: "Sources/StillPointCore"
        ),
        .executableTarget(
            name: "StillPoint",
            dependencies: ["StillPointCore"],
            path: "Sources/StillPoint"
        ),
        .executableTarget(
            name: "StillPointLogicTests",
            dependencies: ["StillPointCore"],
            path: "Tests/StillPointLogicTests"
        )
    ]
)
