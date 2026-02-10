import SwiftUI
import SwiftData

@main
struct SPCToolsApp: App {
    @State private var subscriptionManager = SubscriptionManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(subscriptionManager)
                .onAppear {
                    subscriptionManager.configure()
                }
                .task {
                    await subscriptionManager.checkSubscriptionStatus()
                }
        }
        .modelContainer(for: CalculationRecord.self)
    }
}
