import SwiftUI

struct ContentView: View {
    var body: some View {
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
    }

    @ViewBuilder
    private func destinationView(for category: CalculationCategory) -> some View {
        switch category {
        case .cpCpk:            CpCpkView()
        case .oee:              OEEView()
        case .sigmaLevel:       SigmaLevelView()
        case .sampleSize:       SampleSizeView()
        case .formulaReference: FormulaReferenceView()
        case .ppPpk:            Text("Pp/Ppk") // Placeholder
        case .controlChart:     Text("Control Charts") // Placeholder
        case .gageRR:           Text("Gage R&R") // Placeholder
        case .aqlTable:         Text("AQL Table") // Placeholder
        case .pareto:           Text("Pareto") // Placeholder
        case .histogram:        Text("Histogram") // Placeholder
        case .fmea:             Text("FMEA") // Placeholder
        case .ishikawa:         Text("Ishikawa") // Placeholder
        case .alphaBeta:        Text("Alpha/Beta") // Placeholder
        case .hypothesisTest:   Text("Hypothesis Test") // Placeholder
        }
    }
}
