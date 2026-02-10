import SwiftUI

struct AlphaBetaView: View {
    @State private var viewModel = AlphaBetaViewModel()
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        ScrollView {
            VStack(spacing: AppTheme.Spacing.large) {
                VStack(spacing: AppTheme.Spacing.regular) {
                    InputFieldView(label: String(localized: "alphaBeta.alpha"), text: $viewModel.alphaText, unit: "α")
                    InputFieldView(label: String(localized: "alphaBeta.effectSize"), text: $viewModel.effectSizeText, unit: "d")
                    InputFieldView(label: String(localized: "alphaBeta.sampleSize"), text: $viewModel.sampleSizeText, unit: "n")
                }

                CalculateButton(
                    title: String(localized: "action.calculate"),
                    isEnabled: viewModel.isValid
                ) {
                    withAnimation { viewModel.calculate() }
                }

                if let r = viewModel.result {
                    VStack(spacing: AppTheme.Spacing.regular) {
                        ResultCardView(
                            title: String(localized: "alphaBeta.power"),
                            value: r.power.formatted2,
                            unit: "",
                            formula: "Power = 1 - β"
                        )

                        HStack(spacing: AppTheme.Spacing.regular) {
                            miniResult(title: "α", value: r.alpha.formatted2)
                            miniResult(title: "β", value: r.beta.formatted2)
                        }

                        if let reqN = viewModel.requiredN {
                            HStack {
                                Image(systemName: "info.circle").foregroundStyle(.blue)
                                Text(String(localized: "alphaBeta.requiredN \(reqN)"))
                                    .font(.subheadline)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(.blue.opacity(0.1), in: RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium))
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
        .navigationTitle(String(localized: "category.alphaBeta"))
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
