import SwiftUI

struct ReportView: View {
    @EnvironmentObject var store: AppStore

    var body: some View {
        if let part = store.selectedPart, let workshop = store.workshop {
            ManufacturingReportView(part: part, workshop: workshop)
        } else {
            ContentUnavailableView(
                "Выберите деталь",
                systemImage: "chart.bar.doc.horizontal",
                description: Text("Перейдите в раздел «Детали» и выберите деталь для расчёта")
            )
        }
    }
}

// MARK: - Main report view

struct ManufacturingReportView: View {
    let part: Part
    let workshop: Workshop
    @State private var selectedTab: ReportTab = .table

    enum ReportTab: String, CaseIterable {
        case table = "Таблица"
        case gantt = "Диаграмма Ганта"
        case route = "Маршрут"
    }

    private var result: ManufacturingTimeResult {
        TimeCalculator.calculate(part: part, workshop: workshop)
    }

    private var ganttRows: [GanttRow] {
        GanttBuilder.build(part: part, workshop: workshop)
    }

    var body: some View {
        VStack(spacing: 0) {
            summaryCard.padding()
            Divider()

            Picker("", selection: $selectedTab) {
                ForEach(ReportTab.allCases, id: \.self) { Text($0.rawValue).tag($0) }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.vertical, 8)

            Divider()

            switch selectedTab {
            case .table:
                ScrollView {
                    operationsTable.padding()
                }
            case .gantt:
                GanttView(rows: ganttRows, totalTime: max(result.grandTotal, 1))
            case .route:
                ScrollView {
                    routeSection.padding()
                }
            }
        }
        .navigationTitle("Отчёт: \(part.name)")
    }

    // MARK: - Summary card

    private var summaryCard: some View {
        GroupBox("Итого") {
            Grid(alignment: .leading, horizontalSpacing: 24, verticalSpacing: 8) {
                GridRow { timeRow("Обработка",       minutes: result.totalMachiningTime, color: .blue) }
                GridRow { timeRow("Переналадка",     minutes: result.totalSetupTime,     color: .orange) }
                GridRow { timeRow("Транспортировка", minutes: result.totalTransportTime, color: .green) }
                Divider()
                GridRow { timeRow("ИТОГО", minutes: result.grandTotal, color: .primary, bold: true) }
            }
        }
    }

    private func timeRow(_ label: String, minutes: Double, color: Color, bold: Bool = false) -> some View {
        HStack {
            Text(label).fontWeight(bold ? .bold : .regular).foregroundStyle(color)
                .frame(width: 160, alignment: .leading)
            Text(formatTime(minutes)).monospacedDigit().fontWeight(bold ? .bold : .regular)
        }
    }

    // MARK: - Operations table

    private var operationsTable: some View {
        GroupBox("Операции") {
            VStack(spacing: 0) {
                HStack {
                    Text("Операция").frame(maxWidth: .infinity, alignment: .leading)
                    Text("Станок").frame(width: 140, alignment: .leading)
                    Text("Маш.").frame(width: 60, alignment: .trailing)
                    Text("Вспом.").frame(width: 60, alignment: .trailing)
                    Text("Налад.").frame(width: 60, alignment: .trailing)
                    Text("Трансп.").frame(width: 70, alignment: .trailing)
                    Text("Итого").frame(width: 70, alignment: .trailing)
                }
                .font(.caption.bold()).foregroundStyle(.secondary)
                .padding(.vertical, 6).padding(.horizontal, 8)
                Divider()
                ForEach(result.operations, id: \.operation.id) { row in
                    HStack {
                        Text(row.operation.name).frame(maxWidth: .infinity, alignment: .leading)
                        Text(row.machineName).frame(width: 140, alignment: .leading)
                        Text(fmt(row.machineTime)).frame(width: 60, alignment: .trailing)
                        Text(fmt(row.auxiliaryTime)).frame(width: 60, alignment: .trailing)
                        Text(fmt(row.setupTime)).frame(width: 60, alignment: .trailing)
                        Text(fmt(row.transportTimeBefore)).frame(width: 70, alignment: .trailing)
                        Text(fmt(row.total)).frame(width: 70, alignment: .trailing).fontWeight(.semibold)
                    }
                    .font(.caption).padding(.vertical, 5).padding(.horizontal, 8)
                    Divider()
                }
            }
        }
    }

    // MARK: - Route section

    private var routeSection: some View {
        let steps = RouteOptimizer.buildRoute(part: part, workshop: workshop)
        return GroupBox("Маршрут по цеху") {
            VStack(alignment: .leading, spacing: 6) {
                ForEach(Array(steps.indices), id: \.self) { i in
                    HStack {
                        Image(systemName: "arrow.right.circle.fill").foregroundStyle(.blue)
                        Text(steps[i].label)
                        Spacer()
                        Text(String(format: "%.1f м", steps[i].distanceMeters))
                            .monospacedDigit().foregroundStyle(.secondary)
                        Text(fmt(steps[i].timeMinutes)).monospacedDigit()
                    }
                    .font(.caption)
                }
                Divider()
                HStack {
                    Text("Общий путь:").fontWeight(.semibold)
                    Spacer()
                    Text(String(format: "%.1f м", RouteOptimizer.totalDistance(steps: steps)))
                        .monospacedDigit().fontWeight(.semibold)
                }
                .font(.caption)
            }
        }
    }

    private func fmt(_ m: Double) -> String { String(format: "%.1f мин", m) }

    private func formatTime(_ m: Double) -> String {
        if m < 60 { return String(format: "%.1f мин", m) }
        return String(format: "%d ч %.0f мин", Int(m / 60), m.truncatingRemainder(dividingBy: 60))
    }
}
