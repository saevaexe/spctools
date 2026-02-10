import SwiftUI

struct FMEAView: View {
    @State private var viewModel = FMEAViewModel()
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        ScrollView {
            VStack(spacing: AppTheme.Spacing.large) {
                // Input section
                VStack(spacing: AppTheme.Spacing.regular) {
                    InputFieldView(label: String(localized: "fmea.failureMode"), text: $viewModel.failureModeText, unit: "")

                    sliderRow(label: String(localized: "fmea.severity"), value: $viewModel.severity)
                    sliderRow(label: String(localized: "fmea.occurrence"), value: $viewModel.occurrence)
                    sliderRow(label: String(localized: "fmea.detection"), value: $viewModel.detection)

                    // Live RPN preview
                    HStack {
                        Text("RPN").font(.headline)
                        Spacer()
                        Text("\(viewModel.currentRPN)")
                            .font(.title2.bold())
                            .foregroundStyle(viewModel.currentRPN >= 200 ? .red : viewModel.currentRPN >= 120 ? .orange : .green)
                    }
                    .padding()
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium))
                }

                CalculateButton(
                    title: String(localized: "fmea.addItem"),
                    isEnabled: viewModel.isValid
                ) {
                    withAnimation { viewModel.addItem() }
                }

                // Items list
                if !viewModel.items.isEmpty {
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
                        Text(String(localized: "fmea.itemsList")).font(.headline)

                        ForEach(viewModel.items) { item in
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(item.failureMode).font(.subheadline.bold())
                                    Text("S:\(item.severity) O:\(item.occurrence) D:\(item.detection)")
                                        .font(.caption).foregroundStyle(.secondary)
                                }
                                Spacer()
                                VStack(alignment: .trailing) {
                                    Text("RPN: \(item.rpn)").font(.subheadline.bold())
                                        .foregroundStyle(item.rpn >= 200 ? .red : item.rpn >= 120 ? .orange : .green)
                                    Text(item.priority).font(.caption).foregroundStyle(.secondary)
                                }
                            }
                            .padding()
                            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: AppTheme.CornerRadius.small))
                            .swipeActions { Button(role: .destructive) { viewModel.removeItem(item) } label: { Label("", systemImage: "trash") } }
                        }
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
        .navigationTitle(String(localized: "category.fmea"))
        .hideKeyboardOnTap()
    }

    private func sliderRow(label: String, value: Binding<Int>) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
            HStack {
                Text(label).font(.subheadline).foregroundStyle(.secondary)
                Spacer()
                Text("\(value.wrappedValue)").font(.subheadline.bold())
            }
            Slider(value: Binding(
                get: { Double(value.wrappedValue) },
                set: { value.wrappedValue = Int($0) }
            ), in: 1...10, step: 1)
        }
    }
}
