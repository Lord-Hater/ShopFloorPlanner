import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: AppStore

    var body: some View {
        NavigationSplitView {
            SidebarView()
        } content: {
            FloorEditorView()
        } detail: {
            switch store.sidebarTab {
            case .machines:
                MachineDetailView()
            case .parts:
                PartPlannerView()
            case .reports:
                ReportView()
            }
        }
    }
}
