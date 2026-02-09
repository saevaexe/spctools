import SwiftUI
import SwiftData

@main
struct SPCToolsApp: App {
    @State private var subscriptionManager = SubscriptionManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(subscriptionManager)
                .task {
                    await subscriptionManager.loadProducts()
                }
                .task {
                    await subscriptionManager.listenForTransactions()
                }
        }
        .modelContainer(for: CalculationRecord.self)
    }
}
