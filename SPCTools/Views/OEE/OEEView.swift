import SwiftUI

struct OEEView: View {
    @State private var viewModel = OEEViewModel()
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        ScrollView {
            VStack(spacing: AppTheme.Spacing.large) {
                VStack(spacing: AppTheme.Spacing.regular) {
                    InputFieldView(label: String(localized: "oee.plannedTime"), text: $viewModel.plannedTimeText, unit: String(localized: "unit.min"))
                    InputFieldView(label: String(localized: "oee.downtime"), text: $viewModel.downtimeText, unit: String(localized: "unit.min"))
                    InputFieldView(label: String(localized: "oee.idealCycleTime"), text: $viewModel.idealCycleTimeText, unit: String(localized: "unit.min"))
                    InputFieldView(label: String(localized: "oee.totalCount"), text: $viewModel.totalCountText, unit: String(localized: "unit.pcs"))
                    InputFieldView(label: String(localized: "oee.defectCount"), text: $viewModel.defectCountText, unit: String(localized: "unit.pcs"))
                }

                CalculateButton(
                    title: String(localized: "action.calculate"),
                    isEnabled: viewModel.isValid
                ) {
                    withAnimation { viewModel.calculate() }
                }

                if let oee = viewModel.oeeResult {
                    VStack(spacing: AppTheme.Spacing.regular) {
                        ResultCardView(
                            title: "OEE",
                            value: oee.formatted2,
                            unit: "%",
                            formula: "OEE = A × P × Q"
                        )

                        HStack(spacing: AppTheme.Spacing.regular) {
                            if let a = viewModel.availabilityResult {
                                miniResult(title: String(localized: "oee.availability"), value: "\(a.formatted2)%", color: .blue)
                            }
                            if let p = viewModel.performanceResult {
                                miniResult(title: String(localized: "oee.performance"), value: "\(p.formatted2)%", color: .green)
                            }
                            if let q = viewModel.qualityResult {
                                miniResult(title: String(localized: "oee.quality"), value: "\(q.formatted2)%", color: .orange)
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
        .navigationTitle(String(localized: "category.oee"))
        .hideKeyboardOnTap()
    }

    private func miniResult(title: String, value: String, color: Color) -> some View {
        VStack(spacing: AppTheme.Spacing.small) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.headline)
                .foregroundStyle(color)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium))
    }
}
