import Foundation

class Part: ObservableObject, Identifiable, Codable {
    let id: UUID
    @Published var name: String
    @Published var material: String
    @Published var blankWeight: Double    // кг
    @Published var finishedWeight: Double // кг
    @Published var operations: [Operation] = []

    init(name: String, material: String = "Сталь 45", blankWeight: Double = 1.0, finishedWeight: Double = 0.8) {
        self.id             = UUID()
        self.name           = name
        self.material       = material
        self.blankWeight    = blankWeight
        self.finishedWeight = finishedWeight
    }

    var totalMachiningTime: Double {
        operations.reduce(0) { $0 + $1.totalTime }
    }

    // MARK: - Codable
    enum CodingKeys: CodingKey {
        case id, name, material, blankWeight, finishedWeight, operations
    }

    required init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id             = try c.decode(UUID.self,        forKey: .id)
        name           = try c.decode(String.self,      forKey: .name)
        material       = try c.decode(String.self,      forKey: .material)
        blankWeight    = try c.decode(Double.self,      forKey: .blankWeight)
        finishedWeight = try c.decode(Double.self,      forKey: .finishedWeight)
        operations     = try c.decode([Operation].self, forKey: .operations)
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id,             forKey: .id)
        try c.encode(name,           forKey: .name)
        try c.encode(material,       forKey: .material)
        try c.encode(blankWeight,    forKey: .blankWeight)
        try c.encode(finishedWeight, forKey: .finishedWeight)
        try c.encode(operations,     forKey: .operations)
    }
}
