import SwiftUI

struct InputFieldView: View {
    let label: String
    @Binding var text: String
    let unit: String
    var placeholder: String = "0"
    var isDisabled: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            HStack {
                TextField(placeholder, text: $text)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(.roundedBorder)
                    .disabled(isDisabled)
                    .opacity(isDisabled ? 0.5 : 1.0)
                    .accessibilityLabel(label)
                    .accessibilityValue(text.isEmpty ? String(localized: "accessibility.empty") : "\(text) \(unit)")
                Text(unit)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .frame(width: 40, alignment: .leading)
            }
        }
    }
}
