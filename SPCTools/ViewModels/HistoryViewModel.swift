import Foundation
import SwiftData

enum HistoryFilter: String, CaseIterable, Hashable {
    case all
    case favorites

    var title: String {
        switch self {
        case .all:       return String(localized: "history.filter.all")
        case .favorites: return String(localized: "history.filter.favorites")
        }
    }
}

@Observable
final class HistoryViewModel {
    var filter: HistoryFilter = .all

    func filteredRecords(_ records: [CalculationRecord]) -> [CalculationRecord] {
        switch filter {
        case .all:       return records
        case .favorites: return records.filter { $0.isFavorite }
        }
    }

    func toggleFavorite(_ record: CalculationRecord) {
        record.isFavorite.toggle()
    }

    func deleteRecord(_ record: CalculationRecord, modelContext: ModelContext) {
        modelContext.delete(record)
    }

    func deleteAll(modelContext: ModelContext) {
        do {
            try modelContext.delete(model: CalculationRecord.self)
        } catch {
            // silently handle
        }
    }
}
