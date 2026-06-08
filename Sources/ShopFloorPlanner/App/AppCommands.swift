import SwiftUI

struct AppCommands: Commands {
    var body: some Commands {
        CommandGroup(replacing: .newItem) {
            Button("Новый цех") {
                NotificationCenter.default.post(name: .newWorkshop, object: nil)
            }
            .keyboardShortcut("n", modifiers: .command)
        }
    }
}

extension Notification.Name {
    static let newWorkshop = Notification.Name("newWorkshop")
}
