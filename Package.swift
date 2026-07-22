// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "JoltPhysics",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .tvOS(.v26),
        //.watchOS(.v26),
        .visionOS(.v26),
    ],
    products: [
        .library(
            name: "Jolt",
            targets: ["Jolt"]
        ),
        .library(
            name: "JoltShaders",
            targets: ["JoltShaders"]
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
            // Packaging a Metal renderer
            // https://developer.apple.com/documentation/technotes/tn3133-packaging-a-renderer
            name: "JoltShaders",
        ),
        .target(
            name: "JoltExample",
            dependencies: [
                .target(name: "Jolt"),
                .target(name: "JoltShaders")
            ]
        )

    ],
    // Jolt was compiled with C++ 17
    cxxLanguageStandard: .cxx17
)
