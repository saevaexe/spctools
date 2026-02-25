import Foundation
import SwiftData

@Observable
final class GageRRViewModel {
    var numOperators = "2"
    var numParts = "5"
    var numTrials = "3"
    var dataText = ""

    var result: GageRREngine.GageRRResult?
    var interpretation: String?

    var isValid: Bool {
        guard let ops = Int(numOperators), let parts = Int(numParts), let trials = Int(numTrials) else { return false }
        let values = parseData(dataText)
        return ops >= 2 && parts >= 2 && trials >= 2 && values.count == ops * parts * trials
    }

    func calculate() {
        guard let ops = Int(numOperators), let parts = Int(numParts), let trials = Int(numTrials) else { return }
        let values = parseData(dataText)
        guard values.count == ops * parts * trials else { return }

        // Reshape flat array to [operator][part][trial]
        var measurements: [[[Double]]] = []
        var idx = 0
        for _ in 0..<ops {
            var opData: [[Double]] = []
            for _ in 0..<parts {
                var trialData: [Double] = []
                for _ in 0..<trials {
                    trialData.append(values[idx])
                    idx += 1
                }
                opData.append(trialData)
            }
            measurements.append(opData)
        }

        result = GageRREngine.calculate(measurements: measurements)
        if let r = result {
            interpretation = GageRREngine.interpretation(percentGRR: r.percentGRR)
        }
    }

    func saveToHistory(modelContext: ModelContext) {
        guard let r = result else { return }
        let record = CalculationRecord(
            category: .gageRR,
            title: String(localized: "category.gageRR"),
            inputSummary: "\(numOperators) ops × \(numParts) parts × \(numTrials) trials",
            resultSummary: "%GRR: \(r.percentGRR.formatted2)%, NDC: \(r.ndc)"
        )
        modelContext.insert(record)
    }

    func reset() {
        numOperators = "2"; numParts = "5"; numTrials = "3"; dataText = ""
        result = nil; interpretation = nil
    }

    private func parseData(_ text: String) -> [Double] {
        text.components(separatedBy: CharacterSet(charactersIn: ";\n "))
            .compactMap { Double($0.trimmingCharacters(in: .whitespaces).replacingOccurrences(of: ",", with: ".")) }
    }
}
