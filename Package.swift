// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "system-module",
    platforms: [
       .macOS(.v10_15)
    ],
    products: [
        .library(name: "SystemModule", targets: ["SystemModule"]),
        .library(name: "SystemModuleApi", targets: ["SystemModuleApi"]),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/fluent-sqlite-driver", from: "4.0.0"),
        .package(url: "https://github.com/binarybirds/liquid-local-driver", from: "1.2.0-beta"),
        .package(url: "https://github.com/FeatherCMS/feather-core", from: "1.0.0-beta"),
        /// core modules
        .package(url: "https://github.com/FeatherCMS/user-module", from: "1.0.0-beta"),
        .package(url: "https://github.com/FeatherCMS/api-module", from: "1.0.0-beta"),
        .package(url: "https://github.com/FeatherCMS/admin-module", from: "1.0.0-beta"),
        .package(url: "https://github.com/FeatherCMS/frontend-module", from: "1.0.0-beta"),
    ],
    targets: [
        .target(name: "SystemModuleApi", dependencies: []),
        .target(name: "SystemModule", dependencies: [
            .product(name: "FeatherCore", package: "feather-core"),
            .target(name: "SystemModuleApi")
        ],
        resources: [
            .copy("Bundle"),
        ]),
        .target(name: "Feather", dependencies: [
            .product(name: "FeatherCore", package: "feather-core"),
            
            .product(name: "FluentSQLiteDriver", package: "fluent-sqlite-driver"),
            .product(name: "LiquidLocalDriver", package: "liquid-local-driver"),
            
            /// core modules
            .product(name: "UserModule", package: "user-module"),
            .product(name: "ApiModule", package: "api-module"),
            .product(name: "AdminModule", package: "admin-module"),
            .product(name: "FrontendModule", package: "frontend-module"),
            
            .target(name: "SystemModule"),
        ]),
        .testTarget(name: "SystemModuleTests", dependencies: [
            .target(name: "SystemModule"),
        ])
    ]
)
