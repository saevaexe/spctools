import SwiftUI

struct SampleSizeView: View {
    @State private var viewModel = SampleSizeViewModel()
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        ScrollView {
            VStack(spacing: AppTheme.Spacing.large) {
                VStack(spacing: AppTheme.Spacing.regular) {
                    // Confidence Level Picker
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
                        Text(String(localized: "sampleSize.confidence"))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Picker(String(localized: "sampleSize.confidence"), selection: $viewModel.selectedConfidence) {
                            ForEach(SampleSizeEngine.confidenceLevels, id: \.value) { level in
                                Text(level.label).tag(level.value)
                            }
                        }
                        .pickerStyle(.segmented)
                    }

                    InputFieldView(label: String(localized: "sampleSize.marginOfError"), text: $viewModel.marginOfErrorText, unit: "", placeholder: "0.05")
                    InputFieldView(label: String(localized: "sampleSize.proportion"), text: $viewModel.proportionText, unit: "", placeholder: "0.5")
                    InputFieldView(label: String(localized: "sampleSize.population"), text: $viewModel.populationText, unit: "", placeholder: String(localized: "sampleSize.optional"))
                }

                CalculateButton(
                    title: String(localized: "action.calculate"),
                    isEnabled: viewModel.isValid
                ) {
                    withAnimation { viewModel.calculate() }
                }

                if let n = viewModel.sampleSizeResult {
                    VStack(spacing: AppTheme.Spacing.regular) {
                        ResultCardView(
                            title: String(localized: "sampleSize.result"),
                            value: "\(n)",
                            unit: String(localized: "sampleSize.unit"),
                            formula: "n = Z²·p·(1-p) / E²"
                        )

                        if let adjusted = viewModel.adjustedSampleSize {
                            ResultCardView(
                                title: String(localized: "sampleSize.adjusted"),
                                value: "\(adjusted)",
                                unit: String(localized: "sampleSize.unit"),
                                formula: "n_adj = n / (1 + (n-1)/N)"
                            )
                        }

                        Button(String(localized: "action.saveHistory")) {
                            viewModel.saveToHistory(modelContext: modelContext)
                        }
                        .font(.subheadline)
                    }
                }
            }
            .padding()
            .frame(maxWidth: 600)
        }
        .navigationTitle(String(localized: "category.sampleSize"))
        .hideKeyboardOnTap()
    }
}
