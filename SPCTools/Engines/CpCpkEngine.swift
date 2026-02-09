import Foundation

enum CpCpkEngine {
    /// Cp = (USL - LSL) / (6 * sigma)
    static func cp(usl: Double, lsl: Double, sigma: Double) -> Double {
        guard sigma > 0 else { return 0 }
        return (usl - lsl) / (6.0 * sigma)
    }

    /// Cpu = (USL - mean) / (3 * sigma)
    static func cpu(usl: Double, mean: Double, sigma: Double) -> Double {
        guard sigma > 0 else { return 0 }
        return (usl - mean) / (3.0 * sigma)
    }

    /// Cpl = (mean - LSL) / (3 * sigma)
    static func cpl(mean: Double, lsl: Double, sigma: Double) -> Double {
        guard sigma > 0 else { return 0 }
        return (mean - lsl) / (3.0 * sigma)
    }

    /// Cpk = min(Cpu, Cpl)
    static func cpk(usl: Double, lsl: Double, mean: Double, sigma: Double) -> Double {
        return min(cpu(usl: usl, mean: mean, sigma: sigma),
                   cpl(mean: mean, lsl: lsl, sigma: sigma))
    }

    /// Calculate sigma from data: standard deviation
    static func standardDeviation(_ data: [Double]) -> Double {
        guard data.count > 1 else { return 0 }
        let mean = data.reduce(0, +) / Double(data.count)
        let variance = data.reduce(0) { $0 + ($1 - mean) * ($1 - mean) } / Double(data.count - 1)
        return variance.squareRoot()
    }

    /// Interpretation of Cpk value
    static func interpretation(_ cpk: Double) -> String {
        if cpk >= 2.0 {
            return String(localized: "cpCpk.interpretation.excellent")
        } else if cpk >= 1.67 {
            return String(localized: "cpCpk.interpretation.good")
        } else if cpk >= 1.33 {
            return String(localized: "cpCpk.interpretation.capable")
        } else if cpk >= 1.0 {
            return String(localized: "cpCpk.interpretation.marginal")
        } else {
            return String(localized: "cpCpk.interpretation.incapable")
        }
    }
}
