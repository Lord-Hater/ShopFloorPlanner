import XCTest
@testable import ShopFloorPlanner

final class TimeCalculatorTests: XCTestCase {

    // MARK: - Cutting formula unit tests

    func testTurningFormula() {
        var p = TurningParameters()
        p.diameter = 50       // мм
        p.length = 100        // мм
        p.allowance = 2.0     // мм
        p.depthOfCut = 1.0    // мм  → 2 прохода
        p.cuttingSpeed = 80   // м/мин
        p.feed = 0.3          // мм/об
        p.approachLength = 2
        p.overrunLength = 1

        // n = 1000*80 / (π*50) ≈ 509.3 об/мин
        // L = 100 + 2 + 1 = 103 мм
        // T₀ = 103 * 2 / (509.3 * 0.3) ≈ 1.347 мин
        let t0 = p.calculateMachineTime()
        XCTAssertEqual(t0, 1.347, accuracy: 0.01)
        XCTAssertEqual(p.passes, 2)
    }

    func testDrillingFormula() {
        var p = DrillingParameters()
        p.toolDiameter = 10
        p.holeDepth = 30
        p.cuttingSpeed = 25
        p.feed = 0.15
        p.approachLength = 3
        p.overrunLength = 2

        // n = 1000*25 / (π*10) ≈ 795.8 об/мин
        // L = 30 + 3 + 2 = 35 мм
        // T₀ = 35 / (795.8 * 0.15) ≈ 0.293 мин
        let t0 = p.calculateMachineTime()
        XCTAssertEqual(t0, 0.293, accuracy: 0.01)
    }

    func testMillingFormula() {
        var p = MillingParameters()
        p.toolDiameter = 80
        p.teethCount = 8
        p.cuttingSpeed = 100
        p.feedPerTooth = 0.08
        p.length = 100
        p.approachLength = 5
        p.overrunLength = 3

        // n = 1000*100 / (π*80) ≈ 397.9 об/мин
        // Sмин = 0.08 * 8 * 397.9 ≈ 254.6 мм/мин
        // T₀ = 108 / 254.6 ≈ 0.424 мин
        let t0 = p.calculateMachineTime()
        XCTAssertEqual(t0, 0.424, accuracy: 0.01)
    }

    func testGrindingFormula() {
        var p = GrindingParameters()
        p.diameter = 50
        p.length = 80
        p.allowance = 0.3
        p.partSpeed = 30
        p.wheelWidth = 40
        p.axialFeedCoeff = 0.4
        p.radialFeedPerPass = 0.01

        let t0 = p.calculateMachineTime()
        XCTAssertGreaterThan(t0, 0)
    }

    // MARK: - Integration: full workshop route

    func testFullRouteCalculation() {
        let workshop = Workshop(name: "Тест", width: 20, height: 10)

        let lathe = Machine(name: "Токарный 1", type: .lathe,    position: CGPoint(x: 5, y: 5))
        let mill  = Machine(name: "Фрезерный 1", type: .milling, position: CGPoint(x: 15, y: 5))
        workshop.machines = [lathe, mill]

        let part = Part(name: "Вал", material: "Сталь 45")

        let op1 = Operation(name: "Токарная черновая", type: .turning)
        op1.machineID = lathe.id
        // Задаём параметры резания явно
        var tp = TurningParameters()
        tp.diameter = 50; tp.length = 100; tp.cuttingSpeed = 80; tp.feed = 0.3; tp.depthOfCut = 1.0
        op1.cuttingParameters = .turning(tp)
        op1.auxiliaryTime = 2.0

        let op2 = Operation(name: "Фрезерная", type: .milling)
        op2.machineID = mill.id
        op2.cuttingParameters = nil   // ручное время
        op2.machineTime = 8.0
        op2.auxiliaryTime = 1.5

        part.operations = [op1, op2]

        let result = TimeCalculator.calculate(part: part, workshop: workshop)
        XCTAssertGreaterThan(result.totalMachiningTime, 0)
        XCTAssertGreaterThan(result.totalTransportTime, 0)
        XCTAssertEqual(result.grandTotal,
                       result.totalMachiningTime + result.totalTransportTime + result.totalSetupTime,
                       accuracy: 0.001)
    }

    func testEmptyPart() {
        let workshop = Workshop(name: "Тест", width: 10, height: 10)
        let part = Part(name: "Пустая деталь")
        let result = TimeCalculator.calculate(part: part, workshop: workshop)
        XCTAssertEqual(result.grandTotal, 0)
    }
}
