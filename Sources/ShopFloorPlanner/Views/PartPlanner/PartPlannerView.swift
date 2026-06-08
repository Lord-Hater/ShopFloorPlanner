import SwiftUI

struct PartPlannerView: View {
    @EnvironmentObject var store: AppStore
    @State private var showAddPart = false

    var body: some View {
        HSplitView {
            // Левая панель — список деталей
            partList
                .frame(minWidth: 200, maxWidth: 280)

            // Правая панель — операции выбранной детали
            if let part = store.selectedPart {
                OperationsEditorView(part: part)
            } else {
                ContentUnavailableView(
                    "Деталь не выбрана",
                    systemImage: "cube",
                    description: Text("Выберите деталь слева или создайте новую")
                )
            }
        }
        .sheet(isPresented: $showAddPart) {
            AddPartSheet()
        }
        .navigationTitle("Маршрут детали")
    }

    private var partList: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Детали").font(.headline)
                Spacer()
                Button {
                    showAddPart = true
                } label: {
                    Image(systemName: "plus")
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)

            Divider()

            List(store.workshop.parts, selection: $store.selectedPartID) { part in
                PartRowView(part: part)
                    .tag(part.id)
                    .contextMenu {
                        Button(role: .destructive) {
                            store.workshop.parts.removeAll { $0.id == part.id }
                            if store.selectedPartID == part.id {
                                store.selectedPartID = store.workshop.parts.first?.id
                            }
                        } label: {
                            Label("Удалить", systemImage: "trash")
                        }
                    }
            }
            .listStyle(.sidebar)
        }
    }
}

struct PartRowView: View {
    @ObservedObject var part: Part

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(part.name).font(.body)
            Text("\(part.material) · \(part.operations.count) опер.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 2)
    }
}
