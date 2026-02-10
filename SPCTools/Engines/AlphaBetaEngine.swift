import Foundation

enum AlphaBetaEngine {
    struct PowerResult {
        let alpha: Double       // Type I error (significance level)
        let beta: Double        // Type II error
        let power: Double       // 1 - beta
        let sampleSize: Int     // Required sample size
    }

    /// Calculate beta (Type II error) for a z-test
    /// - Parameters:
    ///   - alpha: significance level (e.g. 0.05)
    ///   - effectSize: (mu1 - mu0) / sigma
    ///   - n: sample size
    static func beta(alpha: Double, effectSize: Double, n: Int) -> Double {
        guard n > 0, effectSize > 0 else { return 1.0 }

        let zAlpha = SigmaLevelEngine.inverseNormalCDF(1 - alpha / 2)
        let sqrtN = Double(n).squareRoot()
        let zBeta = zAlpha - effectSize * sqrtN

        return SigmaLevelEngine.normalCDF(zBeta)
    }

    /// Calculate power = 1 - beta
    static func power(alpha: Double, effectSize: Double, n: Int) -> Double {
        1.0 - beta(alpha: alpha, effectSize: effectSize, n: n)
    }

    /// Calculate required sample size for desired power
    /// - Parameters:
    ///   - alpha: significance level
    ///   - desiredPower: target power (e.g. 0.80)
    ///   - effectSize: standardized effect size
    static func requiredSampleSize(alpha: Double, desiredPower: Double, effectSize: Double) -> Int {
        guard effectSize > 0 else { return 0 }

        let zAlpha = SigmaLevelEngine.inverseNormalCDF(1 - alpha / 2)
        let zBeta = SigmaLevelEngine.inverseNormalCDF(desiredPower)

        let n = ((zAlpha + zBeta) / effectSize) * ((zAlpha + zBeta) / effectSize)
        return Int(ceil(n))
    }

    /// Full power analysis
    static func analyze(alpha: Double, effectSize: Double, n: Int) -> PowerResult {
        let b = beta(alpha: alpha, effectSize: effectSize, n: n)
        return PowerResult(
            alpha: alpha,
            beta: b,
            power: 1.0 - b,
            sampleSize: n
        )
    }

    /// Interpretation of power
    static func interpretation(power: Double) -> String {
        if power >= 0.90 {
            return String(localized: "alphaBeta.interpretation.excellent")
        } else if power >= 0.80 {
            return String(localized: "alphaBeta.interpretation.adequate")
        } else if power >= 0.60 {
            return String(localized: "alphaBeta.interpretation.low")
        } else {
            return String(localized: "alphaBeta.interpretation.veryLow")
        }
    }
}
