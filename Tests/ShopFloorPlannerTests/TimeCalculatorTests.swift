import XCTest
@testable import ShopFloorPlanner

final class TimeCalculatorTests: XCTestCase {

    func testSimpleRoute() {
        let workshop = Workshop(name: "Тест", width: 20, height: 10)

        let lathe = Machine(name: "Токарный 1", type: .lathe, position: CGPoint(x: 5, y: 5))
        let mill  = Machine(name: "Фрезерный 1", type: .milling, position: CGPoint(x: 15, y: 5))
        workshop.machines = [lathe, mill]

        let part = Part(name: "Вал", material: "Сталь 45")

        let op1 = Operation(name: "Токарная черновая", type: .turning, machineTime: 10, auxiliaryTime: 2)
        op1.machineID = lathe.id

        let op2 = Operation(name: "Фрезерная", type: .milling, machineTime: 8, auxiliaryTime: 1.5)
        op2.machineID = mill.id

        part.operations = [op1, op2]

        let result = TimeCalculator.calculate(part: part, workshop: workshop)

        XCTAssertEqual(result.totalMachiningTime, 21.5, accuracy: 0.01)
        XCTAssertGreaterThan(result.totalTransportTime, 0)
        XCTAssertEqual(result.grandTotal, result.totalMachiningTime + result.totalTransportTime + result.totalSetupTime, accuracy: 0.01)
    }

    func testEmptyPart() {
        let workshop = Workshop(name: "Тест", width: 10, height: 10)
        let part = Part(name: "Пустая деталь")
        let result = TimeCalculator.calculate(part: part, workshop: workshop)
        XCTAssertEqual(result.grandTotal, 0)
    }
}
