import Foundation

struct ManufacturingTimeResult {
    let partName: String
    let operations: [OperationTimeResult]
    let totalMachiningTime: Double   // мин
    let totalTransportTime: Double   // мин
    let totalSetupTime: Double       // мин
    let grandTotal: Double           // мин

    var grandTotalHours: Double { grandTotal / 60.0 }
}

struct OperationTimeResult {
    let operation: Operation
    let machineID: UUID?
    let machineName: String
    let machineTime: Double
    let auxiliaryTime: Double
    let setupTime: Double
    let transportTimeBefore: Double  // время доставки к этому станку
    let total: Double
}

struct TimeCalculator {

    /// Рассчитывает полное время изготовления детали с учётом маршрута
    static func calculate(part: Part, workshop: Workshop, transportSpeed: Double = 30.0) -> ManufacturingTimeResult {
        var operationResults: [OperationTimeResult] = []
        var prevMachinePosition = CGPoint(x: 0, y: 0) // точка входа (склад заготовок)

        for op in part.operations {
            let machine = op.machineID.flatMap { workshop.machine(by: $0) }
            let machineName = machine?.name ?? "Не назначено"

            let setupTime: Double
            if let override = op.setupTimeOverride {
                setupTime = override
            } else {
                setupTime = machine?.setupTime ?? 0
            }

            let transportTime: Double
            if let machine = machine {
                let distance = distance(from: prevMachinePosition, to: machine.position)
                // скорость транспортировки в м/мин
                transportTime = distance / transportSpeed
                prevMachinePosition = machine.position
            } else {
                transportTime = 0
            }

            let total = op.machineTime + op.auxiliaryTime + setupTime + transportTime

            operationResults.append(OperationTimeResult(
                operation: op,
                machineID: op.machineID,
                machineName: machineName,
                machineTime: op.machineTime,
                auxiliaryTime: op.auxiliaryTime,
                setupTime: setupTime,
                transportTimeBefore: transportTime,
                total: total
            ))
        }

        let totalMachining  = operationResults.reduce(0) { $0 + $1.machineTime + $1.auxiliaryTime }
        let totalTransport  = operationResults.reduce(0) { $0 + $1.transportTimeBefore }
        let totalSetup      = operationResults.reduce(0) { $0 + $1.setupTime }
        let grandTotal      = totalMachining + totalTransport + totalSetup

        return ManufacturingTimeResult(
            partName: part.name,
            operations: operationResults,
            totalMachiningTime: totalMachining,
            totalTransportTime: totalTransport,
            totalSetupTime: totalSetup,
            grandTotal: grandTotal
        )
    }

    private static func distance(from a: CGPoint, to b: CGPoint) -> Double {
        let dx = b.x - a.x
        let dy = b.y - a.y
        return sqrt(dx * dx + dy * dy)
    }
}
