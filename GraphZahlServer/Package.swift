// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GraphZahlServer",
    platforms: [.macOS(.v10_15)],
    products: [
        .executable(
            name: "GraphZahlServer",
            targets: ["GraphZahlServer"]),
    ],
    dependencies: [
        .package(url: "https://github.com/nerdsupremacist/GraphZahl.git", from: "0.1.0-alpha.24"),
    ],
    targets: [
        .target(
            name: "GraphZahlServer",
            dependencies: ["GraphZahl"]),
    ]
)
