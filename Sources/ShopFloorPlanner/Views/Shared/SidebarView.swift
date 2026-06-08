import SwiftUI

struct SidebarView: View {
    @EnvironmentObject var store: AppStore

    var body: some View {
        List(selection: Binding(
            get: { store.sidebarTab },
            set: { store.sidebarTab = $0 }
        )) {
            Section("Цех") {
                Label("Станки", systemImage: "gearshape.2")
                    .tag(AppStore.SidebarTab.machines)
                Label("Детали", systemImage: "cube")
                    .tag(AppStore.SidebarTab.parts)
            }
            Section("Аналитика") {
                Label("Отчёты", systemImage: "chart.bar.doc.horizontal")
                    .tag(AppStore.SidebarTab.reports)
            }
        }
        .navigationTitle(store.workshop.name)
        .listStyle(.sidebar)
    }
}
