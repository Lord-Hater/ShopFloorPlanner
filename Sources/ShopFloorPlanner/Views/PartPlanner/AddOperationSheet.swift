import SwiftUI

struct AddOperationSheet: View {
    @ObservedObject var part: Part
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    @State private var name = ""
    @State private var type: OperationType = .turning
    @State private var machineID: UUID? = nil
    @State private var machineTime = 5.0
    @State private var auxiliaryTime = 1.0

    private var compatibleMachines: [Machine] {
        (store.workshop?.machines ?? []).filter { $0.type.compatibleOperationType == type }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Добавить операцию")
                .font(.title2.bold())

            TextField("Название (например: Токарная черновая)", text: $name)
                .textFieldStyle(.roundedBorder)

            Picker("Тип операции", selection: $type) {
                ForEach(OperationType.allCases, id: \.self) { t in
                    Text(t.rawValue).tag(t)
                }
            }
            .onChange(of: type) { _, newType in
                Task { @MainActor in
                    machineID = nil
                    if name.isEmpty { name = newType.rawValue }
                }
            }

            Picker("Станок", selection: $machineID) {
                Text("— Не назначен —").tag(UUID?.none)
                ForEach(compatibleMachines) { m in
                    Text("\(m.type.icon) \(m.name)").tag(Optional(m.id))
                }
            }
            .disabled(compatibleMachines.isEmpty)

            if compatibleMachines.isEmpty && !(store.workshop?.machines.isEmpty ?? true) {
                Label("Нет совместимых станков для этого типа операции", systemImage: "exclamationmark.triangle")
                    .font(.caption)
                    .foregroundStyle(.orange)
            }

            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Машинное время (мин)").font(.caption)
                    TextField("", value: $machineTime, format: .number)
                        .textFieldStyle(.roundedBorder)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("Вспомогательное (мин)").font(.caption)
                    TextField("", value: $auxiliaryTime, format: .number)
                        .textFieldStyle(.roundedBorder)
                }
            }

            HStack {
                Button("Отмена") { dismiss() }
                    .keyboardShortcut(.escape)
                Spacer()
                Button("Добавить") {
                    let op = Operation(
                        name: name.isEmpty ? type.rawValue : name,
                        type: type,
                        machineTime: machineTime,
                        auxiliaryTime: auxiliaryTime
                    )
                    op.machineID = machineID
                    part.operations.append(op)
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .keyboardShortcut(.return)
            }
        }
        .padding(24)
        .frame(width: 420)
        .onAppear {
            // Авто-выбор первого совместимого станка
            machineID = compatibleMachines.first?.id
        }
    }
}
