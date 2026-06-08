import SwiftUI

struct PartPlannerView: View {
    @ObservedObject var workshop: Workshop
    @EnvironmentObject var store: AppStore
    @State private var showAddPart = false

    var body: some View {
        HSplitView {
            partList
                .frame(minWidth: 200, maxWidth: 280)

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
            AddPartSheet(workshop: workshop)
        }
        .navigationTitle("Маршрут детали")
    }

    private var partList: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Детали").font(.headline)
                Spacer()
                Button { showAddPart = true } label: {
                    Image(systemName: "plus")
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)

            Divider()

            List(workshop.parts, selection: $store.selectedPartID) { part in
                PartRowView(part: part)
                    .tag(part.id)
                    .contextMenu {
                        Button(role: .destructive) {
                            workshop.parts.removeAll { $0.id == part.id }
                            if store.selectedPartID == part.id {
                                store.selectedPartID = workshop.parts.first?.id
                            }
                            store.markDirty()
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
