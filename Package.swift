// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-error-kit",
    platforms: [.macOS(.v14), .iOS(.v13), .tvOS(.v13), .watchOS(.v6), .macCatalyst(.v13)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "SwiftErrorKit",
            targets: ["SwiftErrorKit"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
        .package(url: "https://github.com/stansmida/swift-extras.git", from: "0.7.4")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "SwiftErrorKit",
            dependencies: [
                .product(name: "SwiftExtras", package: "swift-extras"),
            ]
        ),
        .testTarget(
            name: "SwiftErrorKitTests",
            dependencies: ["SwiftErrorKit"]
        ),
    ]
)
