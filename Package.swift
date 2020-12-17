// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "system-module",
    platforms: [
       .macOS(.v10_15)
    ],
    products: [
        .library(name: "SystemModule", targets: ["SystemModule"]),
    ],
    dependencies: [
        .package(url: "https://github.com/binarybirds/feather-core", from: "1.0.0-beta"),
        
        .package(url: "https://github.com/vapor/fluent-sqlite-driver", from: "4.0.0"),
        .package(url: "https://github.com/binarybirds/liquid-local-driver", from: "1.2.0-beta"),
    ],
    targets: [
        .target(name: "SystemModule", dependencies: [
            .product(name: "FeatherCore", package: "feather-core"),
        ],
        resources: [
            .copy("Bundle"),
        ]),
        .target(name: "Feather", dependencies: [
            .product(name: "FeatherCore", package: "feather-core"),
            
            .product(name: "FluentSQLiteDriver", package: "fluent-sqlite-driver"),
            .product(name: "LiquidLocalDriver", package: "liquid-local-driver"),
            
            .target(name: "SystemModule"),
        ]),
        .testTarget(name: "SystemModuleTests", dependencies: [
            .target(name: "SystemModule"),
        ])
    ]
)
