import Foundation
import SwiftData

@Observable
final class ParetoViewModel {
    var categoriesText = ""
    var countsText = ""

    var items: [ParetoEngine.ParetoItem] = []
    var vitalFewItems: [ParetoEngine.ParetoItem] = []

    var isValid: Bool {
        let cats = parseCategories(categoriesText)
        let cnts = parseCounts(countsText)
        return cats.count >= 2 && cats.count == cnts.count
    }

    func calculate() {
        let cats = parseCategories(categoriesText)
        let cnts = parseCounts(countsText)
        items = ParetoEngine.analyze(categories: cats, counts: cnts)
        vitalFewItems = ParetoEngine.vitalFew(items)
    }

    func saveToHistory(modelContext: ModelContext) {
        guard !items.isEmpty else { return }
        let record = CalculationRecord(
            category: .pareto,
            title: String(localized: "category.pareto"),
            inputSummary: "\(items.count) categories",
            resultSummary: "Vital few: \(vitalFewItems.count)"
        )
        modelContext.insert(record)
    }

    func reset() {
        categoriesText = ""; countsText = ""
        items = []; vitalFewItems = []
    }

    private func parseCategories(_ text: String) -> [String] {
        text.components(separatedBy: CharacterSet(charactersIn: ",;\n"))
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
    }

    private func parseCounts(_ text: String) -> [Int] {
        text.components(separatedBy: CharacterSet(charactersIn: ",;\n "))
            .compactMap { Int($0.trimmingCharacters(in: .whitespaces)) }
    }
}
