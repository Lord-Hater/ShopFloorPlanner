import SwiftUI

struct FloorEditorView: View {
    @EnvironmentObject var store: AppStore
    @State private var scale: CGFloat = 20.0   // пикселей на метр
    @State private var showAddMachine = false

    var body: some View {
        VStack(spacing: 0) {
            toolbar
            Divider()
            GeometryReader { geo in
                ScrollView([.horizontal, .vertical]) {
                    FloorCanvasView(scale: scale)
                        .frame(
                            width:  CGFloat(store.workshop.width)  * scale,
                            height: CGFloat(store.workshop.height) * scale
                        )
                }
                .background(Color(nsColor: .controlBackgroundColor))
            }
        }
        .navigationTitle("Схема цеха")
        .sheet(isPresented: $showAddMachine) {
            AddMachineSheet()
        }
    }

    private var toolbar: some View {
        HStack {
            Button {
                showAddMachine = true
            } label: {
                Label("Добавить станок", systemImage: "plus")
            }
            .buttonStyle(.borderedProminent)

            Spacer()

            Text("Масштаб")
                .foregroundStyle(.secondary)
            Slider(value: $scale, in: 10...50, step: 5)
                .frame(width: 120)
            Text("\(Int(scale)) px/м")
                .monospacedDigit()
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }
}
