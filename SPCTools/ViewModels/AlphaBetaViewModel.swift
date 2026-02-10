import Foundation
import SwiftData

@Observable
final class AlphaBetaViewModel {
    var alphaText = "0.05"
    var effectSizeText = ""
    var sampleSizeText = ""

    var result: AlphaBetaEngine.PowerResult?
    var requiredN: Int?
    var interpretation: String?

    var isValid: Bool {
        guard let alpha = parseDouble(alphaText),
              let es = parseDouble(effectSizeText),
              let n = Int(sampleSizeText) else { return false }
        return alpha > 0 && alpha < 1 && es > 0 && n > 0
    }

    func calculate() {
        guard let alpha = parseDouble(alphaText),
              let es = parseDouble(effectSizeText),
              let n = Int(sampleSizeText) else { return }

        result = AlphaBetaEngine.analyze(alpha: alpha, effectSize: es, n: n)
        requiredN = AlphaBetaEngine.requiredSampleSize(alpha: alpha, desiredPower: 0.80, effectSize: es)
        if let r = result {
            interpretation = AlphaBetaEngine.interpretation(power: r.power)
        }
    }

    func saveToHistory(modelContext: ModelContext) {
        guard let r = result else { return }
        let record = CalculationRecord(
            category: .alphaBeta,
            title: String(localized: "category.alphaBeta"),
            inputSummary: "α=\(alphaText), d=\(effectSizeText), n=\(sampleSizeText)",
            resultSummary: "Power: \(r.power.formatted2), β: \(r.beta.formatted2)"
        )
        modelContext.insert(record)
    }

    func reset() {
        alphaText = "0.05"; effectSizeText = ""; sampleSizeText = ""
        result = nil; requiredN = nil; interpretation = nil
    }

    private func parseDouble(_ text: String) -> Double? {
        Double(text.replacingOccurrences(of: ",", with: "."))
    }
}
