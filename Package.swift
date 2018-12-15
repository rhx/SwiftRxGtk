// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "RxGtk",
    products: [
        .library(name: "RxGtk", targets: ["RxGtk"]),
    ],
    dependencies: [
        .package(url: "https://github.com/ReactiveX/RxSwift.git", .branch("master")),
        .package(url: "https://github.com/rhx/SwiftGtk.git", .branch("master")),
    ],
    targets: [
        .target(name: "RxGtk", dependencies: ["Gtk", "RxCocoa", "RxSwift"]),
    ]
)
