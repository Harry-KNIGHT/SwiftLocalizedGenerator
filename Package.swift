// swift-tools-version: 6.1

import PackageDescription

let package = Package(
    name: "SwiftLocalizedGenerator",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
        .tvOS(.v16),
        .watchOS(.v9),
        .visionOS(.v1)
    ],
    products: [
        .plugin(
            name: "SwiftLocalizedGeneratorPlugin",
            targets: ["SwiftLocalizedGeneratorPlugin"]
        )
    ],
    targets: [
        .target(
            name: "SwiftLocalizedGeneratorCore"
        ),
        .executableTarget(
            name: "SwiftLocalizedGenerator",
            dependencies: ["SwiftLocalizedGeneratorCore"]
        ),
        .plugin(
            name: "SwiftLocalizedGeneratorPlugin",
            capability: .buildTool(),
            dependencies: ["SwiftLocalizedGenerator"]
        ),
        .target(
            name: "FixtureLocalization",
            path: "Tests/Fixtures/FixtureLocalization",
            resources: [.process("Resources")],
            plugins: [.plugin(name: "SwiftLocalizedGeneratorPlugin")]
        ),
        .testTarget(
            name: "SwiftLocalizedGeneratorCoreTests",
            dependencies: ["SwiftLocalizedGeneratorCore"]
        ),
        .testTarget(
            name: "IntegrationTests",
            dependencies: ["FixtureLocalization"]
        )
    ],
    swiftLanguageModes: [.v6]
)
