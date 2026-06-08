import SwiftUI

struct AppCommands: Commands {
    var body: some Commands {
        // Не переопределяем .newItem — DocumentGroup сам обрабатывает ⌘N
        // Дополнительные команды можно добавить здесь
    }
}
