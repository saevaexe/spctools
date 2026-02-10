import Foundation

enum ParetoEngine {
    struct ParetoItem: Identifiable {
        let id = UUID()
        let category: String
        let count: Int
        let percentage: Double
        let cumulativePercentage: Double
    }

    /// Analyze categories and frequencies, return sorted Pareto items
    static func analyze(categories: [String], counts: [Int]) -> [ParetoItem] {
        guard categories.count == counts.count, !categories.isEmpty else { return [] }

        let total = counts.reduce(0, +)
        guard total > 0 else { return [] }

        let paired = zip(categories, counts).sorted { $0.1 > $1.1 }

        var items: [ParetoItem] = []
        var cumulative = 0.0

        for (cat, count) in paired {
            let pct = Double(count) / Double(total) * 100
            cumulative += pct
            items.append(ParetoItem(
                category: cat,
                count: count,
                percentage: pct,
                cumulativePercentage: cumulative
            ))
        }

        return items
    }

    /// Find the vital few (categories contributing to ~80%)
    static func vitalFew(_ items: [ParetoItem]) -> [ParetoItem] {
        var result: [ParetoItem] = []
        for item in items {
            result.append(item)
            if item.cumulativePercentage >= 80 { break }
        }
        return result
    }
}
