import SwiftUI
import RevenueCatUI

struct PaywallWrapperView: View {
    @Environment(SubscriptionManager.self) private var subscriptionManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            PaywallView()
                .onPurchaseCompleted { _ in
                    Task { await subscriptionManager.checkSubscriptionStatus() }
                    dismiss()
                }
                .onRestoreCompleted { _ in
                    Task { await subscriptionManager.checkSubscriptionStatus() }
                    dismiss()
                }

            VStack(spacing: AppTheme.Spacing.medium) {
                Text(String(localized: "paywall.disclosure"))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                HStack(spacing: AppTheme.Spacing.large) {
                    Link(String(localized: "paywall.termsOfUse"), destination: URL(string: "https://saevaexe.github.io/spctools/terms.html")!)
                    Text("·").foregroundStyle(.secondary)
                    Link(String(localized: "paywall.privacyPolicy"), destination: URL(string: "https://saevaexe.github.io/spctools/privacy.html")!)
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            .padding(.bottom, AppTheme.Spacing.regular)
        }
    }
}
