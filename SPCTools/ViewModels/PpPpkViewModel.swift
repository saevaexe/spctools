import Foundation
import SwiftData

@Observable
final class PpPpkViewModel {
    var uslText = ""
    var lslText = ""
    var meanText = ""
    var sigmaText = ""

    var ppResult: Double?
    var ppkResult: Double?
    var ppuResult: Double?
    var pplResult: Double?
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

        ppResult = PpPpkEngine.pp(usl: usl, lsl: lsl, sigmaOverall: sigma)
        ppkResult = PpPpkEngine.ppk(usl: usl, lsl: lsl, mean: mean, sigmaOverall: sigma)
        ppuResult = PpPpkEngine.ppu(usl: usl, mean: mean, sigmaOverall: sigma)
        pplResult = PpPpkEngine.ppl(mean: mean, lsl: lsl, sigmaOverall: sigma)
        interpretation = PpPpkEngine.interpretation(ppkResult ?? 0)
    }

    func saveToHistory(modelContext: ModelContext) {
        guard let pp = ppResult, let ppk = ppkResult else { return }
        let record = CalculationRecord(
            category: .ppPpk,
            title: String(localized: "category.ppPpk"),
            inputSummary: "USL: \(uslText), LSL: \(lslText), μ: \(meanText), σ: \(sigmaText)",
            resultSummary: "Pp: \(pp.formatted2), Ppk: \(ppk.formatted2)"
        )
        modelContext.insert(record)
    }

    func reset() {
        uslText = ""; lslText = ""; meanText = ""; sigmaText = ""
        ppResult = nil; ppkResult = nil; ppuResult = nil; pplResult = nil
        interpretation = nil
    }

    private func parseDouble(_ text: String) -> Double? {
        Double(text.replacingOccurrences(of: ",", with: "."))
    }
}
