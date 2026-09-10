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
    targets: [
        .executableTarget(
            name: "Centik",
            path: ".",
            exclude: [
                "docs",
                "assets",
                "LICENSE",
                "README.md"
            ],
            sources: [
                "App",
                "Shell"
            ]
        )
    ]
)
