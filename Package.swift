// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ShopFloorPlanner",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "ShopFloorPlanner", targets: ["ShopFloorPlanner"])
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "ShopFloorPlanner",
            path: "Sources/ShopFloorPlanner"
        ),
        .testTarget(
            name: "ShopFloorPlannerTests",
            dependencies: ["ShopFloorPlanner"],
            path: "Tests/ShopFloorPlannerTests"
        )
    ]
)
