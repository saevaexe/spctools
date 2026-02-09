import SwiftUI

struct ResultCardView: View {
    let title: String
    let value: String
    let unit: String
    let formula: String

    var body: some View {
        VStack(spacing: AppTheme.Spacing.regular) {
            Text(title)
                .font(.headline)
            Text(value)
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
                .contentTransition(.numericText())
            Text(unit)
                .font(.title3)
                .foregroundStyle(.secondary)
            Divider()
            Text(formula)
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: AppTheme.CornerRadius.large))
        .transition(.scale(scale: 0.9).combined(with: .opacity))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(value) \(unit)")
        .accessibilityHint(formula)
    }
}
