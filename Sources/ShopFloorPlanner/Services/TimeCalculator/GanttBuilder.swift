import Foundation
import SwiftUI

// MARK: - Data model

struct GanttRow: Identifiable {
    let id: UUID
    let operationName: String
    let machineName: String
    let operationType: OperationType
    let segments: [GanttSegment]

    var start: Double { segments.first?.start ?? 0 }
    var end: Double   { segments.last?.end   ?? 0 }
    var duration: Double { end - start }
}

struct GanttSegment: Identifiable {
    let id = UUID()
    let kind: SegmentKind
    let start: Double  // мин от начала
    let end: Double

    var duration: Double { end - start }

    enum SegmentKind: CaseIterable {
        case transport, setup, machining, auxiliary

        var label: String {
            switch self {
            case .transport:  return "Транспорт"
            case .setup:      return "Переналадка"
            case .machining:  return "Обработка"
            case .auxiliary:  return "Вспом."
            }
        }

        var color: Color {
            switch self {
            case .transport:  return .gray.opacity(0.6)
            case .setup:      return .orange
            case .machining:  return .blue
            case .auxiliary:  return .teal
            }
        }
    }
}

// MARK: - Builder

struct GanttBuilder {

    static func build(part: Part, workshop: Workshop,
                      transportSpeed: Double = 30.0) -> [GanttRow] {
        var rows: [GanttRow] = []
        var cursor: Double = 0  // текущее время (мин)
        var prevPos = CGPoint(x: 0, y: 0)

        for op in part.operations {
            let machine = op.machineID.flatMap { workshop.machine(by: $0) }
            let machineName = machine?.name ?? "Не назначено"

            // Транспортное время
            var transportTime = 0.0
            if let m = machine {
                let d = distance(from: prevPos, to: m.position)
                transportTime = d / transportSpeed
                prevPos = m.position
            }

            // Переналадка
            let setupTime: Double
            if let ov = op.setupTimeOverride {
                setupTime = ov
            } else {
                setupTime = machine?.setupTime ?? 0
            }

            var segments: [GanttSegment] = []

            if transportTime > 0 {
                segments.append(GanttSegment(kind: .transport,
                                             start: cursor,
                                             end: cursor + transportTime))
                cursor += transportTime
            }

            if setupTime > 0 {
                segments.append(GanttSegment(kind: .setup,
                                             start: cursor,
                                             end: cursor + setupTime))
                cursor += setupTime
            }

            let t0 = op.effectiveMachineTime
            if t0 > 0 {
                segments.append(GanttSegment(kind: .machining,
                                             start: cursor,
                                             end: cursor + t0))
                cursor += t0
            }

            if op.auxiliaryTime > 0 {
                segments.append(GanttSegment(kind: .auxiliary,
                                             start: cursor,
                                             end: cursor + op.auxiliaryTime))
                cursor += op.auxiliaryTime
            }

            guard !segments.isEmpty else { continue }

            rows.append(GanttRow(
                id: op.id,
                operationName: op.name,
                machineName: machineName,
                operationType: op.type,
                segments: segments
            ))
        }

        return rows
    }

    private static func distance(from a: CGPoint, to b: CGPoint) -> Double {
        let dx = b.x - a.x; let dy = b.y - a.y
        return sqrt(dx * dx + dy * dy)
    }
}
