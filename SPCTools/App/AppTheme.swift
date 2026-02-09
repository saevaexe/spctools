import SwiftUI

enum AppTheme {
    enum Spacing {
        static let small: CGFloat = 4
        static let medium: CGFloat = 8
        static let regular: CGFloat = 12
        static let large: CGFloat = 16
        static let extraLarge: CGFloat = 24
    }

    enum CornerRadius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
    }

    enum CategoryColor {
        static let cpCpk = Color.blue
        static let oee = Color.orange
        static let sigmaLevel = Color.purple
        static let sampleSize = Color.green
        static let formulaReference = Color.mint
        static let ppPpk = Color.teal
        static let controlChart = Color.red
        static let gageRR = Color.cyan
        static let aqlTable = Color.indigo
        static let pareto = Color.brown
        static let histogram = Color.pink
        static let fmea = Color(.systemOrange)
        static let ishikawa = Color.gray
        static let alphaBeta = Color(.systemTeal)
        static let hypothesisTest = Color(.systemPurple)
    }
}
