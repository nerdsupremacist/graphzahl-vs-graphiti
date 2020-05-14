// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GraphitiServer",
    platforms: [.macOS(.v10_15)],
    products: [
        .executable(
            name: "GraphitiServer",
            targets: ["GraphitiServer"]),
    ],
    dependencies: [
        .package(url: "https://github.com/alexsteinerde/Graphiti.git", from: "0.12.1")
    ],
    targets: [
        .target(
            name: "GraphitiServer",
            dependencies: ["Graphiti"]),
    ]
)
