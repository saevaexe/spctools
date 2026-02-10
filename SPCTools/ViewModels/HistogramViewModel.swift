import Foundation
import SwiftData

@Observable
final class HistogramViewModel {
    var dataText = ""
    var customBinCount = ""

    var result: HistogramEngine.HistogramResult?

    var isValid: Bool {
        parseData(dataText).count >= 2
    }

    func calculate() {
        let values = parseData(dataText)
        let binCount = Int(customBinCount)
        result = HistogramEngine.analyze(data: values, binCount: binCount)
    }

    func saveToHistory(modelContext: ModelContext) {
        guard let r = result else { return }
        let record = CalculationRecord(
            category: .histogram,
            title: String(localized: "category.histogram"),
            inputSummary: "\(r.count) data points",
            resultSummary: "μ=\(r.mean.formatted2), σ=\(r.standardDeviation.formatted2)"
        )
        modelContext.insert(record)
    }

    func reset() {
        dataText = ""; customBinCount = ""; result = nil
    }

    private func parseData(_ text: String) -> [Double] {
        text.components(separatedBy: CharacterSet(charactersIn: ",;\n "))
            .compactMap { Double($0.trimmingCharacters(in: .whitespaces).replacingOccurrences(of: ",", with: ".")) }
    }
}
