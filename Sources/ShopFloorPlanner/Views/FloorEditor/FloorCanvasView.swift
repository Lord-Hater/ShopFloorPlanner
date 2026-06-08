import SwiftUI

struct FloorCanvasView: View {
    @ObservedObject var workshop: Workshop
    @EnvironmentObject var store: AppStore
    let scale: CGFloat

    var body: some View {
        ZStack(alignment: .topLeading) {
            GridBackground(scale: scale, width: workshop.width, height: workshop.height)

            ForEach(workshop.zones) { zone in
                ZoneView(zone: zone, scale: scale)
            }

            ForEach(workshop.machines) { machine in
                MachineView(machine: machine, scale: scale,
                            isSelected: store.selectedMachineID == machine.id)
                    .onTapGesture {
                        store.selectedMachineID = machine.id
                        store.sidebarTab = .machines
                        store.markDirty()
                    }
                    .gesture(DragGesture()
                        .onChanged { value in
                            machine.position = CGPoint(
                                x: value.location.x / scale,
                                y: value.location.y / scale
                            )
                            store.markDirty()
                        }
                    )
            }
        }
        .border(Color.primary.opacity(0.3), width: 1)
    }
}

// MARK: - Grid

struct GridBackground: View {
    let scale: CGFloat
    let width: Double
    let height: Double

    var body: some View {
        Canvas { ctx, size in
            let step = scale
            var x: CGFloat = 0
            while x <= size.width {
                let path = Path { p in
                    p.move(to: CGPoint(x: x, y: 0))
                    p.addLine(to: CGPoint(x: x, y: size.height))
                }
                ctx.stroke(path, with: .color(.gray.opacity(0.2)), lineWidth: x.truncatingRemainder(dividingBy: step * 5) == 0 ? 1 : 0.5)
                x += step
            }
            var y: CGFloat = 0
            while y <= size.height {
                let path = Path { p in
                    p.move(to: CGPoint(x: 0, y: y))
                    p.addLine(to: CGPoint(x: size.width, y: y))
                }
                ctx.stroke(path, with: .color(.gray.opacity(0.2)), lineWidth: y.truncatingRemainder(dividingBy: step * 5) == 0 ? 1 : 0.5)
                y += step
            }
        }
        .frame(width: CGFloat(width) * scale, height: CGFloat(height) * scale)
        .background(Color.white)
    }
}

// MARK: - Zone

struct ZoneView: View {
    let zone: WorkshopZone
    let scale: CGFloat

    var body: some View {
        Rectangle()
            .fill(zoneColor.opacity(0.15))
            .border(zoneColor.opacity(0.4), width: 1)
            .frame(width: zone.rect.width * scale, height: zone.rect.height * scale)
            .offset(x: zone.rect.minX * scale, y: zone.rect.minY * scale)
            .overlay(alignment: .topLeading) {
                Text(zone.name)
                    .font(.caption2)
                    .foregroundStyle(zoneColor)
                    .padding(2)
                    .offset(x: zone.rect.minX * scale, y: zone.rect.minY * scale)
            }
    }

    private var zoneColor: Color {
        switch zone.type {
        case .workArea:  return .blue
        case .storage:   return .orange
        case .passage:   return .gray
        case .loading:   return .green
        case .scrap:     return .red
        }
    }
}

// MARK: - Machine

struct MachineView: View {
    @ObservedObject var machine: Machine
    let scale: CGFloat
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 2) {
            Text(machine.type.icon)
                .font(.system(size: min(machine.size.width, machine.size.height) * scale * 0.4))
            Text(machine.name)
                .font(.system(size: 9))
                .lineLimit(1)
                .truncationMode(.tail)
        }
        .frame(width: machine.size.width * scale, height: machine.size.height * scale)
        .background(isSelected ? Color.accentColor.opacity(0.25) : Color.blue.opacity(0.1))
        .border(isSelected ? Color.accentColor : Color.blue.opacity(0.5),
                width: isSelected ? 2 : 1)
        .rotationEffect(.radians(machine.rotation))
        .position(x: machine.position.x * scale,
                  y: machine.position.y * scale)
    }
}
