import Foundation

enum PpPpkEngine {
    /// Pp = (USL - LSL) / (6 * sigmaOverall)
    static func pp(usl: Double, lsl: Double, sigmaOverall: Double) -> Double {
        guard sigmaOverall > 0 else { return 0 }
        return (usl - lsl) / (6.0 * sigmaOverall)
    }

    /// Ppu = (USL - mean) / (3 * sigmaOverall)
    static func ppu(usl: Double, mean: Double, sigmaOverall: Double) -> Double {
        guard sigmaOverall > 0 else { return 0 }
        return (usl - mean) / (3.0 * sigmaOverall)
    }

    /// Ppl = (mean - LSL) / (3 * sigmaOverall)
    static func ppl(mean: Double, lsl: Double, sigmaOverall: Double) -> Double {
        guard sigmaOverall > 0 else { return 0 }
        return (mean - lsl) / (3.0 * sigmaOverall)
    }

    /// Ppk = min(Ppu, Ppl)
    static func ppk(usl: Double, lsl: Double, mean: Double, sigmaOverall: Double) -> Double {
        return min(ppu(usl: usl, mean: mean, sigmaOverall: sigmaOverall),
                   ppl(mean: mean, lsl: lsl, sigmaOverall: sigmaOverall))
    }

    /// Overall standard deviation (uses N, not N-1)
    static func overallSigma(_ data: [Double]) -> Double {
        guard data.count > 1 else { return 0 }
        let mean = data.reduce(0, +) / Double(data.count)
        let variance = data.reduce(0) { $0 + ($1 - mean) * ($1 - mean) } / Double(data.count)
        return variance.squareRoot()
    }

    static func interpretation(_ ppk: Double) -> String {
        if ppk >= 2.0 {
            return String(localized: "ppPpk.interpretation.excellent")
        } else if ppk >= 1.67 {
            return String(localized: "ppPpk.interpretation.good")
        } else if ppk >= 1.33 {
            return String(localized: "ppPpk.interpretation.capable")
        } else if ppk >= 1.0 {
            return String(localized: "ppPpk.interpretation.marginal")
        } else {
            return String(localized: "ppPpk.interpretation.incapable")
        }
    }
}
