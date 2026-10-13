// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MacDuoAnimation",
    platforms: [
        .macOS(.v14) // Garante compatibilidade com o macOS Sonoma ou superior
    ],
    products: [
        .library(
            name: "MacDuoAnimation",
            targets: ["MacDuoAnimation"]
        ),
    ],
    targets: [
        .target(
            name: "MacDuoAnimation",
            path: "Sources",
            publicHeadersPath: ".", // Diz ao Xcode onde achar o LidSensorBridge.h
            cSettings: [
                .headerSearchPath(".")
            ],
            linkerSettings: [
                .linkedFramework("IOKit"), // Importa automaticamente a biblioteca de hardware da Apple
                .linkedFramework("Cocoa"),
                .linkedFramework("QuartzCore")
            ]
        )
    ]
)
