import SwiftUI

struct SigmaLevelView: View {
    @State private var viewModel = SigmaLevelViewModel()
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        ScrollView {
            VStack(spacing: AppTheme.Spacing.large) {
                VStack(spacing: AppTheme.Spacing.regular) {
                    InputFieldView(label: String(localized: "sigma.defects"), text: $viewModel.defectsText, unit: "")
                    InputFieldView(label: String(localized: "sigma.units"), text: $viewModel.unitsText, unit: "")
                    InputFieldView(label: String(localized: "sigma.opportunities"), text: $viewModel.opportunitiesText, unit: "")
                }

                CalculateButton(
                    title: String(localized: "action.calculate"),
                    isEnabled: viewModel.isValid
                ) {
                    withAnimation { viewModel.calculate() }
                }

                if let sigma = viewModel.sigmaResult {
                    VStack(spacing: AppTheme.Spacing.regular) {
                        ResultCardView(
                            title: String(localized: "sigma.level"),
                            value: sigma.formatted2,
                            unit: "σ",
                            formula: "σ = Z(1 - DPMO/10⁶) + 1.5"
                        )

                        HStack(spacing: AppTheme.Spacing.regular) {
                            if let dpmo = viewModel.dpmoResult {
                                miniResult(title: "DPMO", value: dpmo.formatted2)
                            }
                            if let yield_ = viewModel.yieldResult {
                                miniResult(title: "Yield", value: "\(yield_.formatted2)%")
                            }
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
        .navigationTitle(String(localized: "category.sigmaLevel"))
        .hideKeyboardOnTap()
    }

    private func miniResult(title: String, value: String) -> some View {
        VStack(spacing: AppTheme.Spacing.small) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title3.bold())
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium))
    }
}
