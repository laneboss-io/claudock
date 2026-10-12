// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Claudock",
    platforms: [.macOS(.v14)],
    products: [
        .executable(name: "claudock", targets: ["ClaudockCLI"]),
        .library(name: "UsageCore", targets: ["UsageCore"])
    ],
    targets: [
        .target(name: "UsageCore"),
        .executableTarget(name: "ClaudockCLI", dependencies: ["UsageCore"]),
        .testTarget(name: "UsageCoreTests", dependencies: ["UsageCore"])
    ],
    swiftLanguageModes: [.v5]
)
