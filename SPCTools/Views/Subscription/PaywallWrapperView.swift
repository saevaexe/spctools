import SwiftUI
import RevenueCatUI

struct PaywallWrapperView: View {
    @Environment(SubscriptionManager.self) private var subscriptionManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        PaywallView()
            .onPurchaseCompleted { _ in
                Task { await subscriptionManager.checkSubscriptionStatus() }
                dismiss()
            }
            .onRestoreCompleted { _ in
                Task { await subscriptionManager.checkSubscriptionStatus() }
                dismiss()
            }
    }
}
