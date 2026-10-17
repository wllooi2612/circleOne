// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "circleOne",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .executable(
            name: "circleOne",
            targets: ["circleOne"]
        ),
    ],
    targets: [
        .executableTarget(
            name: "circleOne",
            path: "circleOne",
            exclude: [
                "Resources",
                "Preview Content"
            ]
        ),
    ]
)
