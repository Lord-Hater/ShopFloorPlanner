import SwiftUI

struct PartPlannerView: View {
    @EnvironmentObject var store: AppStore
    @State private var showAddPart = false

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Детали")
                    .font(.headline)
                Spacer()
                Button {
                    showAddPart = true
                } label: {
                    Label("Добавить деталь", systemImage: "plus")
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()

            Divider()

            if store.workshop.machines.isEmpty {
                ContentUnavailableView(
                    "Нет деталей",
                    systemImage: "cube",
                    description: Text("Добавьте деталь и задайте маршрут операций")
                )
            } else {
                List(selection: Binding(
                    get: { store.selectedPart?.id },
                    set: { id in store.selectedPart = nil }
                )) {
                    ForEach(store.workshop.machines.map(\.id), id: \.self) { _ in
                        EmptyView()
                    }
                }
            }
        }
        .sheet(isPresented: $showAddPart) {
            AddPartSheet()
        }
        .navigationTitle("Маршрут детали")
    }
}
