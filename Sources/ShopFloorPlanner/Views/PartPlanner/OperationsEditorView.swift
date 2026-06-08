import SwiftUI

struct OperationsEditorView: View {
    @ObservedObject var part: Part
    @EnvironmentObject var store: AppStore
    @State private var selectedOperationID: UUID?
    @State private var showAddOperation = false

    var body: some View {
        HSplitView {
            operationList
                .frame(minWidth: 260, maxWidth: 340)

            if let opID = selectedOperationID,
               let op = part.operations.first(where: { $0.id == opID }) {
                OperationDetailView(operation: op, part: part)
            } else {
                ContentUnavailableView(
                    "Операция не выбрана",
                    systemImage: "wrench.and.screwdriver",
                    description: Text("Добавьте операцию или выберите из списка")
                )
            }
        }
        .sheet(isPresented: $showAddOperation) {
            AddOperationSheet(part: part)
        }
    }

    private var operationList: some View {
        VStack(spacing: 0) {
            // Заголовок детали
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(part.name).font(.headline)
                        Text(part.material).font(.caption).foregroundStyle(.secondary)
                    }
                    Spacer()
                    Button {
                        showAddOperation = true
                    } label: {
                        Label("Операция", systemImage: "plus")
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                }

                HStack(spacing: 16) {
                    Label(String(format: "%.2f кг → %.2f кг", part.blankWeight, part.finishedWeight),
                          systemImage: "scalemass")
                    Label(formatTime(part.totalMachiningTime), systemImage: "clock")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            .padding(12)

            Divider()

            // Список операций с drag-to-reorder
            List(selection: $selectedOperationID) {
                ForEach(part.operations) { op in
                    OperationRowView(op: op, machineName: machineName(for: op))
                        .tag(op.id)
                        .contextMenu {
                            Button(role: .destructive) {
                                part.operations.removeAll { $0.id == op.id }
                                if selectedOperationID == op.id {
                                    selectedOperationID = nil
                                }
                            } label: {
                                Label("Удалить", systemImage: "trash")
                            }
                        }
                }
                .onMove { from, to in
                    part.operations.move(fromOffsets: from, toOffset: to)
                }
            }
            .listStyle(.plain)

            Divider()

            // Итоги
            HStack {
                Text("Итого:").font(.caption.bold())
                Spacer()
                Text(formatTime(part.totalMachiningTime))
                    .font(.caption.bold())
                    .monospacedDigit()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
        }
    }

    private func machineName(for op: Operation) -> String {
        op.machineID.flatMap { store.workshop?.machine(by: $0) }?.name ?? "—"
    }

    private func formatTime(_ minutes: Double) -> String {
        if minutes < 60 { return String(format: "%.1f мин", minutes) }
        return String(format: "%d ч %.0f мин", Int(minutes / 60), minutes.truncatingRemainder(dividingBy: 60))
    }
}

struct OperationRowView: View {
    @ObservedObject var op: Operation
    let machineName: String

    var body: some View {
        HStack(spacing: 8) {
            // Цветная метка типа
            RoundedRectangle(cornerRadius: 3)
                .fill(opColor)
                .frame(width: 4, height: 36)

            VStack(alignment: .leading, spacing: 2) {
                Text(op.name).font(.body)
                HStack(spacing: 8) {
                    Text(op.type.rawValue)
                    Text("·")
                    Text(machineName)
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Spacer()

            Text(String(format: "%.1f мин", op.totalTime))
                .font(.caption)
                .monospacedDigit()
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 2)
    }

    private var opColor: Color {
        switch op.type {
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
