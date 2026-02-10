import SwiftUI

struct PpPpkView: View {
    @State private var viewModel = PpPpkViewModel()
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        ScrollView {
            VStack(spacing: AppTheme.Spacing.large) {
                VStack(spacing: AppTheme.Spacing.regular) {
                    InputFieldView(label: String(localized: "ppPpk.usl"), text: $viewModel.uslText, unit: "")
                    InputFieldView(label: String(localized: "ppPpk.lsl"), text: $viewModel.lslText, unit: "")
                    InputFieldView(label: String(localized: "ppPpk.mean"), text: $viewModel.meanText, unit: "μ")
                    InputFieldView(label: String(localized: "ppPpk.sigmaOverall"), text: $viewModel.sigmaText, unit: "σ")
                }

                CalculateButton(
                    title: String(localized: "action.calculate"),
                    isEnabled: viewModel.isValid
                ) {
                    withAnimation { viewModel.calculate() }
                }

                if let pp = viewModel.ppResult, let ppk = viewModel.ppkResult {
                    VStack(spacing: AppTheme.Spacing.regular) {
                        ResultCardView(title: "Pp", value: pp.formatted2, unit: "", formula: "Pp = (USL - LSL) / 6σ_overall")
                        ResultCardView(title: "Ppk", value: ppk.formatted2, unit: "", formula: "Ppk = min(Ppu, Ppl)")

                        if let ppu = viewModel.ppuResult, let ppl = viewModel.pplResult {
                            HStack(spacing: AppTheme.Spacing.regular) {
                                miniResult(title: "Ppu", value: ppu.formatted2)
                                miniResult(title: "Ppl", value: ppl.formatted2)
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
        .navigationTitle(String(localized: "category.ppPpk"))
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
