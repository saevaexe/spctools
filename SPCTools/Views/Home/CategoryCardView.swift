import SwiftUI

struct CategoryCardView: View {
    let category: CalculationCategory
    var animationDelay: Double = 0
    var showProBadge: Bool = false

    @Environment(\.colorScheme) private var colorScheme
    @State private var isAppearing = false

    var body: some View {
        VStack(spacing: AppTheme.Spacing.regular) {
            Image(systemName: category.iconName)
                .font(.system(size: 32))
                .foregroundStyle(category.color)
            Text(category.title)
                .font(.headline)
                .multilineTextAlignment(.center)
            Text(category.subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, minHeight: 140)
        .padding()
        .background(
            category.color.opacity(colorScheme == .dark ? 0.15 : 0.1),
            in: RoundedRectangle(cornerRadius: AppTheme.CornerRadius.large)
        )
        .overlay(alignment: .topTrailing) {
            if showProBadge {
                ProBadgeView()
                    .padding(8)
            }
        }
        .opacity(showProBadge ? 0.75 : 1.0)
        .scaleEffect(isAppearing ? 1.0 : 0.92)
        .opacity(isAppearing ? 1.0 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.75).delay(animationDelay)) {
                isAppearing = true
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(category.title). \(category.subtitle)")
        .accessibilityAddTraits(.isButton)
    }
}
