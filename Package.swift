// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "JoltPhysics",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .tvOS(.v26),
        .visionOS(.v26)
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
