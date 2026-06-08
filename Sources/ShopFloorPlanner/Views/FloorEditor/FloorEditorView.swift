import SwiftUI

struct FloorEditorView: View {
    @ObservedObject var workshop: Workshop
    @EnvironmentObject var store: AppStore
    @State private var scale: CGFloat = 20.0
    @State private var showAddMachine = false

    var body: some View {
        VStack(spacing: 0) {
            toolbar
            Divider()
            GeometryReader { _ in
                ScrollView([.horizontal, .vertical]) {
                    FloorCanvasView(workshop: workshop, scale: scale)
                        .frame(
                            width:  CGFloat(workshop.width)  * scale,
                            height: CGFloat(workshop.height) * scale
                        )
                }
                .background(Color(nsColor: .controlBackgroundColor))
            }
        }
        .navigationTitle("Схема цеха")
        .sheet(isPresented: $showAddMachine) {
            AddMachineSheet(workshop: workshop)
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

            Text("Масштаб").foregroundStyle(.secondary)
            Slider(value: $scale, in: 10...50, step: 5).frame(width: 120)
            Text("\(Int(scale)) px/м").monospacedDigit().foregroundStyle(.secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }
}
