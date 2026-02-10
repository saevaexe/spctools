import Foundation
import SwiftData

@Observable
final class ControlChartViewModel {
    enum ChartType: String, CaseIterable {
        case imr = "I-MR"
        case xbarR = "X̄-R"
    }

    var chartType: ChartType = .imr
    var dataText = ""
    var subgroupSize = "5"

    // I-MR results
    var iResult: ControlChartEngine.ChartResult?
    var mrResult: ControlChartEngine.ChartResult?

    // X-bar R results
    var xbarResult: ControlChartEngine.ChartResult?
    var rResult: ControlChartEngine.ChartResult?

    var outOfControlIndices: [Int] = []
    var hasResult: Bool { iResult != nil || xbarResult != nil }

    var isValid: Bool {
        let values = parseData(dataText)
        if chartType == .imr {
            return values.count >= 2
        } else {
            let n = Int(subgroupSize) ?? 5
            return values.count >= n * 2 && n >= 2 && n <= 25
        }
    }

    func calculate() {
        let values = parseData(dataText)

        if chartType == .imr {
            guard let result = ControlChartEngine.imrChart(data: values) else { return }
            iResult = result.i
            mrResult = result.mr
            xbarResult = nil
            rResult = nil
            outOfControlIndices = ControlChartEngine.outOfControlPoints(result.i)
        } else {
            let n = Int(subgroupSize) ?? 5
            let subgroups = stride(from: 0, to: values.count - n + 1, by: n).map {
                Array(values[$0..<min($0 + n, values.count)])
            }.filter { $0.count == n }

            guard let result = ControlChartEngine.xbarRChart(subgroups: subgroups) else { return }
            xbarResult = result.xbar
            rResult = result.r
            iResult = nil
            mrResult = nil
            outOfControlIndices = ControlChartEngine.outOfControlPoints(result.xbar)
        }
    }

    func saveToHistory(modelContext: ModelContext) {
        let values = parseData(dataText)
        let record = CalculationRecord(
            category: .controlChart,
            title: String(localized: "category.controlChart"),
            inputSummary: "\(chartType.rawValue), n=\(values.count)",
            resultSummary: chartType == .imr
                ? "CL: \(iResult?.cl.formatted2 ?? "-"), UCL: \(iResult?.ucl.formatted2 ?? "-")"
                : "X̄: \(xbarResult?.cl.formatted2 ?? "-"), UCL: \(xbarResult?.ucl.formatted2 ?? "-")"
        )
        modelContext.insert(record)
    }

    func reset() {
        dataText = ""; subgroupSize = "5"
        iResult = nil; mrResult = nil; xbarResult = nil; rResult = nil
        outOfControlIndices = []
    }

    private func parseData(_ text: String) -> [Double] {
        text.components(separatedBy: CharacterSet(charactersIn: ",;\n "))
            .compactMap { Double($0.trimmingCharacters(in: .whitespaces).replacingOccurrences(of: ",", with: ".")) }
    }
}
