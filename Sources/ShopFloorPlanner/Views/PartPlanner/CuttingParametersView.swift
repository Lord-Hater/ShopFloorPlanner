import SwiftUI

/// Главный переключатель — показывает нужную форму по типу параметров
struct CuttingParametersView: View {
    @Binding var container: CuttingParametersContainer?
    let operationType: OperationType

    var body: some View {
        if operationType.supportsCuttingParameters {
            VStack(alignment: .leading, spacing: 0) {
                Toggle("Рассчитать T₀ по режимам резания", isOn: Binding(
                    get: { container != nil },
                    set: { on in
                        container = on ? CuttingParametersContainer.defaultFor(operationType) : nil
                    }
                ))
                .padding(.bottom, 8)

                if let c = container {
                    Divider().padding(.bottom, 8)
                    cuttingForm(for: c)
                }
            }
        }
    }

    @ViewBuilder
    private func cuttingForm(for c: CuttingParametersContainer) -> some View {
        switch c {
        case .turning(let p):
            TurningParametersForm(params: p) { updated in
                container = .turning(updated)
            }
        case .milling(let p):
            MillingParametersForm(params: p) { updated in
                container = .milling(updated)
            }
        case .drilling(let p):
            DrillingParametersForm(params: p) { updated in
                container = .drilling(updated)
            }
        case .grinding(let p):
            GrindingParametersForm(params: p) { updated in
                container = .grinding(updated)
            }
        }
    }
}

// MARK: - Result banner

struct CuttingResultBanner: View {
    let container: CuttingParametersContainer

    var body: some View {
        let p = container.parameters
        HStack(spacing: 20) {
            resultItem("T₀", value: String(format: "%.3f мин", p.calculateMachineTime()), primary: true)
            resultItem("n", value: String(format: "%.0f об/мин", p.actualRPM))
            resultItem("V", value: String(format: "%.1f м/мин", p.actualCuttingSpeed))
        }
        .padding(10)
        .background(Color.accentColor.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private func resultItem(_ label: String, value: String, primary: Bool = false) -> some View {
        VStack(spacing: 2) {
            Text(label).font(.caption2).foregroundStyle(.secondary)
            Text(value)
                .font(primary ? .body.bold() : .caption.monospacedDigit())
                .foregroundStyle(primary ? Color.accentColor : Color.primary)
        }
    }
}

// MARK: - Turning form

struct TurningParametersForm: View {
    @State var params: TurningParameters
    let onChange: (TurningParameters) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            CuttingResultBanner(container: .turning(params))

            Group {
                sectionHeader("Геометрия детали")
                row("Диаметр D", unit: "мм", value: $params.diameter)
                row("Длина обработки l", unit: "мм", value: $params.length)
                row("Припуск на сторону", unit: "мм", value: $params.allowance)
                row("Длина врезания l_вр", unit: "мм", value: $params.approachLength)
                row("Длина перебега l_пер", unit: "мм", value: $params.overrunLength)
            }

            Group {
                sectionHeader("Режимы резания")
                row("Скорость резания V", unit: "м/мин", value: $params.cuttingSpeed)
                row("Подача S", unit: "мм/об", value: $params.feed, step: 0.01)
                row("Глубина резания ap", unit: "мм", value: $params.depthOfCut, step: 0.1)
            }

            Group {
                sectionHeader("Проходы")
                Toggle("Авто (i = припуск / ap)", isOn: $params.useAutoPasses)
                if !params.useAutoPasses {
                    Stepper("Число проходов i = \(params.manualPasses)", value: $params.manualPasses, in: 1...50)
                } else {
                    Text("i = \(params.passes) проход(а/ов)")
                        .font(.caption).foregroundStyle(.secondary)
                }
            }

            formulaNote("T₀ = L · i / (n · S),  n = 1000·V / (π·D)")
        }
        .onChange(of: params) { _, new in Task { @MainActor in onChange(new) } }
    }
}

// MARK: - Milling form

struct MillingParametersForm: View {
    @State var params: MillingParameters
    let onChange: (MillingParameters) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            CuttingResultBanner(container: .milling(params))

            Group {
                sectionHeader("Геометрия")
                row("Длина фрезерования l", unit: "мм", value: $params.length)
                row("Глубина фрезерования t", unit: "мм", value: $params.depthOfCut, step: 0.5)
                row("Длина врезания l_вр", unit: "мм", value: $params.approachLength)
                row("Длина перебега l_пер", unit: "мм", value: $params.overrunLength)
            }

            Group {
                sectionHeader("Инструмент")
                row("Диаметр фрезы D", unit: "мм", value: $params.toolDiameter)
                intRow("Число зубьев z", value: $params.teethCount, range: 2...80)
            }

            Group {
                sectionHeader("Режимы резания")
                row("Скорость резания V", unit: "м/мин", value: $params.cuttingSpeed)
                row("Подача на зуб Sz", unit: "мм/зуб", value: $params.feedPerTooth, step: 0.01)
                resultRow("Минутная подача Sмин", value: String(format: "%.1f мм/мин", params.tableFeedPerMin))
            }

            formulaNote("T₀ = L / Sмин,  Sмин = Sz · z · n,  n = 1000·V / (π·D)")
        }
        .onChange(of: params) { _, new in Task { @MainActor in onChange(new) } }
    }
}

// MARK: - Drilling form

struct DrillingParametersForm: View {
    @State var params: DrillingParameters
    let onChange: (DrillingParameters) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            CuttingResultBanner(container: .drilling(params))

            Group {
                sectionHeader("Геометрия")
                row("Диаметр сверла D", unit: "мм", value: $params.toolDiameter)
                row("Глубина сверления l", unit: "мм", value: $params.holeDepth)
                row("Длина подвода l_вр", unit: "мм", value: $params.approachLength)
                row("Длина выхода l_пер", unit: "мм", value: $params.overrunLength)
            }

            Group {
                sectionHeader("Режимы резания")
                row("Скорость резания V", unit: "м/мин", value: $params.cuttingSpeed)
                row("Подача S", unit: "мм/об", value: $params.feed, step: 0.01)
            }

            formulaNote("T₀ = L / (n · S),  n = 1000·V / (π·D)")
        }
        .onChange(of: params) { _, new in Task { @MainActor in onChange(new) } }
    }
}

// MARK: - Grinding form

struct GrindingParametersForm: View {
    @State var params: GrindingParameters
    let onChange: (GrindingParameters) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            CuttingResultBanner(container: .grinding(params))

            Group {
                sectionHeader("Геометрия детали")
                row("Диаметр детали D", unit: "мм", value: $params.diameter)
                row("Длина шлифования l", unit: "мм", value: $params.length)
                row("Общий припуск a", unit: "мм", value: $params.allowance, step: 0.01)
            }

            Group {
                sectionHeader("Круг и режимы")
                row("Ширина круга Bк", unit: "мм", value: $params.wheelWidth)
                row("Скорость детали Vд", unit: "м/мин", value: $params.partSpeed)
                row("Коэффициент перекрытия β", unit: "", value: $params.axialFeedCoeff, step: 0.05, range: 0.1...0.8)
                row("Попер. подача t_поп", unit: "мм/проход", value: $params.radialFeedPerPass, step: 0.005, range: 0.001...0.05)
            }

            Group {
                sectionHeader("Расчётные параметры")
                resultRow("Осевая подача Sос", value: String(format: "%.2f мм/об", params.axialFeedPerRev))
                resultRow("Продольных ходов/поп. подачу", value: String(format: "%.1f", params.longitudinalPassesPerRadial))
                resultRow("Поперечных подач i", value: "\(params.radialPasses)")
            }

            formulaNote("T₀ = (l/Sос + 1) · i / n · 1.2  (коэф. выхаживания)")
        }
        .onChange(of: params) { _, new in Task { @MainActor in onChange(new) } }
    }
}

// MARK: - Shared helpers

private func sectionHeader(_ title: String) -> some View {
    Text(title)
        .font(.caption.bold())
        .foregroundStyle(.secondary)
        .padding(.top, 4)
}

private func row(_ label: String, unit: String, value: Binding<Double>,
                  step: Double = 1.0, range: ClosedRange<Double> = 0.001...9999) -> some View {
    HStack {
        Text(label).frame(maxWidth: .infinity, alignment: .leading)
        TextField("", value: value, format: .number.precision(.fractionLength(3)))
            .textFieldStyle(.roundedBorder)
            .frame(width: 90)
            .multilineTextAlignment(.trailing)
        if !unit.isEmpty {
            Text(unit).frame(width: 60, alignment: .leading).foregroundStyle(.secondary).font(.caption)
        }
    }
    .font(.callout)
}

private func intRow(_ label: String, value: Binding<Int>, range: ClosedRange<Int> = 1...200) -> some View {
    HStack {
        Text(label).frame(maxWidth: .infinity, alignment: .leading)
        Stepper("\(value.wrappedValue)", value: value, in: range)
    }
    .font(.callout)
}

private func resultRow(_ label: String, value: String) -> some View {
    HStack {
        Text(label).frame(maxWidth: .infinity, alignment: .leading).foregroundStyle(.secondary)
        Text(value).monospacedDigit().font(.callout)
    }
    .font(.callout)
}

private func formulaNote(_ text: String) -> some View {
    Text(text)
        .font(.caption2)
        .foregroundStyle(.tertiary)
        .padding(.top, 4)
}
