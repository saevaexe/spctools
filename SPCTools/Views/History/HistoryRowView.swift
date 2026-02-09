import SwiftUI

struct HistoryRowView: View {
    let record: CalculationRecord
    var onToggleFavorite: (() -> Void)?

    var body: some View {
        HStack(spacing: AppTheme.Spacing.regular) {
            if let category = record.calculationCategory {
                Image(systemName: category.iconName)
                    .font(.title3)
                    .foregroundStyle(category.color)
                    .frame(width: 36)
            }
            VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
                Text(record.title)
                    .font(.headline)
                Text(record.resultSummary)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(record.inputSummary)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: AppTheme.Spacing.small) {
                Button {
                    onToggleFavorite?()
                } label: {
                    Image(systemName: record.isFavorite ? "star.fill" : "star")
                        .foregroundStyle(record.isFavorite ? .yellow : .gray)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(record.isFavorite
                    ? String(localized: "accessibility.removeFavorite")
                    : String(localized: "accessibility.addFavorite"))

                Text(record.timestamp, style: .relative)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, AppTheme.Spacing.small)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(record.title). \(record.resultSummary)")
    }
}
