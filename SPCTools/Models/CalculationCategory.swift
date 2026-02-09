import SwiftUI

enum CalculationCategory: String, Codable, CaseIterable, Identifiable, Hashable {
    case cpCpk
    case oee
    case sigmaLevel
    case sampleSize
    case formulaReference
    case ppPpk
    case controlChart
    case gageRR
    case aqlTable
    case pareto
    case histogram
    case fmea
    case ishikawa
    case alphaBeta
    case hypothesisTest

    var id: String { rawValue }

    var isPremium: Bool {
        switch self {
        case .cpCpk, .oee, .sigmaLevel, .sampleSize, .formulaReference:
            return false
        default:
            return true
        }
    }

    var title: String {
        switch self {
        case .cpCpk:            return String(localized: "category.cpCpk")
        case .oee:              return String(localized: "category.oee")
        case .sigmaLevel:       return String(localized: "category.sigmaLevel")
        case .sampleSize:       return String(localized: "category.sampleSize")
        case .formulaReference: return String(localized: "category.formulaReference")
        case .ppPpk:            return String(localized: "category.ppPpk")
        case .controlChart:     return String(localized: "category.controlChart")
        case .gageRR:           return String(localized: "category.gageRR")
        case .aqlTable:         return String(localized: "category.aqlTable")
        case .pareto:           return String(localized: "category.pareto")
        case .histogram:        return String(localized: "category.histogram")
        case .fmea:             return String(localized: "category.fmea")
        case .ishikawa:         return String(localized: "category.ishikawa")
        case .alphaBeta:        return String(localized: "category.alphaBeta")
        case .hypothesisTest:   return String(localized: "category.hypothesisTest")
        }
    }

    var subtitle: String {
        switch self {
        case .cpCpk:            return String(localized: "category.cpCpk.subtitle")
        case .oee:              return String(localized: "category.oee.subtitle")
        case .sigmaLevel:       return String(localized: "category.sigmaLevel.subtitle")
        case .sampleSize:       return String(localized: "category.sampleSize.subtitle")
        case .formulaReference: return String(localized: "category.formulaReference.subtitle")
        case .ppPpk:            return String(localized: "category.ppPpk.subtitle")
        case .controlChart:     return String(localized: "category.controlChart.subtitle")
        case .gageRR:           return String(localized: "category.gageRR.subtitle")
        case .aqlTable:         return String(localized: "category.aqlTable.subtitle")
        case .pareto:           return String(localized: "category.pareto.subtitle")
        case .histogram:        return String(localized: "category.histogram.subtitle")
        case .fmea:             return String(localized: "category.fmea.subtitle")
        case .ishikawa:         return String(localized: "category.ishikawa.subtitle")
        case .alphaBeta:        return String(localized: "category.alphaBeta.subtitle")
        case .hypothesisTest:   return String(localized: "category.hypothesisTest.subtitle")
        }
    }

    var iconName: String {
        switch self {
        case .cpCpk:            return "chart.bar.doc.horizontal"
        case .oee:              return "gauge.with.dots.needle.67percent"
        case .sigmaLevel:       return "sigma"
        case .sampleSize:       return "number.circle"
        case .formulaReference: return "book.fill"
        case .ppPpk:            return "chart.bar.doc.horizontal.fill"
        case .controlChart:     return "chart.xyaxis.line"
        case .gageRR:           return "ruler"
        case .aqlTable:         return "tablecells"
        case .pareto:           return "chart.bar.fill"
        case .histogram:        return "chart.bar"
        case .fmea:             return "exclamationmark.triangle.fill"
        case .ishikawa:         return "arrow.triangle.branch"
        case .alphaBeta:        return "percent"
        case .hypothesisTest:   return "function"
        }
    }

    var color: Color {
        switch self {
        case .cpCpk:            return AppTheme.CategoryColor.cpCpk
        case .oee:              return AppTheme.CategoryColor.oee
        case .sigmaLevel:       return AppTheme.CategoryColor.sigmaLevel
        case .sampleSize:       return AppTheme.CategoryColor.sampleSize
        case .formulaReference: return AppTheme.CategoryColor.formulaReference
        case .ppPpk:            return AppTheme.CategoryColor.ppPpk
        case .controlChart:     return AppTheme.CategoryColor.controlChart
        case .gageRR:           return AppTheme.CategoryColor.gageRR
        case .aqlTable:         return AppTheme.CategoryColor.aqlTable
        case .pareto:           return AppTheme.CategoryColor.pareto
        case .histogram:        return AppTheme.CategoryColor.histogram
        case .fmea:             return AppTheme.CategoryColor.fmea
        case .ishikawa:         return AppTheme.CategoryColor.ishikawa
        case .alphaBeta:        return AppTheme.CategoryColor.alphaBeta
        case .hypothesisTest:   return AppTheme.CategoryColor.hypothesisTest
        }
    }
}
