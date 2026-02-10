import SwiftUI

struct HypothesisTestView: View {
    @State private var viewModel = HypothesisTestViewModel()
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        ScrollView {
            VStack(spacing: AppTheme.Spacing.large) {
                // Test type picker
                Picker("", selection: $viewModel.testType) {
                    ForEach(HypothesisTestEngine.TestType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(.segmented)

                // Alternative hypothesis
                VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
                    Text(String(localized: "hypothesis.alternative")).font(.subheadline).foregroundStyle(.secondary)
                    Picker("", selection: $viewModel.alternative) {
                        ForEach(HypothesisTestEngine.Alternative.allCases, id: \.self) { alt in
                            Text("H₁: μ \(alt.rawValue) μ₀").tag(alt)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                // Inputs
                VStack(spacing: AppTheme.Spacing.regular) {
                    InputFieldView(label: String(localized: "hypothesis.alpha"), text: $viewModel.alphaText, unit: "α")
                    InputFieldView(label: String(localized: "hypothesis.sampleMean"), text: $viewModel.sampleMeanText, unit: "x̄")

                    if viewModel.testType != .twoSampleT {
                        InputFieldView(label: String(localized: "hypothesis.mu0"), text: $viewModel.mu0Text, unit: "μ₀")
                    }

                    if viewModel.testType == .oneSampleZ {
                        InputFieldView(label: String(localized: "hypothesis.sigma"), text: $viewModel.sigmaText, unit: "σ")
                    }

                    if viewModel.testType == .oneSampleT || viewModel.testType == .twoSampleT {
                        InputFieldView(label: String(localized: "hypothesis.sampleStdDev"), text: $viewModel.sampleStdDevText, unit: "s₁")
                    }

                    InputFieldView(label: String(localized: "hypothesis.n"), text: $viewModel.nText, unit: "n₁")

                    if viewModel.testType == .twoSampleT {
                        InputFieldView(label: String(localized: "hypothesis.mean2"), text: $viewModel.mean2Text, unit: "x̄₂")
                        InputFieldView(label: String(localized: "hypothesis.s2"), text: $viewModel.s2Text, unit: "s₂")
                        InputFieldView(label: String(localized: "hypothesis.n2"), text: $viewModel.n2Text, unit: "n₂")
                    }
                }

                CalculateButton(
                    title: String(localized: "action.calculate"),
                    isEnabled: viewModel.isValid
                ) {
                    withAnimation { viewModel.calculate() }
                }

                if let r = viewModel.result {
                    VStack(spacing: AppTheme.Spacing.regular) {
                        HStack(spacing: AppTheme.Spacing.regular) {
                            miniResult(title: String(localized: "hypothesis.testStat"), value: r.testStatistic.formatted2)
                            miniResult(title: "p-value", value: r.pValue < 0.001 ? "<0.001" : r.pValue.formatted2)
                        }

                        Text(r.conclusion)
                            .font(.subheadline.bold())
                            .foregroundStyle(r.reject ? .red : .green)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                (r.reject ? Color.red : Color.green).opacity(0.1),
                                in: RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                            )

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
        .navigationTitle(String(localized: "category.hypothesisTest"))
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
