import XCTest
@testable import SPCTools

final class AlphaBetaEngineTests: XCTestCase {

    func testBetaCalculation() {
        // alpha=0.05, effectSize=0.5, n=64 → power should be high
        let b = AlphaBetaEngine.beta(alpha: 0.05, effectSize: 0.5, n: 64)
        XCTAssertTrue(b > 0 && b < 1)
        XCTAssertTrue(b < 0.1, "Beta should be small with large sample and medium effect")
    }

    func testPowerCalculation() {
        let p = AlphaBetaEngine.power(alpha: 0.05, effectSize: 0.5, n: 64)
        XCTAssertTrue(p > 0.9, "Power should be > 0.9 for n=64, d=0.5")
    }

    func testPowerPlusBetaEqualsOne() {
        let alpha = 0.05
        let effectSize = 0.3
        let n = 30
        let b = AlphaBetaEngine.beta(alpha: alpha, effectSize: effectSize, n: n)
        let p = AlphaBetaEngine.power(alpha: alpha, effectSize: effectSize, n: n)
        XCTAssertEqual(b + p, 1.0, accuracy: 1e-10)
    }

    func testRequiredSampleSize() {
        let n = AlphaBetaEngine.requiredSampleSize(alpha: 0.05, desiredPower: 0.80, effectSize: 0.5)
        // For z-test: n ≈ ((1.96 + 0.84) / 0.5)^2 ≈ 31.4 → 32
        XCTAssertTrue(n > 25 && n < 40, "Required n should be around 32")
    }

    func testAnalyze() {
        let result = AlphaBetaEngine.analyze(alpha: 0.05, effectSize: 0.5, n: 50)
        XCTAssertEqual(result.alpha, 0.05)
        XCTAssertEqual(result.sampleSize, 50)
        XCTAssertEqual(result.power + result.beta, 1.0, accuracy: 1e-10)
    }

    func testEdgeCases() {
        // Zero effect size → beta = 1
        XCTAssertEqual(AlphaBetaEngine.beta(alpha: 0.05, effectSize: 0, n: 100), 1.0)

        // Zero sample size → beta = 1
        XCTAssertEqual(AlphaBetaEngine.beta(alpha: 0.05, effectSize: 0.5, n: 0), 1.0)

        // Zero effect size → required n = 0
        XCTAssertEqual(AlphaBetaEngine.requiredSampleSize(alpha: 0.05, desiredPower: 0.80, effectSize: 0), 0)
    }
}
