// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "mParticle-Foresee",
    platforms: [ .iOS(.v9) ],
    products: [
        .library(
            name: "mParticle-Foresee",
            targets: ["mParticle-Foresee"]),
    ],
    dependencies: [
      .package(
          name: "mParticle-Apple-SDK",
          url: "https://github.com/mParticle/mparticle-apple-sdk",
          .upToNextMajor(from: "8.19.0")
      ),
    ],
    targets: [
        .target(
            name: "mParticle-Foresee",
            dependencies: [
                .byName(name: "mParticle-Apple-SDK"),
            ],
            path: "mParticle-Foresee",
            publicHeadersPath: "."
        )
    ]
)
