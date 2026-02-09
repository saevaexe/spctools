import SwiftUI

struct CpCpkView: View {
    @State private var viewModel = CpCpkViewModel()
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        ScrollView {
            VStack(spacing: AppTheme.Spacing.large) {
                // Inputs
                VStack(spacing: AppTheme.Spacing.regular) {
                    InputFieldView(label: String(localized: "cpCpk.usl"), text: $viewModel.uslText, unit: "")
                    InputFieldView(label: String(localized: "cpCpk.lsl"), text: $viewModel.lslText, unit: "")
                    InputFieldView(label: String(localized: "cpCpk.mean"), text: $viewModel.meanText, unit: "μ")
                    InputFieldView(label: String(localized: "cpCpk.sigma"), text: $viewModel.sigmaText, unit: "σ")
                }

                CalculateButton(
                    title: String(localized: "action.calculate"),
                    isEnabled: viewModel.isValid
                ) {
                    withAnimation { viewModel.calculate() }
                }

                // Results
                if let cp = viewModel.cpResult, let cpk = viewModel.cpkResult {
                    VStack(spacing: AppTheme.Spacing.regular) {
                        ResultCardView(
                            title: "Cp",
                            value: cp.formatted2,
                            unit: "",
                            formula: "Cp = (USL - LSL) / 6σ"
                        )
                        ResultCardView(
                            title: "Cpk",
                            value: cpk.formatted2,
                            unit: "",
                            formula: "Cpk = min(Cpu, Cpl)"
                        )

                        if let cpu = viewModel.cpuResult, let cpl = viewModel.cplResult {
                            HStack(spacing: AppTheme.Spacing.regular) {
                                miniResult(title: "Cpu", value: cpu.formatted2)
                                miniResult(title: "Cpl", value: cpl.formatted2)
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
        .navigationTitle(String(localized: "category.cpCpk"))
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
