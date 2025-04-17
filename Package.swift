// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ManulMonday",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "ManulMonday",
            targets: ["ManulMonday"]),
    ],
    dependencies: [
        // Firebase dependencies
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "10.0.0"),
        
        // Kingfisher for image loading and caching
        .package(url: "https://github.com/onevcat/Kingfisher.git", from: "7.0.0"),
    ],
    targets: [
        .target(
            name: "ManulMonday",
            dependencies: [
                .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
                .product(name: "FirebaseFirestore", package: "firebase-ios-sdk"),
                .product(name: "FirebaseFirestoreSwift", package: "firebase-ios-sdk"),
                .product(name: "FirebaseStorage", package: "firebase-ios-sdk"),
                .product(name: "FirebaseAnalytics", package: "firebase-ios-sdk"),
                .product(name: "Kingfisher", package: "Kingfisher"),
            ],
            path: "ManulMonday/Sources"
        ),
    ]
)
