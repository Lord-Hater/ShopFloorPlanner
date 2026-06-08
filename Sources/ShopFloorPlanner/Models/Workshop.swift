import Foundation
import CoreGraphics

class Workshop: ObservableObject, Identifiable, Codable {
    let id: UUID
    @Published var name: String
    /// Размеры цеха в метрах
    @Published var width: Double
    @Published var height: Double
    @Published var machines: [Machine] = []
    @Published var zones: [WorkshopZone] = []

    init(name: String, width: Double, height: Double) {
        self.id = UUID()
        self.name = name
        self.width = width
        self.height = height
    }

    func machine(by id: UUID) -> Machine? {
        machines.first { $0.id == id }
    }

    // MARK: - Codable
    enum CodingKeys: CodingKey {
        case id, name, width, height, machines, zones
    }

    required init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id       = try c.decode(UUID.self,    forKey: .id)
        name     = try c.decode(String.self,  forKey: .name)
        width    = try c.decode(Double.self,  forKey: .width)
        height   = try c.decode(Double.self,  forKey: .height)
        machines = try c.decode([Machine].self, forKey: .machines)
        zones    = try c.decode([WorkshopZone].self, forKey: .zones)
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id,       forKey: .id)
        try c.encode(name,     forKey: .name)
        try c.encode(width,    forKey: .width)
        try c.encode(height,   forKey: .height)
        try c.encode(machines, forKey: .machines)
        try c.encode(zones,    forKey: .zones)
    }
}
