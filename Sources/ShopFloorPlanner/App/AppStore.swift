import SwiftUI
import Combine

class AppStore: ObservableObject {
    @Published var selectedMachineID: UUID?
    @Published var selectedPartID: UUID?
    @Published var sidebarTab: SidebarTab = .machines

    weak var workshopRef: Workshop?
    weak var document: ShopFloorDocument?

    var workshop: Workshop? { workshopRef }

    var selectedPart: Part? {
        guard let id = selectedPartID else { return nil }
        return workshop?.part(by: id)
    }

    func selectPart(_ part: Part) {
        selectedPartID = part.id
        sidebarTab = .parts
    }

    /// Сигнализирует DocumentGroup что документ изменился → появляется точка в titlebar
    func markDirty() {
        document?.touch()
    }

    enum SidebarTab {
        case machines, parts, reports
    }
}
