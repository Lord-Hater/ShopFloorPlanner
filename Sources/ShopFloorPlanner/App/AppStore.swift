import SwiftUI
import Combine

class AppStore: ObservableObject {
    @Published var workshop: Workshop = Workshop(name: "Новый цех", width: 40, height: 30)
    @Published var selectedMachineID: UUID?
    @Published var selectedPart: Part?
    @Published var sidebarTab: SidebarTab = .machines

    enum SidebarTab {
        case machines, parts, reports
    }
}
