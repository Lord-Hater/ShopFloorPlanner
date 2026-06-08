import SwiftUI

struct MachineDetailView: View {
    @EnvironmentObject var store: AppStore

    var body: some View {
        if let id = store.selectedMachineID,
           let machine = store.workshop.machine(by: id) {
            MachinePropertiesView(machine: machine)
        } else {
            ContentUnavailableView(
                "Станок не выбран",
                systemImage: "gearshape",
                description: Text("Выберите станок на схеме или добавьте новый")
            )
        }
    }
}

struct MachinePropertiesView: View {
    @ObservedObject var machine: Machine

    var body: some View {
        Form {
            Section("Основное") {
                TextField("Название", text: $machine.name)
                Picker("Тип", selection: $machine.type) {
                    ForEach(MachineType.allCases, id: \.self) { type in
                        Text("\(type.icon) \(type.rawValue)").tag(type)
                    }
                }
            }

            Section("Размеры (м)") {
                LabeledContent("Ширина") {
                    TextField("", value: Binding(
                        get: { Double(machine.size.width) },
                        set: { machine.size.width = CGFloat($0) }
                    ), format: .number)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 80)
                }
                LabeledContent("Глубина") {
                    TextField("", value: Binding(
                        get: { Double(machine.size.height) },
                        set: { machine.size.height = CGFloat($0) }
                    ), format: .number)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 80)
                }
            }

            Section("Нормативы") {
                LabeledContent("Время переналадки (мин)") {
                    TextField("", value: $machine.setupTime, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 80)
                }
                LabeledContent("Коэф. использования") {
                    Slider(value: $machine.utilizationRate, in: 0...1, step: 0.05)
                    Text("\(Int(machine.utilizationRate * 100))%")
                        .monospacedDigit()
                        .frame(width: 40)
                }
            }

            Section("Позиция на схеме (м)") {
                LabeledContent("X") {
                    TextField("", value: Binding(
                        get: { Double(machine.position.x) },
                        set: { machine.position.x = CGFloat($0) }
                    ), format: .number)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 80)
                }
                LabeledContent("Y") {
                    TextField("", value: Binding(
                        get: { Double(machine.position.y) },
                        set: { machine.position.y = CGFloat($0) }
                    ), format: .number)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 80)
                }
            }
        }
        .formStyle(.grouped)
        .navigationTitle(machine.name)
    }
}
