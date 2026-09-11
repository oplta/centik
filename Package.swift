// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Centik",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "Centik", targets: ["Centik"])
    ],
    dependencies: [
        .package(url: "https://github.com/sparkle-project/Sparkle", from: "2.6.0")
    ],
    targets: [
        .executableTarget(
            name: "Centik",
            dependencies: [
                .product(name: "Sparkle", package: "Sparkle")
            ],
            path: ".",
            exclude: [
                "docs",
                "assets",
                "LICENSE",
                "README.md",
                "packaging",
                "scripts",
                "dist"
            ],
            sources: [
                "App",
                "Shell",
                "Features",
                "Core"
            ]
        )
    ]
)
