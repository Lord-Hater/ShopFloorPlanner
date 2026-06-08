import SwiftUI

// MARK: - Public entry point

struct GanttView: View {
    let rows: [GanttRow]
    let totalTime: Double

    private let rowHeight: CGFloat = 36
    private let labelWidth: CGFloat = 180
    private let timeAxisHeight: CGFloat = 28
    private let minPxPerMin: CGFloat = 4
    private let maxPxPerMin: CGFloat = 60

    @State private var scale: CGFloat = 12  // px per minute
    @State private var hoveredSegmentID: UUID?

    var body: some View {
        VStack(spacing: 0) {
            scaleControl
            Divider()
            if rows.isEmpty {
                emptyState
            } else {
                ScrollView([.horizontal, .vertical]) {
                    HStack(alignment: .top, spacing: 0) {
                        labelColumn
                        chartArea
                    }
                }
            }
        }
    }

    // MARK: - Scale toolbar

    private var scaleControl: some View {
        HStack(spacing: 12) {
            Image(systemName: "minus.magnifyingglass")
                .foregroundStyle(.secondary)
            Slider(value: $scale, in: minPxPerMin...maxPxPerMin, step: 2)
                .frame(width: 140)
            Image(systemName: "plus.magnifyingglass")
                .foregroundStyle(.secondary)
            Spacer()
            legend
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
    }

    // MARK: - Legend

    private var legend: some View {
        HStack(spacing: 12) {
            ForEach(GanttSegment.SegmentKind.allCases, id: \.self) { kind in
                HStack(spacing: 4) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(kind.color)
                        .frame(width: 14, height: 10)
                    Text(kind.label).font(.caption2).foregroundStyle(.secondary)
                }
            }
        }
    }

    // MARK: - Empty state

    private var emptyState: some View {
        ContentUnavailableView(
            "Нет операций",
            systemImage: "chart.bar",
            description: Text("Добавьте операции к детали и назначьте станки")
        )
    }

    // MARK: - Label column (frozen left)

    private var labelColumn: some View {
        VStack(spacing: 0) {
            // Заголовок над временной осью
            Color.clear.frame(width: labelWidth, height: timeAxisHeight)
            Divider()
            ForEach(rows) { row in
                RowLabel(row: row, height: rowHeight)
                Divider()
            }
        }
        .frame(width: labelWidth)
        .background(Color(nsColor: .controlBackgroundColor))
        .overlay(alignment: .trailing) {
            Divider()
        }
    }

    // MARK: - Chart area

    private var chartArea: some View {
        let chartWidth = CGFloat(totalTime) * scale + 40

        return VStack(spacing: 0) {
            TimeAxis(totalTime: totalTime, scale: scale, width: chartWidth, height: timeAxisHeight)
            Divider()
            ZStack(alignment: .topLeading) {
                // Вертикальные сетки времени
                TimeGrid(totalTime: totalTime, scale: scale, rowCount: rows.count,
                         rowHeight: rowHeight, width: chartWidth)

                // Строки
                VStack(spacing: 0) {
                    ForEach(rows) { row in
                        RowBars(row: row, scale: scale, height: rowHeight,
                                hoveredID: $hoveredSegmentID)
                        Divider()
                    }
                }
            }
        }
        .frame(width: chartWidth)
    }
}

// MARK: - Row label

private struct RowLabel: View {
    let row: GanttRow
    let height: CGFloat

    var body: some View {
        HStack(spacing: 6) {
            RoundedRectangle(cornerRadius: 2)
                .fill(opColor)
                .frame(width: 4, height: height * 0.6)

            VStack(alignment: .leading, spacing: 1) {
                Text(row.operationName)
                    .font(.caption.bold())
                    .lineLimit(1)
                Text(row.machineName)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 8)
        .frame(height: height)
    }

    private var opColor: Color {
        switch row.operationType {
        case .turning:    return .blue
        case .milling:    return .purple
        case .drilling:   return .cyan
        case .grinding:   return .orange
        case .welding:    return .red
        case .pressing:   return .indigo
        case .sawing:     return .brown
        case .inspection: return .green
        case .transport:  return .gray
        }
    }
}

// MARK: - Time axis

private struct TimeAxis: View {
    let totalTime: Double
    let scale: CGFloat
    let width: CGFloat
    let height: CGFloat

    private var tickInterval: Double {
        let targetPixels: Double = 60
        let raw = targetPixels / Double(scale)
        let magnitudes = [1.0, 2.0, 5.0, 10.0, 15.0, 30.0, 60.0]
        return magnitudes.first { $0 >= raw } ?? 60
    }

    var body: some View {
        Canvas { ctx, size in
            var t = 0.0
            while t <= totalTime + tickInterval {
                let x = CGFloat(t) * scale
                // Tick
                let tick = Path { p in
                    p.move(to: CGPoint(x: x, y: size.height - 6))
                    p.addLine(to: CGPoint(x: x, y: size.height))
                }
                ctx.stroke(tick, with: .color(.secondary.opacity(0.5)), lineWidth: 1)

                // Label
                let label = formatTime(t)
                ctx.draw(Text(label).font(.system(size: 9)).foregroundStyle(.secondary),
                         at: CGPoint(x: x, y: size.height / 2 - 4),
                         anchor: .center)
                t += tickInterval
            }
        }
        .frame(width: width, height: height)
        .background(Color(nsColor: .controlBackgroundColor))
    }

    private func formatTime(_ minutes: Double) -> String {
        if minutes < 60 { return "\(Int(minutes))м" }
        let h = Int(minutes / 60); let m = Int(minutes) % 60
        return m == 0 ? "\(h)ч" : "\(h)ч\(m)м"
    }
}

// MARK: - Time grid

private struct TimeGrid: View {
    let totalTime: Double
    let scale: CGFloat
    let rowCount: Int
    let rowHeight: CGFloat
    let width: CGFloat

    var body: some View {
        Canvas { ctx, size in
            var t = 0.0
            let interval: Double = 5
            while t <= totalTime {
                let x = CGFloat(t) * scale
                let path = Path { p in
                    p.move(to: CGPoint(x: x, y: 0))
                    p.addLine(to: CGPoint(x: x, y: size.height))
                }
                ctx.stroke(path, with: .color(.gray.opacity(t.truncatingRemainder(dividingBy: 10) == 0 ? 0.2 : 0.08)),
                           lineWidth: 1)
                t += interval
            }
        }
        .frame(width: width, height: CGFloat(rowCount) * rowHeight)
        .allowsHitTesting(false)
    }
}

// MARK: - Row bars

private struct RowBars: View {
    let row: GanttRow
    let scale: CGFloat
    let height: CGFloat
    @Binding var hoveredID: UUID?

    var body: some View {
        ZStack(alignment: .leading) {
            Color(nsColor: .textBackgroundColor)

            ForEach(row.segments) { seg in
                SegmentBar(segment: seg, scale: scale, height: height,
                           isHovered: hoveredID == seg.id)
                    .onHover { inside in
                        hoveredID = inside ? seg.id : nil
                    }
                    .offset(x: CGFloat(seg.start) * scale)
            }
        }
        .frame(height: height)
    }
}

// MARK: - Segment bar

private struct SegmentBar: View {
    let segment: GanttSegment
    let scale: CGFloat
    let height: CGFloat
    let isHovered: Bool

    private var barWidth: CGFloat {
        max(2, CGFloat(segment.duration) * scale)
    }
    private var barHeight: CGFloat { height * 0.65 }

    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 4)
                .fill(segment.kind.color.opacity(isHovered ? 1 : 0.8))
                .frame(width: barWidth, height: barHeight)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .strokeBorder(segment.kind.color, lineWidth: isHovered ? 1.5 : 0)
                )

            if barWidth > 28 {
                Text(String(format: "%.1fм", segment.duration))
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 4)
                    .lineLimit(1)
            }
        }
        .frame(height: height, alignment: .center)
        .popover(isPresented: .constant(isHovered), arrowEdge: .bottom) {
            SegmentTooltip(segment: segment)
        }
    }
}

// MARK: - Tooltip

private struct SegmentTooltip: View {
    let segment: GanttSegment

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Label(segment.kind.label, systemImage: iconName)
                .font(.caption.bold())
            Divider()
            Grid(alignment: .leading, horizontalSpacing: 12, verticalSpacing: 3) {
                GridRow {
                    Text("Начало:").font(.caption2).foregroundStyle(.secondary)
                    Text(formatTime(segment.start)).font(.caption2.monospacedDigit())
                }
                GridRow {
                    Text("Конец:").font(.caption2).foregroundStyle(.secondary)
                    Text(formatTime(segment.end)).font(.caption2.monospacedDigit())
                }
                GridRow {
                    Text("Длит.:").font(.caption2).foregroundStyle(.secondary)
                    Text(formatTime(segment.duration)).font(.caption2.monospacedDigit().bold())
                }
            }
        }
        .padding(10)
        .frame(minWidth: 140)
    }

    private var iconName: String {
        switch segment.kind {
        case .transport:  return "arrow.right.circle"
        case .setup:      return "wrench"
        case .machining:  return "gearshape"
        case .auxiliary:  return "hand.raised"
        }
    }

    private func formatTime(_ m: Double) -> String {
        if m < 60 { return String(format: "%.2f мин", m) }
        return String(format: "%d ч %.1f мин", Int(m / 60), m.truncatingRemainder(dividingBy: 60))
    }
}
