import Foundation

enum IshikawaEngine {
    struct IshikawaDiagram {
        let problem: String
        var categories: [Category]
    }

    struct Category: Identifiable {
        let id = UUID()
        let name: String
        var causes: [String]
    }

    /// Standard 6M categories
    static let standard6M: [String] = [
        "Man", "Machine", "Method", "Material", "Measurement", "Environment"
    ]

    /// Localized 6M categories
    static func localized6M() -> [String] {
        [
            String(localized: "ishikawa.man"),
            String(localized: "ishikawa.machine"),
            String(localized: "ishikawa.method"),
            String(localized: "ishikawa.material"),
            String(localized: "ishikawa.measurement"),
            String(localized: "ishikawa.environment"),
        ]
    }

    /// Create empty diagram with 6M categories
    static func createDiagram(problem: String) -> IshikawaDiagram {
        let names = localized6M()
        let categories = names.map { Category(name: $0, causes: []) }
        return IshikawaDiagram(problem: problem, categories: categories)
    }

    /// Count total causes across all categories
    static func totalCauses(_ diagram: IshikawaDiagram) -> Int {
        diagram.categories.reduce(0) { $0 + $1.causes.count }
    }
}
