import SwiftUI

struct OperationDetailView: View {
    @ObservedObject var operation: Operation
    @ObservedObject var part: Part
    @EnvironmentObject var store: AppStore

    private var compatibleMachines: [Machine] {
        store.workshop.machines.filter { machine in
            machine.type.compatibleOperationType == operation.type
        }
    }

    var body: some View {
        ScrollView {
            Form {
                Section("Основное") {
                    TextField("Название операции", text: $operation.name)
                    Picker("Тип операции", selection: $operation.type) {
                        ForEach(OperationType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                }

                Section("Станок") {
                    if compatibleMachines.isEmpty {
                        Label("Нет совместимых станков на схеме", systemImage: "exclamationmark.triangle")
                            .foregroundStyle(.orange)
                            .font(.caption)
                    } else {
                        Picker("Назначить станок", selection: $operation.machineID) {
                            Text("— Не назначен —").tag(UUID?.none)
                            ForEach(compatibleMachines) { machine in
                                HStack {
                                    Text(machine.type.icon)
                                    Text(machine.name)
                                }
                                .tag(Optional(machine.id))
                            }
                        }
                    }

                    if let machineID = operation.machineID,
                       let machine = store.workshop.machine(by: machineID) {
                        MachineInfoRow(machine: machine)
                    }
                }

                Section("Время (минуты)") {
                    LabeledContent("Машинное время") {
                        HStack {
                            Slider(value: $operation.machineTime, in: 0.1...120, step: 0.5)
                            TextField("", value: $operation.machineTime, format: .number.precision(.fractionLength(1)))
                                .textFieldStyle(.roundedBorder)
                                .frame(width: 64)
                        }
                    }

                    LabeledContent("Вспомогательное время") {
                        HStack {
                            Slider(value: $operation.auxiliaryTime, in: 0...30, step: 0.5)
                            TextField("", value: $operation.auxiliaryTime, format: .number.precision(.fractionLength(1)))
                                .textFieldStyle(.roundedBorder)
                                .frame(width: 64)
                        }
                    }

                    Toggle("Задать переналадку вручную", isOn: Binding(
                        get: { operation.setupTimeOverride != nil },
                        set: { on in operation.setupTimeOverride = on ? 15.0 : nil }
                    ))

                    if operation.setupTimeOverride != nil {
                        LabeledContent("Время переналадки") {
                            HStack {
                                Slider(value: Binding(
                                    get: { operation.setupTimeOverride ?? 0 },
                                    set: { operation.setupTimeOverride = $0 }
                                ), in: 0...120, step: 1)
                                TextField("", value: Binding(
                                    get: { operation.setupTimeOverride ?? 0 },
                                    set: { operation.setupTimeOverride = $0 }
                                ), format: .number.precision(.fractionLength(0)))
                                    .textFieldStyle(.roundedBorder)
                                    .frame(width: 64)
                            }
                        }
                    }
                }

                Section("Итого по операции") {
                    timeSummaryRow("Машинное + вспомогательное", value: operation.operativeTime)
                    if let override = operation.setupTimeOverride {
                        timeSummaryRow("Переналадка (вручную)", value: override)
                    } else if let machineID = operation.machineID,
                              let machine = store.workshop.machine(by: machineID) {
                        timeSummaryRow("Переналадка (со станка)", value: machine.setupTime)
                    }
                    Divider()
                    timeSummaryRow("Штучное время", value: operation.totalTime, bold: true)
                }

                if !operation.notes.isEmpty || true {
                    Section("Примечания") {
                        TextEditor(text: $operation.notes)
                            .frame(minHeight: 60)
                    }
                }
            }
            .formStyle(.grouped)
        }
        .navigationTitle(operation.name)
    }

    private func timeSummaryRow(_ label: String, value: Double, bold: Bool = false) -> some View {
        LabeledContent(label) {
            Text(String(format: "%.1f мин", value))
                .monospacedDigit()
                .fontWeight(bold ? .semibold : .regular)
        }
    }
}

struct MachineInfoRow: View {
    @ObservedObject var machine: Machine

    var body: some View {
        HStack(spacing: 8) {
            Text(machine.type.icon)
            VStack(alignment: .leading, spacing: 2) {
                Text(machine.name).font(.caption.bold())
                Text(String(format: "Перенал.: %.0f мин · Загрузка: %.0f%%",
                            machine.setupTime, machine.utilizationRate * 100))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 2)
    }
}
