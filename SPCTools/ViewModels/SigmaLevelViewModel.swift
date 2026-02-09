import Foundation
import SwiftData

@Observable
final class SigmaLevelViewModel {
    var defectsText = ""
    var unitsText = ""
    var opportunitiesText = ""

    var dpmoResult: Double?
    var sigmaResult: Double?
    var yieldResult: Double?
    var interpretation: String?

    var isValid: Bool {
        guard let defects = parseDouble(defectsText),
              let units = parseDouble(unitsText),
              let opps = parseDouble(opportunitiesText) else { return false }
        return defects >= 0 && units > 0 && opps > 0
    }

    func calculate() {
        guard let defects = parseDouble(defectsText),
              let units = parseDouble(unitsText),
              let opps = parseDouble(opportunitiesText) else { return }

        dpmoResult = SigmaLevelEngine.dpmo(defects: defects, units: units, opportunities: opps)
        sigmaResult = SigmaLevelEngine.sigmaFromDPMO(dpmoResult ?? 0)
        yieldResult = SigmaLevelEngine.yieldFromDPMO(dpmoResult ?? 0)
        interpretation = SigmaLevelEngine.interpretation(sigmaResult ?? 0)
    }

    func saveToHistory(modelContext: ModelContext) {
        guard let sigma = sigmaResult, let dpmo = dpmoResult else { return }
        let record = CalculationRecord(
            category: .sigmaLevel,
            title: String(localized: "category.sigmaLevel"),
            inputSummary: String(localized: "sigma.history.input \(defectsText) \(unitsText) \(opportunitiesText)"),
            resultSummary: "σ: \(sigma.formatted2), DPMO: \(dpmo.formatted2)"
        )
        modelContext.insert(record)
    }

    func reset() {
        defectsText = ""
        unitsText = ""
        opportunitiesText = ""
        dpmoResult = nil
        sigmaResult = nil
        yieldResult = nil
        interpretation = nil
    }

    private func parseDouble(_ text: String) -> Double? {
        Double(text.replacingOccurrences(of: ",", with: "."))
    }
}
