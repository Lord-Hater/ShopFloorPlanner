import SwiftUI

@main
struct ShopFloorPlannerApp: App {
    var body: some Scene {
        DocumentGroup(newDocument: { ShopFloorDocument() }) { file in
            DocumentContentView(document: file.document)
        }
        .commands {
            AppCommands()
        }
    }
}
