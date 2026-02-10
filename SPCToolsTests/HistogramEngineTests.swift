import XCTest
@testable import SPCTools

final class HistogramEngineTests: XCTestCase {
    func testBasicHistogram() {
        let data = [1.0, 2.0, 2.5, 3.0, 3.5, 4.0, 4.5, 5.0, 5.5, 6.0]
        let result = HistogramEngine.analyze(data: data)
        XCTAssertNotNil(result)
        XCTAssertTrue(result!.bins.count > 0)
        XCTAssertEqual(result!.count, 10)
        XCTAssertEqual(result!.min, 1.0, accuracy: 1e-9)
        XCTAssertEqual(result!.max, 6.0, accuracy: 1e-9)
    }

    func testCustomBinCount() {
        let data = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0]
        let result = HistogramEngine.analyze(data: data, binCount: 5)
        XCTAssertNotNil(result)
        XCTAssertEqual(result!.bins.count, 5)
    }

    func testFrequenciesSum() {
        let data = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0]
        let result = HistogramEngine.analyze(data: data)!
        let totalFreq = result.bins.reduce(0) { $0 + $1.frequency }
        XCTAssertEqual(totalFreq, data.count)
    }

    func testSturgesBinCount() {
        XCTAssertEqual(HistogramEngine.sturgesBinCount(n: 10), 5) // 1 + 3.322*1 = 4.322 → 5
        XCTAssertEqual(HistogramEngine.sturgesBinCount(n: 100), 8) // 1 + 3.322*2 = 7.644 → 8
    }

    func testMeanAndStdDev() {
        let data = [2.0, 4.0, 4.0, 4.0, 5.0, 5.0, 7.0, 9.0]
        let result = HistogramEngine.analyze(data: data)!
        XCTAssertEqual(result.mean, 5.0, accuracy: 0.01)
        // Sample std dev = sqrt(32/7) ≈ 2.138
        XCTAssertEqual(result.standardDeviation, 2.138, accuracy: 0.01)
    }

    func testTooFewData() {
        let result = HistogramEngine.analyze(data: [5.0])
        XCTAssertNil(result)
    }
}
