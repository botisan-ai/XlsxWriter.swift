// swift-tools-version: 6.0

import PackageDescription

let useLocalFramework = false
let binaryTarget: Target

if useLocalFramework {
    binaryTarget = .binaryTarget(
        name: "XlsxWriterRS",
        path: "./build/libxlsxwriter-rs.xcframework"
    )
} else {
    let releaseTag = "0.1.0"
    let releaseChecksum = "fa40e133c5e83a5afd661f16a6fde8299f0fef0469d261a8da11e199ca178dc4"
    binaryTarget = .binaryTarget(
        name: "XlsxWriterRS",
        url:
        "https://github.com/example/XlsxWriter.swift/releases/download/\(releaseTag)/libxlsxwriter-rs.xcframework.zip",
        checksum: releaseChecksum
    )
}

let package = Package(
    name: "XlsxWriterSwift",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
    ],
    products: [
        .library(
            name: "XlsxWriterSwift",
            targets: ["XlsxWriterSwift"]
        ),
    ],
    targets: [
        binaryTarget,
        .target(
            name: "XlsxWriterSwift",
            dependencies: ["XlsxWriterFFI"]
        ),
        .target(
            name: "XlsxWriterFFI",
            dependencies: ["XlsxWriterRS"]
        ),
        .testTarget(
            name: "XlsxWriterSwiftTests",
            dependencies: ["XlsxWriterSwift"]
        ),
    ]
)
