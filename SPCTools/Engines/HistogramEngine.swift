import Foundation

enum HistogramEngine {
    struct HistogramBin: Identifiable {
        let id = UUID()
        let lowerBound: Double
        let upperBound: Double
        let frequency: Int
        let relativeFrequency: Double

        var midpoint: Double { (lowerBound + upperBound) / 2 }
        var label: String { "\(lowerBound.formatted2)-\(upperBound.formatted2)" }
    }

    struct HistogramResult {
        let bins: [HistogramBin]
        let mean: Double
        let standardDeviation: Double
        let min: Double
        let max: Double
        let count: Int
    }

    /// Generate histogram bins using Sturges' rule
    static func analyze(data: [Double], binCount: Int? = nil) -> HistogramResult? {
        guard data.count >= 2 else { return nil }

        let sorted = data.sorted()
        let minVal = sorted.first!
        let maxVal = sorted.last!
        guard maxVal > minVal else { return nil }

        let fallback = max(sturgesBinCount(n: data.count), 3)
        let k = (binCount ?? fallback) > 0 ? (binCount ?? fallback) : fallback
        let binWidth = (maxVal - minVal) / Double(k)

        var bins: [HistogramBin] = []
        for i in 0..<k {
            let lower = minVal + Double(i) * binWidth
            let upper = (i == k - 1) ? maxVal : minVal + Double(i + 1) * binWidth
            let count = data.filter { value in
                if i == k - 1 {
                    return value >= lower && value <= upper
                } else {
                    return value >= lower && value < upper
                }
            }.count
            bins.append(HistogramBin(
                lowerBound: lower,
                upperBound: upper,
                frequency: count,
                relativeFrequency: Double(count) / Double(data.count) * 100
            ))
        }

        let mean = data.reduce(0, +) / Double(data.count)
        let variance = data.reduce(0) { $0 + ($1 - mean) * ($1 - mean) } / Double(data.count - 1)
        let stdDev = variance.squareRoot()

        return HistogramResult(
            bins: bins,
            mean: mean,
            standardDeviation: stdDev,
            min: minVal,
            max: maxVal,
            count: data.count
        )
    }

    /// Sturges' rule: k = ceil(1 + 3.322 * log10(n))
    static func sturgesBinCount(n: Int) -> Int {
        Int(ceil(1 + 3.322 * log10(Double(n))))
    }
}
