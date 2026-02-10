import Foundation
import SwiftData

@Observable
final class FMEAViewModel {
    var failureModeText = ""
    var severity = 5
    var occurrence = 5
    var detection = 5

    var items: [FMEAEngine.FMEAItem] = []

    var isValid: Bool {
        !failureModeText.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var currentRPN: Int {
        FMEAEngine.rpn(severity: severity, occurrence: occurrence, detection: detection)
    }

    func addItem() {
        let item = FMEAEngine.createItem(
            failureMode: failureModeText.trimmingCharacters(in: .whitespaces),
            severity: severity, occurrence: occurrence, detection: detection
        )
        items.append(item)
        items = FMEAEngine.sortByRPN(items)
        failureModeText = ""
        severity = 5; occurrence = 5; detection = 5
    }

    func removeItem(_ item: FMEAEngine.FMEAItem) {
        items.removeAll { $0.id == item.id }
    }

    func saveToHistory(modelContext: ModelContext) {
        guard !items.isEmpty else { return }
        let maxRPN = items.first?.rpn ?? 0
        let record = CalculationRecord(
            category: .fmea,
            title: String(localized: "category.fmea"),
            inputSummary: "\(items.count) failure modes",
            resultSummary: "Max RPN: \(maxRPN)"
        )
        modelContext.insert(record)
    }

    func reset() {
        failureModeText = ""; severity = 5; occurrence = 5; detection = 5
        items = []
    }
}
