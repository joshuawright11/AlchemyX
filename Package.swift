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
        .package(path: "../../papyrus/papyrus"),
        .package(url: "https://github.com/apple/swift-syntax", from: "510.0.0"),
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
