import Foundation
import CoreGraphics

struct RouteStep {
    let from: CGPoint
    let to: CGPoint
    let label: String
    let distanceMeters: Double
    let timeMinutes: Double
}

struct RouteOptimizer {

    /// Строит последовательный маршрут детали по цеху согласно операциям
    static func buildRoute(part: Part, workshop: Workshop, transportSpeed: Double = 30.0) -> [RouteStep] {
        var steps: [RouteStep] = []
        var prevPoint = CGPoint(x: 0, y: 0)
        var prevLabel = "Склад заготовок"

        for op in part.operations {
            guard let machine = op.machineID.flatMap({ workshop.machine(by: $0) }) else { continue }

            let dist = distance(from: prevPoint, to: machine.position)
            let time = dist / transportSpeed

            steps.append(RouteStep(
                from: prevPoint,
                to: machine.position,
                label: "\(prevLabel) → \(machine.name)",
                distanceMeters: dist,
                timeMinutes: time
            ))

            prevPoint = machine.position
            prevLabel = machine.name
        }

        // Возврат на склад готовых деталей
        let finalPoint = CGPoint(x: workshop.width, y: 0)
        let dist = distance(from: prevPoint, to: finalPoint)
        steps.append(RouteStep(
            from: prevPoint,
            to: finalPoint,
            label: "\(prevLabel) → Склад готовых деталей",
            distanceMeters: dist,
            timeMinutes: dist / transportSpeed
        ))

        return steps
    }

    /// Суммарный путь детали по цеху в метрах
    static func totalDistance(steps: [RouteStep]) -> Double {
        steps.reduce(0) { $0 + $1.distanceMeters }
    }

    private static func distance(from a: CGPoint, to b: CGPoint) -> Double {
        let dx = b.x - a.x
        let dy = b.y - a.y
        return sqrt(dx * dx + dy * dy)
    }
}
