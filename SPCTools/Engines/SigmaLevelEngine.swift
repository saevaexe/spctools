import Foundation

enum SigmaLevelEngine {
    /// DPMO = (Defects / (Units * Opportunities)) * 1,000,000
    static func dpmo(defects: Double, units: Double, opportunities: Double) -> Double {
        guard units > 0, opportunities > 0 else { return 0 }
        return (defects / (units * opportunities)) * 1_000_000
    }

    /// Yield = (1 - DPMO / 1,000,000) * 100
    static func yieldFromDPMO(_ dpmo: Double) -> Double {
        return (1.0 - dpmo / 1_000_000) * 100.0
    }

    /// Sigma Level from DPMO (with 1.5σ shift)
    /// Using lookup table for standard conversion
    static func sigmaFromDPMO(_ dpmo: Double) -> Double {
        guard dpmo > 0, dpmo < 1_000_000 else {
            return dpmo <= 0 ? 6.0 : 0.0
        }
        // Z = NORMSINV(1 - DPMO/1000000) + 1.5
        // Approximation using rational function
        let p = 1.0 - dpmo / 1_000_000
        let z = inverseNormalCDF(p)
        return z + AppConstants.SPC.sigmaShift
    }

    /// DPMO from Sigma Level (with 1.5σ shift)
    static func dpmoFromSigma(_ sigma: Double) -> Double {
        let z = sigma - AppConstants.SPC.sigmaShift
        let p = normalCDF(z)
        return (1.0 - p) * 1_000_000
    }

    /// Standard Normal CDF approximation (Abramowitz & Stegun)
    static func normalCDF(_ x: Double) -> Double {
        if x < -8 { return 0 }
        if x > 8 { return 1 }

        let a1 = 0.254829592
        let a2 = -0.284496736
        let a3 = 1.421413741
        let a4 = -1.453152027
        let a5 = 1.061405429
        let p = 0.3275911

        let sign: Double = x < 0 ? -1 : 1
        let absX = abs(x)
        let t = 1.0 / (1.0 + p * absX)
        let y = 1.0 - (((((a5 * t + a4) * t) + a3) * t + a2) * t + a1) * t * exp(-absX * absX / 2.0)

        return 0.5 * (1.0 + sign * y)
    }

    /// Inverse Normal CDF approximation (Beasley-Springer-Moro)
    static func inverseNormalCDF(_ p: Double) -> Double {
        guard p > 0, p < 1 else { return 0 }

        let a = [-3.969683028665376e+01, 2.209460984245205e+02,
                  -2.759285104469687e+02, 1.383577518672690e+02,
                  -3.066479806614716e+01, 2.506628277459239e+00]
        let b = [-5.447609879822406e+01, 1.615858368580409e+02,
                  -1.556989798598866e+02, 6.680131188771972e+01,
                  -1.328068155288572e+01]
        let c = [-7.784894002430293e-03, -3.223964580411365e-01,
                  -2.400758277161838e+00, -2.549732539343734e+00,
                   4.374664141464968e+00, 2.938163982698783e+00]
        let d = [ 7.784695709041462e-03, 3.224671290700398e-01,
                   2.445134137142996e+00, 3.754408661907416e+00]

        let pLow = 0.02425
        let pHigh = 1.0 - pLow

        var q: Double
        var r: Double

        if p < pLow {
            q = sqrt(-2.0 * log(p))
            return (((((c[0]*q+c[1])*q+c[2])*q+c[3])*q+c[4])*q+c[5]) /
                    ((((d[0]*q+d[1])*q+d[2])*q+d[3])*q+1.0)
        } else if p <= pHigh {
            q = p - 0.5
            r = q * q
            return (((((a[0]*r+a[1])*r+a[2])*r+a[3])*r+a[4])*r+a[5]) * q /
                    (((((b[0]*r+b[1])*r+b[2])*r+b[3])*r+b[4])*r+1.0)
        } else {
            q = sqrt(-2.0 * log(1.0 - p))
            return -(((((c[0]*q+c[1])*q+c[2])*q+c[3])*q+c[4])*q+c[5]) /
                     ((((d[0]*q+d[1])*q+d[2])*q+d[3])*q+1.0)
        }
    }

    /// Interpretation of sigma level
    static func interpretation(_ sigma: Double) -> String {
        if sigma >= 6.0 {
            return String(localized: "sigma.interpretation.sixSigma")
        } else if sigma >= 5.0 {
            return String(localized: "sigma.interpretation.excellent")
        } else if sigma >= 4.0 {
            return String(localized: "sigma.interpretation.good")
        } else if sigma >= 3.0 {
            return String(localized: "sigma.interpretation.average")
        } else {
            return String(localized: "sigma.interpretation.poor")
        }
    }
}
