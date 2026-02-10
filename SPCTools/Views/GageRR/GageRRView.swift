import SwiftUI

struct GageRRView: View {
    @State private var viewModel = GageRRViewModel()
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        ScrollView {
            VStack(spacing: AppTheme.Spacing.large) {
                VStack(spacing: AppTheme.Spacing.regular) {
                    InputFieldView(label: String(localized: "gageRR.operators"), text: $viewModel.numOperators, unit: "")
                    InputFieldView(label: String(localized: "gageRR.parts"), text: $viewModel.numParts, unit: "")
                    InputFieldView(label: String(localized: "gageRR.trials"), text: $viewModel.numTrials, unit: "")
                }

                DataInputView(label: String(localized: "gageRR.measurements"), text: $viewModel.dataText)

                CalculateButton(
                    title: String(localized: "action.calculate"),
                    isEnabled: viewModel.isValid
                ) {
                    withAnimation { viewModel.calculate() }
                }

                if let r = viewModel.result {
                    VStack(spacing: AppTheme.Spacing.regular) {
                        ResultCardView(
                            title: "%GRR",
                            value: r.percentGRR.formatted2 + "%",
                            unit: "",
                            formula: "%GRR = GRR / TV × 100"
                        )

                        HStack(spacing: AppTheme.Spacing.regular) {
                            miniResult(title: "EV", value: r.repeatability.formatted2)
                            miniResult(title: "AV", value: r.reproducibility.formatted2)
                        }
                        HStack(spacing: AppTheme.Spacing.regular) {
                            miniResult(title: "NDC", value: "\(r.ndc)")
                            miniResult(title: "%PV", value: r.percentPV.formatted2 + "%")
                        }

                        if let interp = viewModel.interpretation {
                            Text(interp)
                                .font(.subheadline)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium))
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
        .navigationTitle(String(localized: "category.gageRR"))
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
