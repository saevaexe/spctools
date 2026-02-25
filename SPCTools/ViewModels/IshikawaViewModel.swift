import Foundation
import SwiftData

@Observable
final class IshikawaViewModel {
    var problemText = ""
    var diagram: IshikawaEngine.IshikawaDiagram?
    var newCauseText = ""
    var selectedCategoryIndex = 0

    var isValid: Bool {
        !problemText.trimmingCharacters(in: .whitespaces).isEmpty
    }

    func createDiagram() {
        diagram = IshikawaEngine.createDiagram(problem: problemText.trimmingCharacters(in: .whitespaces))
    }

    func addCause() {
        guard var d = diagram, !newCauseText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        guard selectedCategoryIndex < d.categories.count else { return }
        d.categories[selectedCategoryIndex].causes.append(newCauseText.trimmingCharacters(in: .whitespaces))
        diagram = d
        newCauseText = ""
    }

    func removeCause(categoryIndex: Int, causeIndex: Int) {
        guard var d = diagram else { return }
        guard categoryIndex < d.categories.count, causeIndex < d.categories[categoryIndex].causes.count else { return }
        d.categories[categoryIndex].causes.remove(at: causeIndex)
        diagram = d
    }

    func saveToHistory(modelContext: ModelContext) {
        guard let d = diagram else { return }
        let total = IshikawaEngine.totalCauses(d)
        let record = CalculationRecord(
            category: .ishikawa,
            title: String(localized: "category.ishikawa"),
            inputSummary: d.problem,
            resultSummary: String(localized: "ishikawa.history.result \(total)")
        )
        modelContext.insert(record)
    }

    func reset() {
        problemText = ""; diagram = nil; newCauseText = ""; selectedCategoryIndex = 0
    }
}
