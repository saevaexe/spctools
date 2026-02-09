import SwiftUI

struct CalculateButton: View {
    let title: String
    let isEnabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
        }
        .buttonStyle(.borderedProminent)
        .disabled(!isEnabled)
        .accessibilityLabel(title)
        .accessibilityHint(isEnabled
            ? String(localized: "accessibility.tapToCalculate")
            : String(localized: "accessibility.fillFieldsFirst"))
    }
}
