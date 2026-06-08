import SwiftUI

struct ContentView: View {
    @ObservedObject var workshop: Workshop
    @EnvironmentObject var store: AppStore

    var body: some View {
        NavigationSplitView {
            SidebarView(workshop: workshop)
        } content: {
            FloorEditorView(workshop: workshop)
        } detail: {
            switch store.sidebarTab {
            case .machines:
                MachineDetailView()
            case .parts:
                PartPlannerView(workshop: workshop)
            case .reports:
                ReportView()
            }
        }
    }
}
