import Foundation

// MARK: - Protocol

protocol CuttingParameters: Codable {
    /// Основное машинное время T₀ (мин)
    func calculateMachineTime() -> Double
    /// Частота вращения шпинделя или детали (об/мин)
    var actualRPM: Double { get }
    /// Фактическая скорость резания (м/мин)
    var actualCuttingSpeed: Double { get }
}

// MARK: - Turning (Токарная)

/// Параметры токарной операции по ГОСТ 3.1404
struct TurningParameters: CuttingParameters, Codable, Equatable {
    // Геометрия
    var diameter: Double = 50        // мм — диаметр обрабатываемой поверхности
    var length: Double = 100         // мм — длина обработки
    var allowance: Double = 2.0      // мм — припуск на сторону
    var approachLength: Double = 2   // мм — врезание (≈ ap / tg φ)
    var overrunLength: Double = 1    // мм — перебег

    // Режимы резания
    var cuttingSpeed: Double = 80    // м/мин — скорость резания V
    var feed: Double = 0.3           // мм/об — подача S
    var depthOfCut: Double = 1.0     // мм — глубина резания ap

    // Проходы
    var useAutoPasses: Bool = true
    var manualPasses: Int = 1

    /// i = ⌈припуск / ap⌉
    var passes: Int {
        useAutoPasses ? max(1, Int(ceil(allowance / depthOfCut))) : manualPasses
    }

    /// n = 1000·V / (π·D)  [об/мин]
    var actualRPM: Double { 1000 * cuttingSpeed / (.pi * diameter) }
    var actualCuttingSpeed: Double { cuttingSpeed }

    /// L = l + l_вр + l_пер
    var totalLength: Double { length + approachLength + overrunLength }

    /// T₀ = L · i / (n · S)
    func calculateMachineTime() -> Double {
        guard actualRPM > 0, feed > 0 else { return 0 }
        return totalLength * Double(passes) / (actualRPM * feed)
    }
}

// MARK: - Milling (Фрезерная)

/// Параметры фрезерной операции по ГОСТ 3.1404
struct MillingParameters: CuttingParameters, Codable, Equatable {
    // Геометрия
    var length: Double = 100         // мм — длина фрезерования
    var approachLength: Double = 5   // мм — врезание ≈ √(D·t - t²)
    var overrunLength: Double = 3    // мм — перебег

    // Фреза
    var toolDiameter: Double = 80    // мм — диаметр фрезы D
    var teethCount: Int = 8          // z — число зубьев
    var feedPerTooth: Double = 0.08  // мм/зуб — подача на зуб Sz
    var cuttingSpeed: Double = 100   // м/мин — скорость резания V
    var depthOfCut: Double = 3.0     // мм — глубина фрезерования t

    /// n = 1000·V / (π·D)
    var actualRPM: Double { 1000 * cuttingSpeed / (.pi * toolDiameter) }
    var actualCuttingSpeed: Double { cuttingSpeed }

    /// Sмин = Sz · z · n  [мм/мин]
    var tableFeedPerMin: Double { feedPerTooth * Double(teethCount) * actualRPM }

    var totalLength: Double { length + approachLength + overrunLength }

    /// T₀ = L / Sмин
    func calculateMachineTime() -> Double {
        guard tableFeedPerMin > 0 else { return 0 }
        return totalLength / tableFeedPerMin
    }
}

// MARK: - Drilling (Сверлильная)

/// Параметры сверлильной операции по ГОСТ 3.1404
struct DrillingParameters: CuttingParameters, Codable, Equatable {
    // Геометрия
    var holeDepth: Double = 30       // мм — глубина сверления
    var toolDiameter: Double = 10    // мм — диаметр сверла D
    var approachLength: Double = 3   // мм — подвод (≈ D/2 · ctg(φ/2), φ=118°)
    var overrunLength: Double = 2    // мм — выход инструмента

    // Режимы
    var cuttingSpeed: Double = 25    // м/мин — скорость резания V
    var feed: Double = 0.15          // мм/об — подача S

    var actualRPM: Double { 1000 * cuttingSpeed / (.pi * toolDiameter) }
    var actualCuttingSpeed: Double { cuttingSpeed }

    var totalLength: Double { holeDepth + approachLength + overrunLength }

    /// T₀ = L / (n · S)
    func calculateMachineTime() -> Double {
        guard actualRPM > 0, feed > 0 else { return 0 }
        return totalLength / (actualRPM * feed)
    }
}

// MARK: - Grinding (Шлифовальная круглая наружная)

/// Параметры круглого наружного шлифования по ГОСТ 3.1404
struct GrindingParameters: CuttingParameters, Codable, Equatable {
    // Геометрия
    var diameter: Double = 50        // мм — диаметр детали
    var length: Double = 80          // мм — длина шлифования
    var allowance: Double = 0.3      // мм — общий припуск на сторону

    // Режимы
    var partSpeed: Double = 30       // м/мин — скорость детали Vд
    var wheelWidth: Double = 40      // мм — ширина шлифовального круга Bк
    /// β — коэффициент перекрытия (доля ширины круга за один оборот детали), 0.2…0.8
    var axialFeedCoeff: Double = 0.4
    var radialFeedPerPass: Double = 0.01 // мм — поперечная подача за проход

    /// n = 1000·Vд / (π·D)  [об/мин]
    var actualRPM: Double { 1000 * partSpeed / (.pi * diameter) }
    var actualCuttingSpeed: Double { partSpeed }

    /// Осевая подача за оборот: Sос = β·Bк  [мм/об]
    var axialFeedPerRev: Double { axialFeedCoeff * wheelWidth }

    /// Число продольных проходов на 1 поперечную подачу: Zпр = l/Sос + 1
    var longitudinalPassesPerRadial: Double {
        (length / axialFeedPerRev) + 1
    }

    /// Число поперечных подач: i = ⌈припуск / t_поп⌉
    var radialPasses: Int { max(1, Int(ceil(allowance / radialFeedPerPass))) }

    /// T₀ = Zпр · i / n  (× 1.2 — коэффициент выхаживания)
    func calculateMachineTime() -> Double {
        guard actualRPM > 0 else { return 0 }
        return longitudinalPassesPerRadial * Double(radialPasses) / actualRPM * 1.2
    }
}

// MARK: - Container (тип операции → нужные параметры)

/// Обёртка для хранения параметров любого типа в Operation
enum CuttingParametersContainer: Codable {
    case turning(TurningParameters)
    case milling(MillingParameters)
    case drilling(DrillingParameters)
    case grinding(GrindingParameters)

    var parameters: any CuttingParameters {
        switch self {
        case .turning(let p):  return p
        case .milling(let p):  return p
        case .drilling(let p): return p
        case .grinding(let p): return p
        }
    }

    var machineTime: Double { parameters.calculateMachineTime() }

    // MARK: Codable
    private enum Tag: String, Codable { case turning, milling, drilling, grinding }
    private enum CodingKeys: String, CodingKey { case tag, value }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let tag = try c.decode(Tag.self, forKey: .tag)
        switch tag {
        case .turning:  self = .turning(try c.decode(TurningParameters.self,  forKey: .value))
        case .milling:  self = .milling(try c.decode(MillingParameters.self,  forKey: .value))
        case .drilling: self = .drilling(try c.decode(DrillingParameters.self, forKey: .value))
        case .grinding: self = .grinding(try c.decode(GrindingParameters.self, forKey: .value))
        }
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .turning(let p):
            try c.encode(Tag.turning,  forKey: .tag); try c.encode(p, forKey: .value)
        case .milling(let p):
            try c.encode(Tag.milling,  forKey: .tag); try c.encode(p, forKey: .value)
        case .drilling(let p):
            try c.encode(Tag.drilling, forKey: .tag); try c.encode(p, forKey: .value)
        case .grinding(let p):
            try c.encode(Tag.grinding, forKey: .tag); try c.encode(p, forKey: .value)
        }
    }
}

// MARK: - Default factory

extension CuttingParametersContainer {
    static func defaultFor(_ type: OperationType) -> CuttingParametersContainer? {
        switch type {
        case .turning:    return .turning(TurningParameters())
        case .milling:    return .milling(MillingParameters())
        case .drilling:   return .drilling(DrillingParameters())
        case .grinding:   return .grinding(GrindingParameters())
        default:          return nil
        }
    }
}
