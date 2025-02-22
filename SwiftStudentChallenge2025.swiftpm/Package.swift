// swift-tools-version: 5.9

// WARNING:
// This file is automatically generated.
// Do not edit it by hand because the contents will be replaced.

import PackageDescription
import AppleProductTypes

let package = Package(
    name: "SwiftStudentChallenge2025",
    platforms: [
        .iOS("17.5")
    ],
    products: [
        .iOSApplication(
            name: "SwiftStudentChallenge2025",
            targets: ["AppModule"],
            bundleIdentifier: "com.Leo",
            teamIdentifier: "5GYXF2FP9Y",
            displayVersion: "1.0",
            bundleVersion: "1",
            appIcon: .placeholder(icon: .gift),
            accentColor: .presetColor(.purple),
            supportedDeviceFamilies: [
                .pad,
                .phone
            ],
            supportedInterfaceOrientations: [
                .landscapeRight
            ],
            capabilities: [
                .camera(purposeString: "Identify Hand Actions.")
            ]
        )
    ],
    targets: [
        .executableTarget(
            name: "AppModule",
            path: ".",
            resources: [
                .copy("Resources/PrimeiroTesteRotacaoMaoUnica 9.mlmodelc"),
                .copy("Resources/SwiftStudentChallenge2025_HandActionClassifier 3.mlmodelc"),
                .copy("Resources/SwiftStudentChallenge2025_HandActionClassifier 3 copy.mlmodelc"),
                .copy("Resources/SwiftStudentChallenge2025_HandActionClassifier 4.mlmodelc"),
                .copy("Resources/SwiftStudentChallenge2025_HandActionClassifier 5.mlmodelc"),
                .copy("Resources/SwiftStudentChallenge2025_HandActionClassifier 16.mlmodelc"),
                .copy("Resources/LeoSSC2025.mlmodelc"),
                .process("Resources/Assets.xcassets")
            ]
        )
    ]
)
