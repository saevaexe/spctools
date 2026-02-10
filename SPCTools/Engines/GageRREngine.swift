import Foundation

enum GageRREngine {
    struct GageRRResult {
        let repeatability: Double   // EV (Equipment Variation)
        let reproducibility: Double // AV (Appraiser Variation)
        let gageRR: Double          // GRR
        let partVariation: Double   // PV
        let totalVariation: Double  // TV
        let percentGRR: Double      // %GRR
        let percentPV: Double       // %PV
        let ndc: Int                // Number of Distinct Categories
    }

    /// Crossed Gage R&R (Average & Range Method)
    /// - Parameters:
    ///   - measurements: [operator][part][trial] = measured value
    ///   - tolerance: optional tolerance for %Tolerance calculation
    static func calculate(measurements: [[[Double]]], tolerance: Double? = nil) -> GageRRResult? {
        guard !measurements.isEmpty else { return nil }
        let numOperators = measurements.count
        let numParts = measurements[0].count
        let numTrials = measurements[0][0].count

        guard numOperators >= 2, numParts >= 2, numTrials >= 2 else { return nil }

        // Calculate ranges per operator per part
        var ranges: [[Double]] = []
        for op in 0..<numOperators {
            var opRanges: [Double] = []
            for part in 0..<numParts {
                let trials = measurements[op][part]
                let range = (trials.max() ?? 0) - (trials.min() ?? 0)
                opRanges.append(range)
            }
            ranges.append(opRanges)
        }

        let rBar = ranges.flatMap { $0 }.reduce(0, +) / Double(numOperators * numParts)
        let d2 = AppConstants.SPC.d2Value(n: numTrials)

        // EV (Repeatability / Equipment Variation)
        let ev = rBar / d2

        // Operator averages
        var operatorMeans: [Double] = []
        for op in 0..<numOperators {
            let allMeasurements = measurements[op].flatMap { $0 }
            operatorMeans.append(allMeasurements.reduce(0, +) / Double(allMeasurements.count))
        }
        let xDiff = (operatorMeans.max() ?? 0) - (operatorMeans.min() ?? 0)
        let d2Star = AppConstants.SPC.d2Value(n: numOperators)

        // AV (Reproducibility / Appraiser Variation)
        let avSquared = (xDiff / d2Star) * (xDiff / d2Star) - (ev * ev) / Double(numParts * numTrials)
        let av = avSquared > 0 ? avSquared.squareRoot() : 0

        // GRR
        let grr = (ev * ev + av * av).squareRoot()

        // Part Variation (PV)
        var partMeans: [Double] = []
        for part in 0..<numParts {
            var sum = 0.0
            var count = 0
            for op in 0..<numOperators {
                for trial in measurements[op][part] {
                    sum += trial
                    count += 1
                }
            }
            partMeans.append(sum / Double(count))
        }
        let rpPart = (partMeans.max() ?? 0) - (partMeans.min() ?? 0)
        let d2Part = AppConstants.SPC.d2Value(n: numParts)
        let pv = rpPart / d2Part

        // Total Variation (TV)
        let tv = (grr * grr + pv * pv).squareRoot()

        // Percentages
        let percentGRR = tv > 0 ? (grr / tv) * 100 : 0
        let percentPV = tv > 0 ? (pv / tv) * 100 : 0

        // NDC (Number of Distinct Categories)
        let ndc = pv > 0 ? Int((1.41 * pv / grr).rounded(.down)) : 0

        return GageRRResult(
            repeatability: ev,
            reproducibility: av,
            gageRR: grr,
            partVariation: pv,
            totalVariation: tv,
            percentGRR: percentGRR,
            percentPV: percentPV,
            ndc: max(ndc, 0)
        )
    }

    static func interpretation(percentGRR: Double) -> String {
        if percentGRR < 10 {
            return String(localized: "gageRR.interpretation.acceptable")
        } else if percentGRR < 30 {
            return String(localized: "gageRR.interpretation.marginal")
        } else {
            return String(localized: "gageRR.interpretation.unacceptable")
        }
    }
}
