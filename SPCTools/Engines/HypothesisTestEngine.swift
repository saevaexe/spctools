import Foundation

enum HypothesisTestEngine {
    enum TestType: String, CaseIterable {
        case oneSampleZ = "1-Sample Z"
        case oneSampleT = "1-Sample t"
        case twoSampleT = "2-Sample t"
    }

    enum Alternative: String, CaseIterable {
        case twoSided = "≠"
        case less = "<"
        case greater = ">"
    }

    struct TestResult {
        let testStatistic: Double
        let pValue: Double
        let reject: Bool
        let conclusion: String
    }

    // MARK: - One-Sample Z Test

    static func oneSampleZ(sampleMean: Double, mu0: Double, sigma: Double, n: Int, alpha: Double, alternative: Alternative) -> TestResult {
        guard n > 0, sigma > 0 else {
            return TestResult(testStatistic: 0, pValue: 1, reject: false, conclusion: "")
        }

        let z = (sampleMean - mu0) / (sigma / Double(n).squareRoot())
        let pValue: Double

        switch alternative {
        case .twoSided:
            pValue = 2 * (1 - SigmaLevelEngine.normalCDF(abs(z)))
        case .less:
            pValue = SigmaLevelEngine.normalCDF(z)
        case .greater:
            pValue = 1 - SigmaLevelEngine.normalCDF(z)
        }

        let reject = pValue < alpha
        let conclusion = reject
            ? String(localized: "hypothesis.reject")
            : String(localized: "hypothesis.failToReject")

        return TestResult(testStatistic: z, pValue: pValue, reject: reject, conclusion: conclusion)
    }

    // MARK: - One-Sample T Test

    static func oneSampleT(sampleMean: Double, mu0: Double, sampleStdDev: Double, n: Int, alpha: Double, alternative: Alternative) -> TestResult {
        guard n > 1, sampleStdDev > 0 else {
            return TestResult(testStatistic: 0, pValue: 1, reject: false, conclusion: "")
        }

        let t = (sampleMean - mu0) / (sampleStdDev / Double(n).squareRoot())
        let df = n - 1

        // Approximate t-distribution p-value using normal approximation for large df
        let pValue: Double
        if df >= 30 {
            switch alternative {
            case .twoSided:
                pValue = 2 * (1 - SigmaLevelEngine.normalCDF(abs(t)))
            case .less:
                pValue = SigmaLevelEngine.normalCDF(t)
            case .greater:
                pValue = 1 - SigmaLevelEngine.normalCDF(t)
            }
        } else {
            // Better approximation for small df using Welch's formula
            let x = Double(df) / (Double(df) + t * t)
            let approxP = incompleteBeta(a: Double(df) / 2, b: 0.5, x: x)

            switch alternative {
            case .twoSided:
                pValue = approxP
            case .less:
                pValue = t < 0 ? approxP / 2 : 1 - approxP / 2
            case .greater:
                pValue = t > 0 ? approxP / 2 : 1 - approxP / 2
            }
        }

        let reject = pValue < alpha
        let conclusion = reject
            ? String(localized: "hypothesis.reject")
            : String(localized: "hypothesis.failToReject")

        return TestResult(testStatistic: t, pValue: pValue, reject: reject, conclusion: conclusion)
    }

    // MARK: - Two-Sample T Test (assuming equal variances)

    static func twoSampleT(mean1: Double, mean2: Double, s1: Double, s2: Double, n1: Int, n2: Int, alpha: Double, alternative: Alternative) -> TestResult {
        guard n1 > 1, n2 > 1, s1 > 0 || s2 > 0 else {
            return TestResult(testStatistic: 0, pValue: 1, reject: false, conclusion: "")
        }

        let df = n1 + n2 - 2
        let sp2 = (Double(n1 - 1) * s1 * s1 + Double(n2 - 1) * s2 * s2) / Double(df)
        let se = (sp2 * (1.0 / Double(n1) + 1.0 / Double(n2))).squareRoot()

        guard se > 0 else {
            return TestResult(testStatistic: 0, pValue: 1, reject: false, conclusion: "")
        }

        let t = (mean1 - mean2) / se

        let pValue: Double
        if df >= 30 {
            switch alternative {
            case .twoSided:
                pValue = 2 * (1 - SigmaLevelEngine.normalCDF(abs(t)))
            case .less:
                pValue = SigmaLevelEngine.normalCDF(t)
            case .greater:
                pValue = 1 - SigmaLevelEngine.normalCDF(t)
            }
        } else {
            let x = Double(df) / (Double(df) + t * t)
            let approxP = incompleteBeta(a: Double(df) / 2, b: 0.5, x: x)

            switch alternative {
            case .twoSided:
                pValue = approxP
            case .less:
                pValue = t < 0 ? approxP / 2 : 1 - approxP / 2
            case .greater:
                pValue = t > 0 ? approxP / 2 : 1 - approxP / 2
            }
        }

        let reject = pValue < alpha
        let conclusion = reject
            ? String(localized: "hypothesis.reject")
            : String(localized: "hypothesis.failToReject")

        return TestResult(testStatistic: t, pValue: pValue, reject: reject, conclusion: conclusion)
    }

    // MARK: - Incomplete Beta (regularized) approximation

    /// Regularized incomplete beta function using continued fraction
    static func incompleteBeta(a: Double, b: Double, x: Double) -> Double {
        guard x > 0, x < 1 else { return x <= 0 ? 0 : 1 }

        let lnBeta = lgamma(a) + lgamma(b) - lgamma(a + b)
        let prefix = exp(a * log(x) + b * log(1 - x) - lnBeta)

        // Lentz's continued fraction
        var c = 1.0
        var d = 1.0 - (a + b) * x / (a + 1)
        if abs(d) < 1e-30 { d = 1e-30 }
        d = 1.0 / d
        var result = d

        for m in 1...200 {
            let mDouble = Double(m)

            // Even step
            var numerator = mDouble * (b - mDouble) * x / ((a + 2 * mDouble - 1) * (a + 2 * mDouble))
            d = 1.0 + numerator * d
            if abs(d) < 1e-30 { d = 1e-30 }
            c = 1.0 + numerator / c
            if abs(c) < 1e-30 { c = 1e-30 }
            d = 1.0 / d
            result *= d * c

            // Odd step
            numerator = -(a + mDouble) * (a + b + mDouble) * x / ((a + 2 * mDouble) * (a + 2 * mDouble + 1))
            d = 1.0 + numerator * d
            if abs(d) < 1e-30 { d = 1e-30 }
            c = 1.0 + numerator / c
            if abs(c) < 1e-30 { c = 1e-30 }
            d = 1.0 / d
            let delta = d * c
            result *= delta

            if abs(delta - 1.0) < 1e-10 { break }
        }

        return prefix * result / a
    }
}
