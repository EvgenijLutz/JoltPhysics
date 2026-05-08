// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "JoltPhysics",
    platforms: [
        .macOS(.v10_13),
        .iOS(.v12),
        .tvOS(.v12),
        //.watchOS(.v8),
        .visionOS(.v1),
    ],
    products: [
        .library(
            name: "Jolt",
            targets: ["Jolt"]
        ),
        .library(
            name: "JoltExample",
            targets: ["JoltExample"]
        )
    ],
    targets: [
        .binaryTarget(
            name: "Jolt",
            path: "Binaries/Jolt.xcframework"
        ),
        .target(
            name: "JoltExample",
            dependencies: [
                .target(name: "Jolt")
            ]
        )

    ],
    // Jolt was compiled with C++ 17
    cxxLanguageStandard: .cxx17
)
