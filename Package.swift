// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LeagueKit",
    products: [
        .library(
            name: "LeagueKit",
            targets: ["LeagueKit"]
		),
    ],
    dependencies: [
		.package(url: "https://github.com/timvermeulen/Promise.git", .branch("master"))
    ],
    targets: [
        .target(
            name: "LeagueKit",
            dependencies: ["Promise"]
		),
        .testTarget(
            name: "LeagueKitTests",
            dependencies: ["LeagueKit"]
		),
    ]
)
