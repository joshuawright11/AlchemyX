// swift-tools-version: 5.9
import CompilerPluginSupport
import PackageDescription

let package = Package(
    name: "alchemyx",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
    ],
    products: [
        .library(name: "AlchemyX", targets: ["AlchemyX"]),
    ],
    dependencies: [
        .package(url: "https://github.com/joshuawright11/papyrus", branch: "main"),
        .package(url: "https://github.com/apple/swift-syntax", "509.0.0"..<"601.0.0-prerelease"),
    ],
    targets: [
        .target(
            name: "AlchemyX",
            dependencies: [
                .byName(name: "AlchemyXPlugin"),
                .product(name: "Papyrus", package: "papyrus"),
            ],
            path: "AlchemyX"
        ),
        .macro(
            name: "AlchemyXPlugin",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftOperators", package: "swift-syntax"),
                .product(name: "SwiftParser", package: "swift-syntax"),
                .product(name: "SwiftParserDiagnostics", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            ],
            path: "AlchemyXPlugin"
        ),
    ]
)
