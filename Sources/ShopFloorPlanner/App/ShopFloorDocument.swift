import SwiftUI
import UniformTypeIdentifiers
import Combine

extension UTType {
    static let shopFloorPlanner = UTType(exportedAs: "com.lordhater.shopfloorplanner")
}

/// Document для reference-типа Workshop.
/// ReferenceFileDocument работает с классами — snapshot создаётся при каждом сохранении.
final class ShopFloorDocument: ReferenceFileDocument {
    typealias Snapshot = Data

    static var readableContentTypes: [UTType] { [.shopFloorPlanner] }
    static var writableContentTypes: [UTType] { [.shopFloorPlanner] }

    @Published var workshop: Workshop

    init(workshop: Workshop = Workshop(name: "Новый цех", width: 40, height: 30)) {
        self.workshop = workshop
    }

    required init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }
        self.workshop = try JSONDecoder().decode(Workshop.self, from: data)
    }

    /// Вызывается на фоновом потоке — делаем снимок текущего состояния
    func snapshot(contentType: UTType) throws -> Data {
        try JSONEncoder().encode(workshop)
    }

    func fileWrapper(snapshot: Data, configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: snapshot)
    }

    /// Уведомить DocumentGroup что документ изменился (для точки сохранения в titlebar)
    func touch() {
        objectWillChange.send()
    }
}
