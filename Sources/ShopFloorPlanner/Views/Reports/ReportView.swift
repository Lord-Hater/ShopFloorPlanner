import SwiftUI

struct ReportView: View {
    @EnvironmentObject var store: AppStore

    var body: some View {
        if let part = store.selectedPart as Part? {
            ManufacturingReportView(part: part)
        } else {
            ContentUnavailableView(
                "Выберите деталь",
                systemImage: "chart.bar.doc.horizontal",
                description: Text("Перейдите в раздел «Детали» и выберите деталь для расчёта")
            )
        }
    }
}

struct ManufacturingReportView: View {
    let part: Part
    @EnvironmentObject var store: AppStore

    private var result: ManufacturingTimeResult {
        TimeCalculator.calculate(part: part, workshop: store.workshop)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Итоговая карточка
                summaryCard

                // Таблица операций
                operationsTable

                // Маршрут
                routeSection
            }
            .padding()
        }
        .navigationTitle("Отчёт: \(part.name)")
    }

    private var summaryCard: some View {
        GroupBox("Итого") {
            Grid(alignment: .leading, horizontalSpacing: 24, verticalSpacing: 8) {
                GridRow {
                    timeRow("Обработка", minutes: result.totalMachiningTime, color: .blue)
                }
                GridRow {
                    timeRow("Переналадка", minutes: result.totalSetupTime, color: .orange)
                }
                GridRow {
                    timeRow("Транспортировка", minutes: result.totalTransportTime, color: .green)
                }
                Divider()
                GridRow {
                    timeRow("ИТОГО", minutes: result.grandTotal, color: .primary, bold: true)
                }
            }
        }
    }

    private func timeRow(_ label: String, minutes: Double, color: Color, bold: Bool = false) -> some View {
        HStack {
            Text(label)
                .fontWeight(bold ? .bold : .regular)
                .foregroundStyle(color)
                .frame(width: 160, alignment: .leading)
            Text(formatTime(minutes))
                .monospacedDigit()
                .fontWeight(bold ? .bold : .regular)
        }
    }

    private var operationsTable: some View {
        GroupBox("Операции") {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Операция").frame(maxWidth: .infinity, alignment: .leading)
                    Text("Станок").frame(width: 140, alignment: .leading)
                    Text("Маш.").frame(width: 60, alignment: .trailing)
                    Text("Вспом.").frame(width: 60, alignment: .trailing)
                    Text("Налад.").frame(width: 60, alignment: .trailing)
                    Text("Трансп.").frame(width: 70, alignment: .trailing)
                    Text("Итого").frame(width: 70, alignment: .trailing)
                }
                .font(.caption.bold())
                .foregroundStyle(.secondary)
                .padding(.vertical, 6)
                .padding(.horizontal, 8)

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
                    .font(.caption)
                    .padding(.vertical, 5)
                    .padding(.horizontal, 8)
                    Divider()
                }
            }
        }
    }

    private var routeSection: some View {
        let steps = RouteOptimizer.buildRoute(part: part, workshop: store.workshop)
        return GroupBox("Маршрут по цеху") {
            VStack(alignment: .leading, spacing: 6) {
                ForEach(steps.indices, id: \.self) { i in
                    HStack {
                        Image(systemName: "arrow.right.circle.fill")
                            .foregroundStyle(.blue)
                        Text(steps[i].label)
                        Spacer()
                        Text(String(format: "%.1f м", steps[i].distanceMeters))
                            .monospacedDigit()
                            .foregroundStyle(.secondary)
                        Text(fmt(steps[i].timeMinutes))
                            .monospacedDigit()
                    }
                    .font(.caption)
                }
                Divider()
                HStack {
                    Text("Общий путь:")
                        .fontWeight(.semibold)
                    Spacer()
                    Text(String(format: "%.1f м", RouteOptimizer.totalDistance(steps: steps)))
                        .monospacedDigit()
                        .fontWeight(.semibold)
                }
                .font(.caption)
            }
        }
    }

    private func fmt(_ minutes: Double) -> String {
        String(format: "%.1f мин", minutes)
    }

    private func formatTime(_ minutes: Double) -> String {
        if minutes < 60 {
            return String(format: "%.1f мин", minutes)
        }
        let h = Int(minutes / 60)
        let m = minutes.truncatingRemainder(dividingBy: 60)
        return String(format: "%d ч %.0f мин", h, m)
    }
}
