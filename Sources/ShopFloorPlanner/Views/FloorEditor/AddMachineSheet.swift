import SwiftUI

struct AddMachineSheet: View {
    @ObservedObject var workshop: Workshop
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    @State private var selectedType: MachineType = .lathe
    @State private var name: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Добавить станок")
                .font(.title2.bold())

            Picker("Тип", selection: $selectedType) {
                ForEach(MachineType.allCases, id: \.self) { type in
                    Text("\(type.icon) \(type.rawValue)").tag(type)
                }
            }
            .onChange(of: selectedType) { _, new in
                Task { @MainActor in
                    if name.isEmpty { name = new.rawValue }
                }
            }

            TextField("Название (необязательно)", text: $name)
                .textFieldStyle(.roundedBorder)

            HStack {
                Button("Отмена") { dismiss() }
                    .keyboardShortcut(.escape)
                Spacer()
                Button("Добавить") {
                    let machine = Machine(
                        name: name.isEmpty ? selectedType.rawValue : name,
                        type: selectedType,
                        position: CGPoint(x: workshop.width / 2, y: workshop.height / 2)
                    )
                    workshop.machines.append(machine)
                    store.selectedMachineID = machine.id
                    store.markDirty()
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .keyboardShortcut(.return)
            }
        }
        .padding(24)
        .frame(width: 360)
    }
}
