import Foundation
import SwiftData

@Observable
final class HypothesisTestViewModel {
    var testType: HypothesisTestEngine.TestType = .oneSampleZ
    var alternative: HypothesisTestEngine.Alternative = .twoSided
    var alphaText = "0.05"

    // One-sample inputs
    var sampleMeanText = ""
    var mu0Text = ""
    var sigmaText = ""
    var sampleStdDevText = ""
    var nText = ""

    // Two-sample inputs
    var mean2Text = ""
    var s2Text = ""
    var n2Text = ""

    var result: HypothesisTestEngine.TestResult?

    var isValid: Bool {
        guard let alpha = parseDouble(alphaText), alpha > 0, alpha < 1 else { return false }

        switch testType {
        case .oneSampleZ:
            return parseDouble(sampleMeanText) != nil && parseDouble(mu0Text) != nil
                && parseDouble(sigmaText) != nil && Int(nText) != nil
        case .oneSampleT:
            return parseDouble(sampleMeanText) != nil && parseDouble(mu0Text) != nil
                && parseDouble(sampleStdDevText) != nil && Int(nText) != nil
        case .twoSampleT:
            return parseDouble(sampleMeanText) != nil && parseDouble(mean2Text) != nil
                && parseDouble(sampleStdDevText) != nil && parseDouble(s2Text) != nil
                && Int(nText) != nil && Int(n2Text) != nil
        }
    }

    func calculate() {
        guard let alpha = parseDouble(alphaText) else { return }

        switch testType {
        case .oneSampleZ:
            guard let xbar = parseDouble(sampleMeanText), let mu0 = parseDouble(mu0Text),
                  let sigma = parseDouble(sigmaText), let n = Int(nText) else { return }
            result = HypothesisTestEngine.oneSampleZ(
                sampleMean: xbar, mu0: mu0, sigma: sigma, n: n, alpha: alpha, alternative: alternative
            )
        case .oneSampleT:
            guard let xbar = parseDouble(sampleMeanText), let mu0 = parseDouble(mu0Text),
                  let s = parseDouble(sampleStdDevText), let n = Int(nText) else { return }
            result = HypothesisTestEngine.oneSampleT(
                sampleMean: xbar, mu0: mu0, sampleStdDev: s, n: n, alpha: alpha, alternative: alternative
            )
        case .twoSampleT:
            guard let x1 = parseDouble(sampleMeanText), let x2 = parseDouble(mean2Text),
                  let s1 = parseDouble(sampleStdDevText), let s2 = parseDouble(s2Text),
                  let n1 = Int(nText), let n2 = Int(n2Text) else { return }
            result = HypothesisTestEngine.twoSampleT(
                mean1: x1, mean2: x2, s1: s1, s2: s2, n1: n1, n2: n2, alpha: alpha, alternative: alternative
            )
        }
    }

    func saveToHistory(modelContext: ModelContext) {
        guard let r = result else { return }
        let record = CalculationRecord(
            category: .hypothesisTest,
            title: String(localized: "category.hypothesisTest"),
            inputSummary: "\(testType.rawValue), α=\(alphaText)",
            resultSummary: "p=\(r.pValue.formatted2), \(r.reject ? "Reject" : "Fail to reject")"
        )
        modelContext.insert(record)
    }

    func reset() {
        sampleMeanText = ""; mu0Text = ""; sigmaText = ""; sampleStdDevText = ""
        nText = ""; mean2Text = ""; s2Text = ""; n2Text = ""
        alphaText = "0.05"; result = nil
    }

    private func parseDouble(_ text: String) -> Double? {
        Double(text.replacingOccurrences(of: ",", with: "."))
    }
}
