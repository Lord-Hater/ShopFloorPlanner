import Foundation
import CoreGraphics

enum MachineType: String, CaseIterable, Codable {
    case lathe        = "Токарный станок"
    case milling      = "Фрезерный станок"
    case drilling     = "Сверлильный станок"
    case grinding     = "Шлифовальный станок"
    case welding      = "Сварочный пост"
    case press        = "Пресс"
    case sawing       = "Отрезной станок"
    case inspection   = "Контрольный стол"
    case storage      = "Склад / стеллаж"

    var icon: String {
        switch self {
        case .lathe:      return "⚙️"
        case .milling:    return "🔩"
        case .drilling:   return "🔧"
        case .grinding:   return "💠"
        case .welding:    return "🔥"
        case .press:      return "🏋️"
        case .sawing:     return "🪚"
        case .inspection: return "🔍"
        case .storage:    return "📦"
        }
    }

    /// Размер по умолчанию (ширина x глубина в метрах)
    var defaultSize: CGSize {
        switch self {
        case .lathe:      return CGSize(width: 2.5, height: 1.2)
        case .milling:    return CGSize(width: 2.0, height: 1.5)
        case .drilling:   return CGSize(width: 0.8, height: 0.8)
        case .grinding:   return CGSize(width: 2.0, height: 1.0)
        case .welding:    return CGSize(width: 1.5, height: 1.5)
        case .press:      return CGSize(width: 1.2, height: 1.2)
        case .sawing:     return CGSize(width: 1.5, height: 0.8)
        case .inspection: return CGSize(width: 1.2, height: 0.8)
        case .storage:    return CGSize(width: 3.0, height: 1.0)
        }
    }
}

class Machine: ObservableObject, Identifiable, Codable {
    let id: UUID
    @Published var name: String
    @Published var type: MachineType
    /// Позиция центра станка в метрах (от левого нижнего угла цеха)
    @Published var position: CGPoint
    @Published var size: CGSize
    /// Угол поворота в радианах
    @Published var rotation: Double
    /// Коэффициент использования (0...1)
    @Published var utilizationRate: Double
    /// Время переналадки в минутах
    @Published var setupTime: Double

    init(name: String, type: MachineType, position: CGPoint) {
        self.id             = UUID()
        self.name           = name
        self.type           = type
        self.position       = position
        self.size           = type.defaultSize
        self.rotation       = 0
        self.utilizationRate = 0.75
        self.setupTime      = 15
    }

    // MARK: - Codable
    enum CodingKeys: CodingKey {
        case id, name, type, positionX, positionY, sizeW, sizeH, rotation, utilizationRate, setupTime
    }

    required init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id              = try c.decode(UUID.self,        forKey: .id)
        name            = try c.decode(String.self,      forKey: .name)
        type            = try c.decode(MachineType.self, forKey: .type)
        let x           = try c.decode(Double.self,      forKey: .positionX)
        let y           = try c.decode(Double.self,      forKey: .positionY)
        position        = CGPoint(x: x, y: y)
        let w           = try c.decode(Double.self,      forKey: .sizeW)
        let h           = try c.decode(Double.self,      forKey: .sizeH)
        size            = CGSize(width: w, height: h)
        rotation        = try c.decode(Double.self,      forKey: .rotation)
        utilizationRate = try c.decode(Double.self,      forKey: .utilizationRate)
        setupTime       = try c.decode(Double.self,      forKey: .setupTime)
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id,              forKey: .id)
        try c.encode(name,            forKey: .name)
        try c.encode(type,            forKey: .type)
        try c.encode(position.x,      forKey: .positionX)
        try c.encode(position.y,      forKey: .positionY)
        try c.encode(size.width,      forKey: .sizeW)
        try c.encode(size.height,     forKey: .sizeH)
        try c.encode(rotation,        forKey: .rotation)
        try c.encode(utilizationRate, forKey: .utilizationRate)
        try c.encode(setupTime,       forKey: .setupTime)
    }
}
