// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

// Treat every warning as an error so the tree stays warning-clean. This uses the
// supported build setting (not `-warnings-as-errors` unsafe flags) so the package
// can still be consumed by a semantic-version requirement.
let strict: [SwiftSetting] = [
    .treatAllWarnings(as: .error),
]

let package = Package(
    name: "PrayerTimePlus",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v6),
    ],
    products: [
        .library(
            name: "PrayerTimePlus",
            targets: ["PrayerTimePlus"]
        ),
        .executable(
            name: "prayer-time-plus-cli",
            targets: ["prayer-time-plus-cli"]
        ),
    ],
    targets: [
        .target(
            name: "PrayerTimePlus",
            swiftSettings: strict
        ),
        .executableTarget(
            name: "prayer-time-plus-cli",
            dependencies: ["PrayerTimePlus"],
            swiftSettings: strict
        ),
        .testTarget(
            name: "PrayerTimePlusTests",
            dependencies: ["PrayerTimePlus"],
            swiftSettings: strict
        ),
    ],
    swiftLanguageModes: [.v6]
)
