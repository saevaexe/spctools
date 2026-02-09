import Foundation
import StoreKit

@Observable
final class SubscriptionManager {
    static let shared = SubscriptionManager()

    var products: [Product] = []
    var purchasedProductIDs: Set<String> = []
    var isLoading: Bool = false

    var isSubscribed: Bool { !purchasedProductIDs.isEmpty }

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

    private var transactionListener: Task<Void, Never>?

    private init() {
        if installDate == nil {
            installDate = Date()
        }
    }

    // MARK: - Product Loading

    func loadProducts() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let productIDs: Set<String> = [
                AppConstants.Subscription.monthlyProductID,
                AppConstants.Subscription.yearlyProductID
            ]
            products = try await Product.products(for: productIDs)
                .sorted { $0.price < $1.price }
        } catch {
            print("Failed to load products: \(error)")
        }

        await checkCurrentEntitlements()
    }

    // MARK: - Purchase

    func purchase(_ product: Product) async throws -> Bool {
        let result = try await product.purchase()

        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            purchasedProductIDs.insert(transaction.productID)
            await transaction.finish()
            return true
        case .userCancelled:
            return false
        case .pending:
            return false
        @unknown default:
            return false
        }
    }

    // MARK: - Restore

    func restorePurchases() async {
        try? await AppStore.sync()
        await checkCurrentEntitlements()
    }

    // MARK: - Transaction Listener

    func listenForTransactions() async {
        for await result in Transaction.updates {
            do {
                let transaction = try checkVerified(result)
                if transaction.revocationDate == nil {
                    purchasedProductIDs.insert(transaction.productID)
                } else {
                    purchasedProductIDs.remove(transaction.productID)
                }
                await transaction.finish()
            } catch {
                print("Transaction verification failed: \(error)")
            }
        }
    }

    // MARK: - Entitlements Check

    func checkCurrentEntitlements() async {
        var activeIDs: Set<String> = []

        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                if transaction.revocationDate == nil {
                    activeIDs.insert(transaction.productID)
                }
            } catch {
                print("Entitlement verification failed: \(error)")
            }
        }

        purchasedProductIDs = activeIDs
    }

    // MARK: - Helpers

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.verificationFailed
        case .verified(let safe):
            return safe
        }
    }

    enum StoreError: Error {
        case verificationFailed
    }
}
