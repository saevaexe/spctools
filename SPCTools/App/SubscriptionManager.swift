import Foundation
import RevenueCat

@Observable
final class SubscriptionManager {
    static let shared = SubscriptionManager()

    var isSubscribed: Bool = false
    var isLoading: Bool = false

    var isTrialActive: Bool {
        guard !isSubscribed else { return false }
        guard let installDate = installDate else { return false }
        return Date().timeIntervalSince(installDate) < 7 * 24 * 3600
    }

    var hasFullAccess: Bool { isSubscribed || isTrialActive }

    var trialDaysRemaining: Int {
        guard let installDate = installDate else { return 0 }
        let elapsed = Date().timeIntervalSince(installDate)
        let remaining = 7 - Int(elapsed / 86400)
        return max(0, remaining)
    }

    private static let installDateKey = "appInstallDate"

    private var installDate: Date? {
        get { UserDefaults.standard.object(forKey: Self.installDateKey) as? Date }
        set { UserDefaults.standard.set(newValue, forKey: Self.installDateKey) }
    }

    private init() {
        if installDate == nil {
            installDate = Date()
        }
    }

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
            isSubscribed = customerInfo.entitlements[AppConstants.Subscription.entitlementID]?.isActive == true
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
            isSubscribed = customerInfo.entitlements[AppConstants.Subscription.entitlementID]?.isActive == true
        } catch {
            print("Failed to restore purchases: \(error)")
        }
    }
}
