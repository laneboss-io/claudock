// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ClaudockMacOS",
    platforms: [.macOS(.v14)],
    products: [.executable(name: "ClaudockApp", targets: ["ClaudeUsage"])],
    dependencies: [.package(name: "Claudock", path: "..")],
    targets: [
        .executableTarget(
            name: "ClaudeUsage",
            dependencies: [.product(name: "UsageCore", package: "Claudock")]
        )
    ],
    swiftLanguageModes: [.v5]
)
