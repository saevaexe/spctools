import SwiftUI

struct AQLTableView: View {
    @State private var viewModel = AQLViewModel()
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        ScrollView {
            VStack(spacing: AppTheme.Spacing.large) {
                VStack(spacing: AppTheme.Spacing.regular) {
                    InputFieldView(label: String(localized: "aql.lotSize"), text: $viewModel.lotSizeText, unit: "")

                    // Inspection level picker
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
                        Text(String(localized: "aql.inspectionLevel")).font(.subheadline).foregroundStyle(.secondary)
                        Picker("", selection: $viewModel.selectedLevel) {
                            ForEach(AQLEngine.inspectionLevels, id: \.self) { level in
                                Text(level).tag(level)
                            }
                        }
                        .pickerStyle(.segmented)
                    }

                    // AQL picker
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
                        Text(String(localized: "aql.aqlValue")).font(.subheadline).foregroundStyle(.secondary)
                        Picker("", selection: $viewModel.selectedAQL) {
                            ForEach(AppConstants.AQL.aqlValues, id: \.self) { value in
                                Text("\(value, specifier: value < 1 ? "%.3f" : "%.1f")").tag(value)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(height: 100)
                    }
                }

                CalculateButton(
                    title: String(localized: "action.calculate"),
                    isEnabled: viewModel.isValid
                ) {
                    withAnimation { viewModel.calculate() }
                }

                if let plan = viewModel.plan {
                    VStack(spacing: AppTheme.Spacing.regular) {
                        HStack(spacing: AppTheme.Spacing.regular) {
                            miniResult(title: String(localized: "aql.codeLetter"), value: plan.codeLetter)
                            miniResult(title: String(localized: "aql.sampleSize"), value: "\(plan.sampleSize)")
                        }
                        HStack(spacing: AppTheme.Spacing.regular) {
                            miniResult(title: String(localized: "aql.accept"), value: "\(plan.acceptNumber)")
                            miniResult(title: String(localized: "aql.reject"), value: "\(plan.rejectNumber)")
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
        .navigationTitle(String(localized: "category.aqlTable"))
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
