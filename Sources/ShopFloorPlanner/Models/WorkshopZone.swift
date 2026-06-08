import Foundation
import CoreGraphics

enum ZoneType: String, CaseIterable, Codable {
    case workArea    = "Рабочая зона"
    case storage     = "Склад"
    case passage     = "Проход"
    case loading     = "Зона погрузки"
    case scrap       = "Отходы"
}

struct WorkshopZone: Identifiable, Codable {
    let id: UUID
    var name: String
    var type: ZoneType
    var rect: CGRect

    init(name: String, type: ZoneType, rect: CGRect) {
        self.id   = UUID()
        self.name = name
        self.type = type
        self.rect = rect
    }

    enum CodingKeys: CodingKey {
        case id, name, type, x, y, w, h
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id   = try c.decode(UUID.self,     forKey: .id)
        name = try c.decode(String.self,   forKey: .name)
        type = try c.decode(ZoneType.self, forKey: .type)
        let x = try c.decode(Double.self, forKey: .x)
        let y = try c.decode(Double.self, forKey: .y)
        let w = try c.decode(Double.self, forKey: .w)
        let h = try c.decode(Double.self, forKey: .h)
        rect = CGRect(x: x, y: y, width: w, height: h)
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id,          forKey: .id)
        try c.encode(name,        forKey: .name)
        try c.encode(type,        forKey: .type)
        try c.encode(rect.origin.x,    forKey: .x)
        try c.encode(rect.origin.y,    forKey: .y)
        try c.encode(rect.size.width,  forKey: .w)
        try c.encode(rect.size.height, forKey: .h)
    }
}
