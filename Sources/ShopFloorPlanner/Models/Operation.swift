import Foundation

enum OperationType: String, CaseIterable, Codable {
    case turning      = "Токарная"
    case milling      = "Фрезерная"
    case drilling     = "Сверлильная"
    case grinding     = "Шлифовальная"
    case welding      = "Сварочная"
    case pressing     = "Прессовая"
    case sawing       = "Отрезная"
    case inspection   = "Контроль"
    case transport    = "Транспортировка"
}

class Operation: ObservableObject, Identifiable, Codable {
    let id: UUID
    @Published var name: String
    @Published var type: OperationType
    @Published var machineID: UUID?       // к какому станку привязана
    /// Основное машинное время (мин)
    @Published var machineTime: Double
    /// Вспомогательное время (мин)
    @Published var auxiliaryTime: Double
    /// Время переналадки (мин, перезаписывает станочное если задано)
    @Published var setupTimeOverride: Double?
    /// Примечания
    @Published var notes: String

    init(name: String, type: OperationType, machineTime: Double = 5.0, auxiliaryTime: Double = 1.0) {
        self.id            = UUID()
        self.name          = name
        self.type          = type
        self.machineTime   = machineTime
        self.auxiliaryTime = auxiliaryTime
        self.notes         = ""
    }

    /// Оперативное время = машинное + вспомогательное
    var operativeTime: Double { machineTime + auxiliaryTime }

    /// Полное штучное время (без переналадки)
    var totalTime: Double { operativeTime }

    // MARK: - Codable
    enum CodingKeys: CodingKey {
        case id, name, type, machineID, machineTime, auxiliaryTime, setupTimeOverride, notes
    }

    required init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id                 = try c.decode(UUID.self,          forKey: .id)
        name               = try c.decode(String.self,        forKey: .name)
        type               = try c.decode(OperationType.self, forKey: .type)
        machineID          = try c.decodeIfPresent(UUID.self,   forKey: .machineID)
        machineTime        = try c.decode(Double.self,        forKey: .machineTime)
        auxiliaryTime      = try c.decode(Double.self,        forKey: .auxiliaryTime)
        setupTimeOverride  = try c.decodeIfPresent(Double.self, forKey: .setupTimeOverride)
        notes              = try c.decode(String.self,        forKey: .notes)
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id,                forKey: .id)
        try c.encode(name,              forKey: .name)
        try c.encode(type,              forKey: .type)
        try c.encodeIfPresent(machineID, forKey: .machineID)
        try c.encode(machineTime,       forKey: .machineTime)
        try c.encode(auxiliaryTime,     forKey: .auxiliaryTime)
        try c.encodeIfPresent(setupTimeOverride, forKey: .setupTimeOverride)
        try c.encode(notes,             forKey: .notes)
    }
}
