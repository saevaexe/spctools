import XCTest
@testable import SPCTools

final class HypothesisTestEngineTests: XCTestCase {

    // MARK: - One-Sample Z Test

    func testOneSampleZ_TwoSided_Reject() {
        // Large z → should reject
        let r = HypothesisTestEngine.oneSampleZ(
            sampleMean: 105, mu0: 100, sigma: 10, n: 25, alpha: 0.05, alternative: .twoSided
        )
        // z = (105-100) / (10/5) = 2.5
        XCTAssertEqual(r.testStatistic, 2.5, accuracy: 1e-9)
        XCTAssertTrue(r.pValue < 0.05)
        XCTAssertTrue(r.reject)
    }

    func testOneSampleZ_TwoSided_FailToReject() {
        let r = HypothesisTestEngine.oneSampleZ(
            sampleMean: 100.5, mu0: 100, sigma: 10, n: 25, alpha: 0.05, alternative: .twoSided
        )
        // z = (100.5-100) / (10/5) = 0.25
        XCTAssertEqual(r.testStatistic, 0.25, accuracy: 1e-9)
        XCTAssertTrue(r.pValue > 0.05)
        XCTAssertFalse(r.reject)
    }

    func testOneSampleZ_LeftTail() {
        let r = HypothesisTestEngine.oneSampleZ(
            sampleMean: 95, mu0: 100, sigma: 10, n: 25, alpha: 0.05, alternative: .less
        )
        // z = (95-100) / (10/5) = -2.5
        XCTAssertEqual(r.testStatistic, -2.5, accuracy: 1e-9)
        XCTAssertTrue(r.pValue < 0.05)
        XCTAssertTrue(r.reject)
    }

    func testOneSampleZ_RightTail() {
        let r = HypothesisTestEngine.oneSampleZ(
            sampleMean: 105, mu0: 100, sigma: 10, n: 25, alpha: 0.05, alternative: .greater
        )
        // z = 2.5, right tail → p ≈ 0.0062
        XCTAssertEqual(r.testStatistic, 2.5, accuracy: 1e-9)
        XCTAssertTrue(r.pValue < 0.05)
        XCTAssertTrue(r.reject)
    }

    // MARK: - One-Sample T Test

    func testOneSampleT_LargeSample() {
        // Large df (>30) uses normal approximation
        let r = HypothesisTestEngine.oneSampleT(
            sampleMean: 52, mu0: 50, sampleStdDev: 5, n: 50, alpha: 0.05, alternative: .twoSided
        )
        // t = (52-50) / (5/sqrt(50)) ≈ 2.828
        XCTAssertEqual(r.testStatistic, 2.0 / (5.0 / 50.0.squareRoot()), accuracy: 1e-6)
        XCTAssertTrue(r.pValue < 0.05)
        XCTAssertTrue(r.reject)
    }

    func testOneSampleT_SmallSample() {
        // Small df (<30) uses incomplete beta
        let r = HypothesisTestEngine.oneSampleT(
            sampleMean: 12, mu0: 10, sampleStdDev: 3, n: 10, alpha: 0.05, alternative: .twoSided
        )
        // t = (12-10) / (3/sqrt(10)) ≈ 2.108
        let expectedT = 2.0 / (3.0 / 10.0.squareRoot())
        XCTAssertEqual(r.testStatistic, expectedT, accuracy: 1e-6)
        // With df=9, t≈2.108, p should be around 0.064 (borderline)
        XCTAssertTrue(r.pValue > 0 && r.pValue < 0.2)
    }

    // MARK: - Two-Sample T Test

    func testTwoSampleT() {
        let r = HypothesisTestEngine.twoSampleT(
            mean1: 50, mean2: 45, s1: 8, s2: 7, n1: 30, n2: 30, alpha: 0.05, alternative: .twoSided
        )
        XCTAssertTrue(r.testStatistic > 0, "Mean1 > Mean2 → positive t")
        XCTAssertTrue(r.pValue > 0 && r.pValue < 1)
    }

    func testTwoSampleT_EqualMeans() {
        let r = HypothesisTestEngine.twoSampleT(
            mean1: 50, mean2: 50, s1: 5, s2: 5, n1: 20, n2: 20, alpha: 0.05, alternative: .twoSided
        )
        XCTAssertEqual(r.testStatistic, 0.0, accuracy: 1e-9)
        XCTAssertFalse(r.reject)
    }

    // MARK: - Edge Cases

    func testInvalidInputs() {
        let r1 = HypothesisTestEngine.oneSampleZ(
            sampleMean: 10, mu0: 10, sigma: 0, n: 10, alpha: 0.05, alternative: .twoSided
        )
        XCTAssertFalse(r1.reject)

        let r2 = HypothesisTestEngine.oneSampleT(
            sampleMean: 10, mu0: 10, sampleStdDev: 5, n: 1, alpha: 0.05, alternative: .twoSided
        )
        XCTAssertFalse(r2.reject)
    }

    // MARK: - Incomplete Beta

    func testIncompleteBeta() {
        // I(0.5, 1, 1) = 0.5
        let result = HypothesisTestEngine.incompleteBeta(a: 1, b: 1, x: 0.5)
        XCTAssertEqual(result, 0.5, accuracy: 1e-6)
    }

    func testIncompleteBetaBoundary() {
        XCTAssertEqual(HypothesisTestEngine.incompleteBeta(a: 1, b: 1, x: 0), 0)
        XCTAssertEqual(HypothesisTestEngine.incompleteBeta(a: 1, b: 1, x: 1), 1)
    }
}
