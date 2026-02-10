import Foundation
import SwiftData

@Observable
final class AQLViewModel {
    var lotSizeText = ""
    var selectedLevel = "II"
    var selectedAQL: Double = 1.0

    var plan: AQLEngine.SamplingPlan?

    var isValid: Bool {
        guard let lot = Int(lotSizeText) else { return false }
        return lot >= 2
    }

    func calculate() {
        guard let lot = Int(lotSizeText) else { return }
        plan = AQLEngine.samplingPlan(lotSize: lot, inspectionLevel: selectedLevel, aql: selectedAQL)
    }

    func saveToHistory(modelContext: ModelContext) {
        guard let p = plan else { return }
        let record = CalculationRecord(
            category: .aqlTable,
            title: String(localized: "category.aqlTable"),
            inputSummary: "Lot: \(lotSizeText), Level: \(selectedLevel), AQL: \(selectedAQL)",
            resultSummary: "n=\(p.sampleSize), Ac=\(p.acceptNumber), Re=\(p.rejectNumber)"
        )
        modelContext.insert(record)
    }

    func reset() {
        lotSizeText = ""; selectedLevel = "II"; selectedAQL = 1.0; plan = nil
    }
}
