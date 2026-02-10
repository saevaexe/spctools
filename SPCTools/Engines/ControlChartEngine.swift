import Foundation

enum ControlChartEngine {
    struct ChartResult {
        let cl: Double
        let ucl: Double
        let lcl: Double
        let points: [Double]
    }

    // MARK: - X-bar R Chart

    static func xbarRChart(subgroups: [[Double]]) -> (xbar: ChartResult, r: ChartResult)? {
        guard !subgroups.isEmpty else { return nil }
        let n = subgroups[0].count
        guard n >= 2, n <= 25 else { return nil }
        guard subgroups.allSatisfy({ $0.count == n }) else { return nil }

        let means = subgroups.map { $0.reduce(0, +) / Double($0.count) }
        let ranges = subgroups.map { ($0.max() ?? 0) - ($0.min() ?? 0) }

        let xbarBar = means.reduce(0, +) / Double(means.count)
        let rBar = ranges.reduce(0, +) / Double(ranges.count)

        let a2 = AppConstants.SPC.a2(n: n)
        let d3 = AppConstants.SPC.d3(n: n)
        let d4 = AppConstants.SPC.d4(n: n)

        let xbarUCL = xbarBar + a2 * rBar
        let xbarLCL = xbarBar - a2 * rBar

        let rUCL = d4 * rBar
        let rLCL = d3 * rBar

        let xbarResult = ChartResult(cl: xbarBar, ucl: xbarUCL, lcl: xbarLCL, points: means)
        let rResult = ChartResult(cl: rBar, ucl: rUCL, lcl: rLCL, points: ranges)

        return (xbar: xbarResult, r: rResult)
    }

    // MARK: - I-MR Chart (Individual - Moving Range)

    static func imrChart(data: [Double]) -> (i: ChartResult, mr: ChartResult)? {
        guard data.count >= 2 else { return nil }

        let movingRanges = (1..<data.count).map { abs(data[$0] - data[$0 - 1]) }
        let xBar = data.reduce(0, +) / Double(data.count)
        let mrBar = movingRanges.reduce(0, +) / Double(movingRanges.count)

        let d2 = AppConstants.SPC.d2Value(n: 2)
        let d4 = AppConstants.SPC.d4(n: 2)
        let d3 = AppConstants.SPC.d3(n: 2)

        let sigma = mrBar / d2
        let iUCL = xBar + 3 * sigma
        let iLCL = xBar - 3 * sigma

        let mrUCL = d4 * mrBar
        let mrLCL = d3 * mrBar

        let iResult = ChartResult(cl: xBar, ucl: iUCL, lcl: iLCL, points: data)
        let mrResult = ChartResult(cl: mrBar, ucl: mrUCL, lcl: mrLCL, points: movingRanges)

        return (i: iResult, mr: mrResult)
    }

    // MARK: - Out of Control Detection

    static func outOfControlPoints(_ result: ChartResult) -> [Int] {
        result.points.enumerated().compactMap { index, value in
            (value > result.ucl || value < result.lcl) ? index : nil
        }
    }
}
