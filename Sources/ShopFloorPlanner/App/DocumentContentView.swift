import SwiftUI

struct DocumentContentView: View {
    @ObservedObject var document: ShopFloorDocument
    @StateObject private var store = AppStore()

    var body: some View {
        ContentView(workshop: document.workshop)
            .environmentObject(store)
            .frame(minWidth: 1200, minHeight: 700)
            .onAppear {
                store.workshopRef = document.workshop
                store.document = document
            }
    }
}
