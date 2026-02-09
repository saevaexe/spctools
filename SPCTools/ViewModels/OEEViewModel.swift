import Foundation
import SwiftData

@Observable
final class OEEViewModel {
    var plannedTimeText = ""
    var downtimeText = ""
    var idealCycleTimeText = ""
    var totalCountText = ""
    var defectCountText = ""

    var availabilityResult: Double?
    var performanceResult: Double?
    var qualityResult: Double?
    var oeeResult: Double?
    var interpretation: String?

    var isValid: Bool {
        guard let planned = parseDouble(plannedTimeText),
              let downtime = parseDouble(downtimeText),
              let idealCycle = parseDouble(idealCycleTimeText),
              let total = parseDouble(totalCountText),
              let defects = parseDouble(defectCountText) else { return false }
        return planned > 0 && downtime >= 0 && downtime < planned &&
               idealCycle > 0 && total > 0 && defects >= 0 && defects <= total
    }

    func calculate() {
        guard let planned = parseDouble(plannedTimeText),
              let downtime = parseDouble(downtimeText),
              let idealCycle = parseDouble(idealCycleTimeText),
              let total = parseDouble(totalCountText),
              let defects = parseDouble(defectCountText) else { return }

        let runTime = planned - downtime
        availabilityResult = OEEEngine.availability(plannedTime: planned, downtime: downtime)
        performanceResult = OEEEngine.performance(idealCycleTime: idealCycle, totalCount: total, runTime: runTime)
        qualityResult = OEEEngine.quality(totalCount: total, defectCount: defects)
        oeeResult = OEEEngine.oee(
            availability: availabilityResult ?? 0,
            performance: performanceResult ?? 0,
            quality: qualityResult ?? 0
        )
        interpretation = OEEEngine.interpretation(oeeResult ?? 0)
    }

    func saveToHistory(modelContext: ModelContext) {
        guard let oee = oeeResult else { return }
        let record = CalculationRecord(
            category: .oee,
            title: String(localized: "category.oee"),
            inputSummary: String(localized: "oee.history.input \(plannedTimeText) \(downtimeText) \(totalCountText)"),
            resultSummary: "OEE: \(oee.formatted2)%"
        )
        modelContext.insert(record)
    }

    func reset() {
        plannedTimeText = ""
        downtimeText = ""
        idealCycleTimeText = ""
        totalCountText = ""
        defectCountText = ""
        availabilityResult = nil
        performanceResult = nil
        qualityResult = nil
        oeeResult = nil
        interpretation = nil
    }

    private func parseDouble(_ text: String) -> Double? {
        Double(text.replacingOccurrences(of: ",", with: "."))
    }
}
