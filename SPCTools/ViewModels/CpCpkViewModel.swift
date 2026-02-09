import Foundation
import SwiftData

@Observable
final class CpCpkViewModel {
    var uslText = ""
    var lslText = ""
    var meanText = ""
    var sigmaText = ""

    var cpResult: Double?
    var cpkResult: Double?
    var cpuResult: Double?
    var cplResult: Double?
    var interpretation: String?

    var isValid: Bool {
        guard let usl = parseDouble(uslText),
              let lsl = parseDouble(lslText),
              let mean = parseDouble(meanText),
              let sigma = parseDouble(sigmaText) else { return false }
        return usl > lsl && sigma > 0 && mean >= lsl && mean <= usl
    }

    func calculate() {
        guard let usl = parseDouble(uslText),
              let lsl = parseDouble(lslText),
              let mean = parseDouble(meanText),
              let sigma = parseDouble(sigmaText) else { return }

        cpResult = CpCpkEngine.cp(usl: usl, lsl: lsl, sigma: sigma)
        cpkResult = CpCpkEngine.cpk(usl: usl, lsl: lsl, mean: mean, sigma: sigma)
        cpuResult = CpCpkEngine.cpu(usl: usl, mean: mean, sigma: sigma)
        cplResult = CpCpkEngine.cpl(mean: mean, lsl: lsl, sigma: sigma)
        interpretation = CpCpkEngine.interpretation(cpkResult ?? 0)
    }

    func saveToHistory(modelContext: ModelContext) {
        guard let cp = cpResult, let cpk = cpkResult else { return }
        let record = CalculationRecord(
            category: .cpCpk,
            title: String(localized: "category.cpCpk"),
            inputSummary: "USL: \(uslText), LSL: \(lslText), μ: \(meanText), σ: \(sigmaText)",
            resultSummary: "Cp: \(cp.formatted2), Cpk: \(cpk.formatted2)"
        )
        modelContext.insert(record)
    }

    func reset() {
        uslText = ""
        lslText = ""
        meanText = ""
        sigmaText = ""
        cpResult = nil
        cpkResult = nil
        cpuResult = nil
        cplResult = nil
        interpretation = nil
    }

    private func parseDouble(_ text: String) -> Double? {
        Double(text.replacingOccurrences(of: ",", with: "."))
    }
}
