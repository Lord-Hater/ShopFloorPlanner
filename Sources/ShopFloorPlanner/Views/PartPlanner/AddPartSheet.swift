import SwiftUI

struct AddPartSheet: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    @State private var name = ""
    @State private var material = "Сталь 45"
    @State private var blankWeight = 1.0
    @State private var finishedWeight = 0.8

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Новая деталь")
                .font(.title2.bold())

            TextField("Название детали", text: $name)
                .textFieldStyle(.roundedBorder)

            TextField("Материал", text: $material)
                .textFieldStyle(.roundedBorder)

            HStack {
                VStack(alignment: .leading) {
                    Text("Масса заготовки (кг)").font(.caption)
                    TextField("", value: $blankWeight, format: .number)
                        .textFieldStyle(.roundedBorder)
                }
                VStack(alignment: .leading) {
                    Text("Масса детали (кг)").font(.caption)
                    TextField("", value: $finishedWeight, format: .number)
                        .textFieldStyle(.roundedBorder)
                }
            }

            HStack {
                Button("Отмена") { dismiss() }
                    .keyboardShortcut(.escape)
                Spacer()
                Button("Создать") {
                    let part = Part(
                        name: name.isEmpty ? "Деталь" : name,
                        material: material,
                        blankWeight: blankWeight,
                        finishedWeight: finishedWeight
                    )
                    store.selectedPart = part
                    store.sidebarTab = .parts
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .keyboardShortcut(.return)
                .disabled(name.isEmpty)
            }
        }
        .padding(24)
        .frame(width: 360)
    }
}
