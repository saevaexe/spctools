import SwiftUI
import Charts

struct ControlChartView: View {
    @State private var viewModel = ControlChartViewModel()
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        ScrollView {
            VStack(spacing: AppTheme.Spacing.large) {
                // Chart type picker
                Picker("", selection: $viewModel.chartType) {
                    ForEach(ControlChartViewModel.ChartType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(.segmented)

                // Data input
                DataInputView(label: String(localized: "controlChart.dataInput"), text: $viewModel.dataText)

                if viewModel.chartType == .xbarR {
                    InputFieldView(label: String(localized: "controlChart.subgroupSize"), text: $viewModel.subgroupSize, unit: "n")
                }

                CalculateButton(
                    title: String(localized: "action.calculate"),
                    isEnabled: viewModel.isValid
                ) {
                    withAnimation { viewModel.calculate() }
                }

                // I-MR Charts
                if let iResult = viewModel.iResult, let mrResult = viewModel.mrResult {
                    chartSection(title: "I Chart", result: iResult)
                    chartSection(title: "MR Chart", result: mrResult)
                    outOfControlSection()

                    Button(String(localized: "action.saveHistory")) {
                        viewModel.saveToHistory(modelContext: modelContext)
                    }
                    .font(.subheadline)
                }

                // X-bar R Charts
                if let xbarResult = viewModel.xbarResult, let rResult = viewModel.rResult {
                    chartSection(title: "X̄ Chart", result: xbarResult)
                    chartSection(title: "R Chart", result: rResult)
                    outOfControlSection()

                    Button(String(localized: "action.saveHistory")) {
                        viewModel.saveToHistory(modelContext: modelContext)
                    }
                    .font(.subheadline)
                }
            }
            .padding()
            .frame(maxWidth: 600)
        }
        .navigationTitle(String(localized: "category.controlChart"))
        .hideKeyboardOnTap()
    }

    private func chartSection(title: String, result: ControlChartEngine.ChartResult) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
            Text(title).font(.headline)

            Chart {
                ForEach(Array(result.points.enumerated()), id: \.offset) { index, value in
                    LineMark(x: .value("Index", index), y: .value("Value", value))
                        .foregroundStyle(.blue)
                    PointMark(x: .value("Index", index), y: .value("Value", value))
                        .foregroundStyle(value > result.ucl || value < result.lcl ? .red : .blue)
                }
                RuleMark(y: .value("UCL", result.ucl))
                    .foregroundStyle(.red).lineStyle(StrokeStyle(dash: [5, 3]))
                RuleMark(y: .value("CL", result.cl))
                    .foregroundStyle(.green)
                RuleMark(y: .value("LCL", result.lcl))
                    .foregroundStyle(.red).lineStyle(StrokeStyle(dash: [5, 3]))
            }
            .frame(height: 200)

            HStack {
                Text("UCL: \(result.ucl.formatted2)").font(.caption)
                Spacer()
                Text("CL: \(result.cl.formatted2)").font(.caption)
                Spacer()
                Text("LCL: \(result.lcl.formatted2)").font(.caption)
            }
            .foregroundStyle(.secondary)
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium))
    }

    @ViewBuilder
    private func outOfControlSection() -> some View {
        if !viewModel.outOfControlIndices.isEmpty {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill").foregroundStyle(.orange)
                Text(String(localized: "controlChart.outOfControl \(viewModel.outOfControlIndices.count)"))
                    .font(.subheadline)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(.orange.opacity(0.1), in: RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium))
        }
    }
}
