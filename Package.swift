// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "swift-dev-console",
    platforms: [
        .macOS(.v13),
        .iOS(.v16),
        .tvOS(.v16),
        .watchOS(.v9)
    ],
    products: [
        .library(name: "DevConsole", targets: ["DevConsole"])
    ],
    targets: [
        .target(
            name: "DevConsole",
            path: "Sources/DevConsole"
        ),
        .testTarget(
            name: "DevConsoleTests",
            dependencies: ["DevConsole"],
            path: "Tests/DevConsoleTests"
        )
    ]
)
