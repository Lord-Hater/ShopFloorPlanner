import SwiftUI
import Combine

class AppStore: ObservableObject {
    @Published var workshop: Workshop = Workshop(name: "Новый цех", width: 40, height: 30)
    @Published var selectedMachineID: UUID?
    @Published var selectedPartID: UUID?
    @Published var sidebarTab: SidebarTab = .machines

    var selectedPart: Part? {
        guard let id = selectedPartID else { return nil }
        return workshop.part(by: id)
    }

    func selectPart(_ part: Part) {
        selectedPartID = part.id
        sidebarTab = .parts
    }

    enum SidebarTab {
        case machines, parts, reports
    }
}
