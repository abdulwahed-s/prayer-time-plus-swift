// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "prayer-time-plus-swift",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "prayer-time-plus-swift",
            targets: ["prayer-time-plus-swift"]
        ),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "prayer-time-plus-swift"
        ),
        .testTarget(
            name: "prayer-time-plus-swiftTests",
            dependencies: ["prayer-time-plus-swift"]
        ),
    ],
    swiftLanguageModes: [.v6]
)
