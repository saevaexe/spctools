import SwiftUI

struct ContentView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false

    var body: some View {
        if hasSeenOnboarding {
            TabView {
                NavigationStack {
                    HomeView()
                        .navigationDestination(for: CalculationCategory.self) { category in
                            destinationView(for: category)
                        }
                }
                .tabItem {
                    Label(String(localized: "tab.calculator"), systemImage: "function")
                }

                NavigationStack {
                    HistoryListView()
                }
                .tabItem {
                    Label(String(localized: "tab.history"), systemImage: "clock.arrow.circlepath")
                }

                NavigationStack {
                    SettingsView()
                }
                .tabItem {
                    Label(String(localized: "tab.settings"), systemImage: "gearshape")
                }
            }
        } else {
            OnboardingView()
        }
    }

    @ViewBuilder
    private func destinationView(for category: CalculationCategory) -> some View {
        switch category {
        case .cpCpk:            CpCpkView()
        case .oee:              OEEView()
        case .sigmaLevel:       SigmaLevelView()
        case .sampleSize:       SampleSizeView()
        case .formulaReference: FormulaReferenceView()
        case .ppPpk:            PpPpkView()
        case .controlChart:     ControlChartView()
        case .gageRR:           GageRRView()
        case .aqlTable:         AQLTableView()
        case .pareto:           ParetoView()
        case .histogram:        HistogramView()
        case .fmea:             FMEAView()
        case .ishikawa:         IshikawaView()
        case .alphaBeta:        AlphaBetaView()
        case .hypothesisTest:   HypothesisTestView()
        }
    }
}
