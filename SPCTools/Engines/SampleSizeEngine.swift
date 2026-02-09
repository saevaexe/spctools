import Foundation

enum SampleSizeEngine {
    /// Sample size for proportion (infinite population)
    /// n = (Z^2 * p * (1-p)) / E^2
    static func sampleSizeProportion(confidenceLevel: Double, marginOfError: Double, proportion: Double = 0.5) -> Int {
        let z = zScore(for: confidenceLevel)
        guard marginOfError > 0 else { return 0 }
        let n = (z * z * proportion * (1 - proportion)) / (marginOfError * marginOfError)
        return Int(ceil(n))
    }

    /// Finite population correction
    /// n_adj = n / (1 + (n - 1) / N)
    static func adjustForPopulation(sampleSize: Int, population: Int) -> Int {
        guard population > 0 else { return sampleSize }
        let n = Double(sampleSize)
        let N = Double(population)
        let adjusted = n / (1.0 + (n - 1.0) / N)
        return Int(ceil(adjusted))
    }

    /// Sample size for mean estimation
    /// n = (Z * sigma / E)^2
    static func sampleSizeMean(confidenceLevel: Double, marginOfError: Double, stdDev: Double) -> Int {
        let z = zScore(for: confidenceLevel)
        guard marginOfError > 0 else { return 0 }
        let n = pow(z * stdDev / marginOfError, 2)
        return Int(ceil(n))
    }

    /// Z-score for common confidence levels
    static func zScore(for confidenceLevel: Double) -> Double {
        switch confidenceLevel {
        case 0.90: return 1.645
        case 0.95: return 1.960
        case 0.99: return 2.576
        default:
            // General case using inverse normal
            return SigmaLevelEngine.inverseNormalCDF((1.0 + confidenceLevel) / 2.0)
        }
    }

    /// Common confidence levels
    static let confidenceLevels: [(label: String, value: Double)] = [
        ("90%", 0.90),
        ("95%", 0.95),
        ("99%", 0.99)
    ]
}
