import SwiftUI
import RevenueCat

struct PaywallWrapperView: View {
    @Environment(SubscriptionManager.self) private var subscriptionManager
    @Environment(\.dismiss) private var dismiss
    @State private var offering: Offering?
    @State private var isLoadingOffering = true
    @State private var selectedPlan: PlanType = .yearly
    @State private var isPurchasing = false
    @State private var errorMessage: String?

    private enum PlanType {
        case monthly, yearly
    }

    private var monthlyPackage: Package? {
        offering?.availablePackages.first {
            $0.storeProduct.productIdentifier == AppConstants.Subscription.monthlyProductID
        }
    }

    private var yearlyPackage: Package? {
        offering?.availablePackages.first {
            $0.storeProduct.productIdentifier == AppConstants.Subscription.yearlyProductID
        }
    }

    private var selectedPackage: Package? {
        selectedPlan == .monthly ? monthlyPackage : yearlyPackage
    }

    var body: some View {
        NavigationStack {
            Group {
                if offering != nil {
                    paywallContent
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
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                            .font(.title3)
                    }
                }
            }
            .alert(String(localized: "paywall.error"), isPresented: .init(
                get: { errorMessage != nil },
                set: { if !$0 { errorMessage = nil } }
            )) {
                Button("OK") { errorMessage = nil }
            } message: {
                if let msg = errorMessage { Text(msg) }
            }
        }
        .task {
            await loadOffering()
        }
    }

    // MARK: - Paywall Content

    private var paywallContent: some View {
        ScrollView {
            VStack(spacing: AppTheme.Spacing.extraLarge) {
                headerSection
                featuresSection
                productsSection
                purchaseButton
                restoreButton
                legalLinks
                subscriptionDisclosure
            }
            .padding()
            .frame(maxWidth: 500)
            .frame(maxWidth: .infinity)
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: AppTheme.Spacing.regular) {
            Image(systemName: "chart.bar.xaxis.ascending.badge.clock")
                .font(.system(size: 64))
                .foregroundStyle(.blue.gradient)

            Text(String(localized: "paywall.title"))
                .font(.title.bold())
                .multilineTextAlignment(.center)

            Text(String(localized: "paywall.subtitle"))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, AppTheme.Spacing.large)
    }

    // MARK: - Features

    private var featuresSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.regular) {
            featureRow(String(localized: "paywall.feature.allCalculators"))
            featureRow(String(localized: "paywall.feature.unlimitedHistory"))
            featureRow(String(localized: "paywall.feature.allSpcTools"))
        }
        .padding()
        .background(
            Color(.secondarySystemBackground),
            in: RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
        )
    }

    private func featureRow(_ text: String) -> some View {
        HStack(spacing: AppTheme.Spacing.regular) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
            Text(text)
                .font(.subheadline)
        }
    }

    // MARK: - Products

    private var productsSection: some View {
        HStack(spacing: AppTheme.Spacing.regular) {
            if let pkg = monthlyPackage {
                productCard(
                    type: .monthly,
                    price: pkg.storeProduct.localizedPriceString,
                    period: String(localized: "paywall.perMonth")
                )
            }
            if let pkg = yearlyPackage {
                productCard(
                    type: .yearly,
                    price: pkg.storeProduct.localizedPriceString,
                    period: String(localized: "paywall.perYear")
                )
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func productCard(type: PlanType, price: String, period: String) -> some View {
        let isSelected = selectedPlan == type
        let isYearly = type == .yearly

        return Button {
            selectedPlan = type
        } label: {
            VStack(spacing: AppTheme.Spacing.medium) {
                Text(isYearly
                     ? String(localized: "paywall.plan.yearly")
                     : String(localized: "paywall.plan.monthly"))
                    .font(.headline)

                Text(price)
                    .font(.title2.bold())

                Text(period)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, minHeight: 120)
            .padding()
            .background(
                isSelected ? Color.blue.opacity(0.15) : Color(.secondarySystemBackground),
                in: RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                    .stroke(isSelected ? .blue : .clear, lineWidth: 2)
            )
            .overlay(alignment: .top) {
                if isYearly, let savings = savingsPercent {
                    Text(String(
                        format: String(localized: "paywall.savings %lld"),
                        Int64(savings)
                    ))
                    .font(.caption2.weight(.bold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(.green.gradient, in: Capsule())
                    .offset(y: -10)
                }
            }
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
    }

    // MARK: - Purchase Button

    private var purchaseButton: some View {
        Button {
            Task { await purchase() }
        } label: {
            VStack(spacing: AppTheme.Spacing.small) {
                Group {
                    if isPurchasing {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text(String(localized: "paywall.cta"))
                    }
                }
                .font(.headline)
                .frame(maxWidth: .infinity)

                if !isPurchasing, let trialText = trialDetailText {
                    Text(trialText)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.92))
                        .multilineTextAlignment(.center)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(.blue.gradient)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium))
        }
        .disabled(isPurchasing || selectedPackage == nil)
        .opacity(selectedPackage == nil ? 0.6 : 1.0)
    }

    // MARK: - Restore

    private var restoreButton: some View {
        Button {
            Task { await restorePurchases() }
        } label: {
            Text(String(localized: "paywall.restore"))
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Legal Links

    private var legalLinks: some View {
        HStack(spacing: AppTheme.Spacing.large) {
            Link(String(localized: "paywall.termsOfUse"),
                 destination: URL(string: "https://saevaexe.github.io/spctools/terms.html")!)
            Text("·").foregroundStyle(.secondary)
            Link(String(localized: "paywall.privacyPolicy"),
                 destination: URL(string: "https://saevaexe.github.io/spctools/privacy.html")!)
        }
        .font(.caption)
        .foregroundStyle(.secondary)
        .padding(.bottom, AppTheme.Spacing.regular)
    }

    // MARK: - Subscription Disclosure

    private var subscriptionDisclosure: some View {
        Text(String(localized: "paywall.disclosure"))
            .font(.caption2)
            .foregroundStyle(.secondary.opacity(0.75))
            .multilineTextAlignment(.center)
            .lineSpacing(1)
            .padding(.horizontal)
    }

    // MARK: - Computed

    private var savingsPercent: Int? {
        guard
            let monthly = monthlyPackage,
            let yearly = yearlyPackage
        else { return nil }

        let monthlyPrice = monthly.storeProduct.price as Decimal
        let yearlyPrice = yearly.storeProduct.price as Decimal
        guard monthlyPrice > 0 else { return nil }

        let annualMonthlyCost = monthlyPrice * 12
        let savings = ((annualMonthlyCost - yearlyPrice) / annualMonthlyCost) * 100
        let roundedSavings = Int(NSDecimalNumber(decimal: savings).doubleValue.rounded())
        return roundedSavings > 0 ? roundedSavings : nil
    }

    private var trialDetailText: String? {
        guard let package = selectedPackage else { return nil }

        let isYearly = selectedPlan == .yearly
        let format = isYearly
            ? String(localized: "paywall.trialDetail.yearly %@")
            : String(localized: "paywall.trialDetail.monthly %@")
        return String(format: format, package.storeProduct.localizedPriceString)
    }

    // MARK: - Actions

    @MainActor
    private func purchase() async {
        guard let package = selectedPackage else { return }
        isPurchasing = true
        defer { isPurchasing = false }

        do {
            let (_, _, _) = try await Purchases.shared.purchase(package: package)
            await subscriptionManager.checkSubscriptionStatus()
            if subscriptionManager.hasFullAccess {
                dismiss()
            }
        } catch {
            if !((error as NSError).domain == "RevenueCat.ErrorCode" && (error as NSError).code == 1) {
                errorMessage = error.localizedDescription
            }
        }
    }

    @MainActor
    private func restorePurchases() async {
        do {
            _ = try await Purchases.shared.restorePurchases()
            await subscriptionManager.checkSubscriptionStatus()
            if subscriptionManager.hasFullAccess {
                dismiss()
            }
        } catch {
            errorMessage = error.localizedDescription
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

    // MARK: - Unavailable View

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
