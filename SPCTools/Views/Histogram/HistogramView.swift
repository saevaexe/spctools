import SwiftUI
import Charts

struct HistogramView: View {
    @State private var viewModel = HistogramViewModel()
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        ScrollView {
            VStack(spacing: AppTheme.Spacing.large) {
                DataInputView(label: String(localized: "histogram.dataInput"), text: $viewModel.dataText)

                InputFieldView(label: String(localized: "histogram.binCount"), text: $viewModel.customBinCount, unit: String(localized: "histogram.optional"))

                CalculateButton(
                    title: String(localized: "action.calculate"),
                    isEnabled: viewModel.isValid
                ) {
                    withAnimation { viewModel.calculate() }
                }

                if let result = viewModel.result {
                    // Histogram chart
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
                        Text(String(localized: "histogram.chart")).font(.headline)

                        Chart(result.bins) { bin in
                            BarMark(
                                x: .value("Range", bin.label),
                                y: .value("Frequency", bin.frequency)
                            )
                            .foregroundStyle(.blue.opacity(0.7))
                        }
                        .frame(height: 200)
                    }
                    .padding()
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium))

                    // Stats
                    VStack(spacing: AppTheme.Spacing.regular) {
                        HStack(spacing: AppTheme.Spacing.regular) {
                            miniResult(title: "μ", value: result.mean.formatted2)
                            miniResult(title: "σ", value: result.standardDeviation.formatted2)
                        }
                        HStack(spacing: AppTheme.Spacing.regular) {
                            miniResult(title: "Min", value: result.min.formatted2)
                            miniResult(title: "Max", value: result.max.formatted2)
                        }
                        miniResult(title: "N", value: "\(result.count)")
                    }

                    Button(String(localized: "action.saveHistory")) {
                        viewModel.saveToHistory(modelContext: modelContext)
                    }
                    .font(.subheadline)
                }
            }
            .padding()
            .frame(maxWidth: 600)
        }
        .navigationTitle(String(localized: "category.histogram"))
        .hideKeyboardOnTap()
    }

    private func miniResult(title: String, value: String) -> some View {
        VStack(spacing: AppTheme.Spacing.small) {
            Text(title).font(.caption).foregroundStyle(.secondary)
            Text(value).font(.title3.bold())
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium))
    }
}
