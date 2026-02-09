import SwiftUI

struct DataInputView: View {
    let label: String
    @Binding var text: String
    var placeholder: String = "1.2, 3.4, 5.6"

    var parsedValues: [Double] {
        text.replacingOccurrences(of: ",", with: " ")
            .split(separator: " ")
            .compactMap { Double($0.trimmingCharacters(in: .whitespaces).replacingOccurrences(of: ",", with: ".")) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
            HStack {
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(String(localized: "dataInput.count \(parsedValues.count)"))
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            TextField(placeholder, text: $text, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(3...6)
                .keyboardType(.numbersAndPunctuation)
                .accessibilityLabel(label)
            if !text.isEmpty {
                Button(String(localized: "dataInput.clear")) {
                    text = ""
                }
                .font(.caption)
                .foregroundStyle(.red)
            }
        }
    }
}
