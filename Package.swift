// swift-tools-version: 5.8
import PackageDescription

let package = Package(
    name: "PinWinTop",
    platforms: [
        .macOS(.v11)
    ],
    products: [
        .executable(name: "PinWinTop", targets: ["PinWinTop"])
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "PinWinTop",
            dependencies: [],
            path: "Sources/PinWinTop"
        )
    ]
)
