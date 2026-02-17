import SwiftUI
import RevenueCat
import RevenueCatUI

struct PaywallWrapperView: View {
    @Environment(SubscriptionManager.self) private var subscriptionManager
    @Environment(\.dismiss) private var dismiss
    @State private var offering: Offering?
    @State private var isLoadingOffering = true

    var body: some View {
        VStack(spacing: 0) {
            Group {
                if let offering {
                    PaywallView(offering: offering)
                        .onPurchaseCompleted { _ in
                            Task { await subscriptionManager.checkSubscriptionStatus() }
                            dismiss()
                        }
                        .onRestoreCompleted { _ in
                            Task { await subscriptionManager.checkSubscriptionStatus() }
                            dismiss()
                        }
                } else if isLoadingOffering {
                    VStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                } else {
                    unavailableView
                }
            }

            VStack(spacing: AppTheme.Spacing.medium) {
                Text(String(localized: "paywall.disclosure"))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                HStack(spacing: AppTheme.Spacing.large) {
                    Link(String(localized: "paywall.termsOfUse"), destination: URL(string: "https://saevaexe.github.io/spctools/terms.html")!)
                    Text(verbatim: "·").foregroundStyle(.secondary)
                    Link(String(localized: "paywall.privacyPolicy"), destination: URL(string: "https://saevaexe.github.io/spctools/privacy.html")!)
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            .padding(.bottom, AppTheme.Spacing.regular)
        }
        .task {
            await loadOffering()
        }
    }

    @MainActor
    private func loadOffering() async {
        isLoadingOffering = true
        defer { isLoadingOffering = false }

        do {
            let offerings = try await Purchases.shared.offerings()
            if let current = offerings.current, !current.availablePackages.isEmpty {
                offering = current
            } else {
                offering = nil
                print("Paywall unavailable: current offering is missing purchasable packages.")
            }
        } catch {
            offering = nil
            print("Failed to load offerings: \(error)")
        }
    }

    private var unavailableView: some View {
        VStack(spacing: AppTheme.Spacing.large) {
            Spacer()
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 34, weight: .semibold))
                .foregroundStyle(.orange)

            Text(String(localized: "subscription.expired.banner"))
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button {
                Task {
                    await subscriptionManager.restorePurchases()
                    await subscriptionManager.checkSubscriptionStatus()

                    if subscriptionManager.hasFullAccess {
                        dismiss()
                    }
                }
            } label: {
                Text(String(localized: "paywall.restore"))
                    .font(.subheadline.bold())
                    .padding(.horizontal, AppTheme.Spacing.large)
                    .padding(.vertical, AppTheme.Spacing.medium)
                    .background(.blue.opacity(0.1), in: Capsule())
            }
            .buttonStyle(.plain)

            Button {
                dismiss()
            } label: {
                Text(String(localized: "onboarding.trial.maybeLater"))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}
