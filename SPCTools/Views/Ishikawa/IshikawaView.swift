import SwiftUI

struct IshikawaView: View {
    @State private var viewModel = IshikawaViewModel()
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        ScrollView {
            VStack(spacing: AppTheme.Spacing.large) {
                if viewModel.diagram == nil {
                    // Setup
                    VStack(spacing: AppTheme.Spacing.regular) {
                        InputFieldView(label: String(localized: "ishikawa.problem"), text: $viewModel.problemText, unit: "")

                        CalculateButton(
                            title: String(localized: "ishikawa.create"),
                            isEnabled: viewModel.isValid
                        ) {
                            withAnimation { viewModel.createDiagram() }
                        }
                    }
                } else if let diagram = viewModel.diagram {
                    // Problem header
                    Text(diagram.problem)
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(.blue.opacity(0.1), in: RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium))

                    // Add cause
                    VStack(spacing: AppTheme.Spacing.small) {
                        Picker(String(localized: "ishikawa.category"), selection: $viewModel.selectedCategoryIndex) {
                            ForEach(Array(diagram.categories.enumerated()), id: \.offset) { index, cat in
                                Text(cat.name).tag(index)
                            }
                        }
                        .pickerStyle(.segmented)

                        HStack {
                            TextField(String(localized: "ishikawa.causePlaceholder"), text: $viewModel.newCauseText)
                                .textFieldStyle(.roundedBorder)
                            Button(action: { withAnimation { viewModel.addCause() } }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                            }
                            .disabled(viewModel.newCauseText.trimmingCharacters(in: .whitespaces).isEmpty)
                        }
                    }

                    // 6M Categories
                    ForEach(Array(diagram.categories.enumerated()), id: \.offset) { catIndex, category in
                        VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
                            HStack {
                                Image(systemName: categoryIcon(catIndex))
                                    .foregroundStyle(.blue)
                                Text(category.name).font(.headline)
                                Spacer()
                                Text("\(category.causes.count)").font(.caption).foregroundStyle(.secondary)
                            }

                            if category.causes.isEmpty {
                                Text(String(localized: "ishikawa.noCauses"))
                                    .font(.caption).foregroundStyle(.tertiary)
                            } else {
                                ForEach(Array(category.causes.enumerated()), id: \.offset) { causeIndex, cause in
                                    HStack {
                                        Text("• \(cause)").font(.subheadline)
                                        Spacer()
                                        Button(action: { withAnimation { viewModel.removeCause(categoryIndex: catIndex, causeIndex: causeIndex) } }) {
                                            Image(systemName: "minus.circle").foregroundStyle(.red).font(.caption)
                                        }
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium))
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
        .navigationTitle(String(localized: "category.ishikawa"))
        .hideKeyboardOnTap()
    }

    private func categoryIcon(_ index: Int) -> String {
        ["person.fill", "gearshape.fill", "list.bullet", "shippingbox.fill", "ruler.fill", "leaf.fill"][index % 6]
    }
}
