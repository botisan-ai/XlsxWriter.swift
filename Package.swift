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
    let releaseTag = "0.1.2"
    let releaseChecksum = "5301cff35f3cf8a4e5e10bdbec4ae327606c130e380f901ebff89fb9ff24f16a"
    binaryTarget = .binaryTarget(
        name: "XlsxWriterRS",
        url:
        "https://github.com/lhr0909/XlsxWriter.swift/releases/download/\(releaseTag)/libxlsxwriter-rs.xcframework.zip",
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
