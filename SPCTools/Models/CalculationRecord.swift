import Foundation
import SwiftData

@Model
final class CalculationRecord {
    var id: UUID
    var category: String
    var title: String
    var inputSummary: String
    var resultSummary: String
    var timestamp: Date
    var isFavorite: Bool

    init(
        category: CalculationCategory,
        title: String,
        inputSummary: String,
        resultSummary: String
    ) {
        self.id = UUID()
        self.category = category.rawValue
        self.title = title
        self.inputSummary = inputSummary
        self.resultSummary = resultSummary
        self.timestamp = Date()
        self.isFavorite = false
    }

    var calculationCategory: CalculationCategory? {
        CalculationCategory(rawValue: category)
    }
}
