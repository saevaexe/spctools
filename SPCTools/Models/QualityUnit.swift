import Foundation

enum QualityUnit: String, CaseIterable, Identifiable {
    case ppm = "ppm"
    case dpmo = "DPMO"
    case percent = "%"
    case sigma = "σ"
    case dpu = "DPU"
    case yield_ = "Yield %"

    var id: String { rawValue }
}
