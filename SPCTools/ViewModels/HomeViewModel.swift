import Foundation

@Observable
final class HomeViewModel {
    let categories = CalculationCategory.allCases
    var searchText: String = ""

    var filteredCategories: [CalculationCategory] {
        if searchText.isEmpty { return Array(categories) }
        return categories.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.subtitle.localizedCaseInsensitiveContains(searchText)
        }
    }
}
