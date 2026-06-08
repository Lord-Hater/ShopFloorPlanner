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
                    TextField("", value: $machine.size.width, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 80)
                }
                LabeledContent("Глубина") {
                    TextField("", value: $machine.size.height, format: .number)
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
                    TextField("", value: $machine.position.x, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 80)
                }
                LabeledContent("Y") {
                    TextField("", value: $machine.position.y, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 80)
                }
            }
        }
        .formStyle(.grouped)
        .navigationTitle(machine.name)
    }
}
