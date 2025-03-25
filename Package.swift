// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "SwiftNetWatch",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "SwiftNetWatch",
            targets: ["SwiftNetWatch"]
        ),
    ],
    targets: [
        .target(
            name: "SwiftNetWatch",
            dependencies: []
        )
    ]
)
