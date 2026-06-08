import Foundation

extension MachineType {
    /// Тип операции, совместимый с данным станком
    var compatibleOperationType: OperationType {
        switch self {
        case .lathe:      return .turning
        case .milling:    return .milling
        case .drilling:   return .drilling
        case .grinding:   return .grinding
        case .welding:    return .welding
        case .press:      return .pressing
        case .sawing:     return .sawing
        case .inspection: return .inspection
        case .storage:    return .transport
        }
    }
}

extension OperationType {
    /// Совместимые типы станков для данной операции
    var compatibleMachineTypes: [MachineType] {
        MachineType.allCases.filter { $0.compatibleOperationType == self }
    }
}
