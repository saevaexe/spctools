import Foundation
import SwiftData

@Observable
final class SampleSizeViewModel {
    var selectedConfidence: Double = 0.95
    var marginOfErrorText = ""
    var populationText = ""
    var proportionText = "0.5"

    var sampleSizeResult: Int?
    var adjustedSampleSize: Int?

    var isValid: Bool {
        guard let margin = parseDouble(marginOfErrorText),
              let prop = parseDouble(proportionText) else { return false }
        return margin > 0 && margin < 1 && prop > 0 && prop <= 1
    }

    func calculate() {
        guard let margin = parseDouble(marginOfErrorText),
              let prop = parseDouble(proportionText) else { return }

        sampleSizeResult = SampleSizeEngine.sampleSizeProportion(
            confidenceLevel: selectedConfidence,
            marginOfError: margin,
            proportion: prop
        )

        if let popText = parseDouble(populationText), popText > 0, let n = sampleSizeResult {
            adjustedSampleSize = SampleSizeEngine.adjustForPopulation(
                sampleSize: n,
                population: Int(popText)
            )
        } else {
            adjustedSampleSize = nil
        }
    }

    func saveToHistory(modelContext: ModelContext) {
        guard let n = sampleSizeResult else { return }
        let finalN = adjustedSampleSize ?? n
        let record = CalculationRecord(
            category: .sampleSize,
            title: String(localized: "category.sampleSize"),
            inputSummary: String(localized: "sampleSize.history.input \(Int(selectedConfidence * 100)) \(marginOfErrorText)"),
            resultSummary: "n = \(finalN)"
        )
        modelContext.insert(record)
    }

    func reset() {
        selectedConfidence = 0.95
        marginOfErrorText = ""
        populationText = ""
        proportionText = "0.5"
        sampleSizeResult = nil
        adjustedSampleSize = nil
    }

    private func parseDouble(_ text: String) -> Double? {
        Double(text.replacingOccurrences(of: ",", with: "."))
    }
}
