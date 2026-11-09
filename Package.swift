// swift-tools-version: 6.2
import PackageDescription

let strict: [SwiftSetting] = [.treatAllWarnings(as: .error)]

let package = Package(
  name: "verpick",
  targets: [
    .target(name: "VerpickCore", swiftSettings: strict),
    .executableTarget(name: "verpick", dependencies: ["VerpickCore"], swiftSettings: strict),
    .testTarget(name: "VerpickCoreTests", dependencies: ["VerpickCore"], swiftSettings: strict),
  ]
)
