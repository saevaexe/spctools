import Foundation
import RevenueCat

@Observable
final class SubscriptionManager {
    static let shared = SubscriptionManager()

    var isSubscribed: Bool = false
    var isTrialActive: Bool = false
    var isLoading: Bool = false

    var hasFullAccess: Bool { isSubscribed || isTrialActive }

    var trialDaysRemaining: Int {
        guard isTrialActive, let expirationDate = trialExpirationDate else { return 0 }
        let remaining = Int(ceil(expirationDate.timeIntervalSinceNow / 86400))
        return max(0, remaining)
    }

    private var trialExpirationDate: Date?

    private init() { }

    // MARK: - Configuration

    func configure() {
        #if DEBUG
        Purchases.logLevel = .debug
        #endif
        Purchases.configure(withAPIKey: AppConstants.Subscription.revenueCatAPIKey)
    }

    // MARK: - Check Subscription

    func checkSubscriptionStatus() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let customerInfo = try await Purchases.shared.customerInfo()
            updateEntitlementState(from: customerInfo)
        } catch {
            print("Failed to check subscription: \(error)")
        }
    }

    // MARK: - Restore

    func restorePurchases() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let customerInfo = try await Purchases.shared.restorePurchases()
            updateEntitlementState(from: customerInfo)
        } catch {
            print("Failed to restore purchases: \(error)")
        }
    }

    private func updateEntitlementState(from customerInfo: CustomerInfo) {
        let entitlement = customerInfo.entitlements[AppConstants.Subscription.entitlementID]
        let isActive = entitlement?.isActive == true
        let isTrial = isActive && entitlement?.periodType == .trial

        isTrialActive = isTrial
        isSubscribed = isActive && !isTrial
        trialExpirationDate = isTrial ? entitlement?.expirationDate : nil
    }
}
