import SwiftUI
import Charts

struct ParetoView: View {
    @State private var viewModel = ParetoViewModel()
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        ScrollView {
            VStack(spacing: AppTheme.Spacing.large) {
                VStack(spacing: AppTheme.Spacing.regular) {
                    DataInputView(label: String(localized: "pareto.categories"), text: $viewModel.categoriesText)
                    DataInputView(label: String(localized: "pareto.counts"), text: $viewModel.countsText)
                }

                CalculateButton(
                    title: String(localized: "action.calculate"),
                    isEnabled: viewModel.isValid
                ) {
                    withAnimation { viewModel.calculate() }
                }

                if !viewModel.items.isEmpty {
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
                        Text(String(localized: "pareto.chart")).font(.headline)

                        Chart {
                            ForEach(viewModel.items) { item in
                                BarMark(
                                    x: .value("Category", item.category),
                                    y: .value("Count", item.count)
                                )
                                .foregroundStyle(.blue.opacity(0.7))
                            }
                            ForEach(viewModel.items) { item in
                                LineMark(
                                    x: .value("Category", item.category),
                                    y: .value("Cumulative", item.cumulativePercentage / 100 * Double(viewModel.items.first?.count ?? 1))
                                )
                                .foregroundStyle(.red)
                                PointMark(
                                    x: .value("Category", item.category),
                                    y: .value("Cumulative", item.cumulativePercentage / 100 * Double(viewModel.items.first?.count ?? 1))
                                )
                                .foregroundStyle(.red)
                            }
                            RuleMark(y: .value("80%", 0.8 * Double(viewModel.items.first?.count ?? 1)))
                                .foregroundStyle(.orange)
                                .lineStyle(StrokeStyle(dash: [5, 3]))
                        }
                        .frame(height: 250)
                    }
                    .padding()
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium))

                    // Vital few
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
                        Text(String(localized: "pareto.vitalFew")).font(.headline)
                        ForEach(viewModel.vitalFewItems) { item in
                            HStack {
                                Text(item.category).font(.subheadline)
                                Spacer()
                                Text("\(item.count)").font(.subheadline.bold())
                                Text("(\(item.percentage.formatted2)%)").font(.caption).foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding()
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium))

                    Button(String(localized: "action.saveHistory")) {
                        viewModel.saveToHistory(modelContext: modelContext)
                    }
                    .font(.subheadline)
                }
            }
            .padding()
            .frame(maxWidth: 600)
        }
        .navigationTitle(String(localized: "category.pareto"))
        .hideKeyboardOnTap()
    }
}
