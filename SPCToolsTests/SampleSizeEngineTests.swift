import XCTest
@testable import SPCTools

final class SampleSizeEngineTests: XCTestCase {
    func testSampleSize95_5percent() {
        // 95% confidence, 5% margin, p=0.5 → n = 385
        let result = SampleSizeEngine.sampleSizeProportion(confidenceLevel: 0.95, marginOfError: 0.05)
        XCTAssertEqual(result, 385)
    }

    func testSampleSize99_5percent() {
        // 99% confidence, 5% margin, p=0.5 → n = 664
        let result = SampleSizeEngine.sampleSizeProportion(confidenceLevel: 0.99, marginOfError: 0.05)
        XCTAssertEqual(result, 664)
    }

    func testSampleSize90_5percent() {
        // 90% confidence, 5% margin, p=0.5 → n = 271
        let result = SampleSizeEngine.sampleSizeProportion(confidenceLevel: 0.90, marginOfError: 0.05)
        XCTAssertEqual(result, 271)
    }

    func testFinitePopulationCorrection() {
        let n = SampleSizeEngine.sampleSizeProportion(confidenceLevel: 0.95, marginOfError: 0.05)
        let adjusted = SampleSizeEngine.adjustForPopulation(sampleSize: n, population: 500)
        // Should be less than infinite population sample size
        XCTAssertTrue(adjusted < n)
        XCTAssertTrue(adjusted > 0)
    }

    func testSampleSizeMean() {
        // 95% confidence, E=1, σ=5 → n = (1.96*5/1)^2 = 96.04 → 97
        let result = SampleSizeEngine.sampleSizeMean(confidenceLevel: 0.95, marginOfError: 1.0, stdDev: 5.0)
        XCTAssertEqual(result, 97)
    }

    func testZScore95() {
        let z = SampleSizeEngine.zScore(for: 0.95)
        XCTAssertEqual(z, 1.960, accuracy: 1e-3)
    }
}
