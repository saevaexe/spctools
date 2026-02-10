import XCTest
@testable import SPCTools

final class PpPpkEngineTests: XCTestCase {
    func testPp() {
        let result = PpPpkEngine.pp(usl: 10, lsl: 4, sigmaOverall: 1)
        XCTAssertEqual(result, 1.0, accuracy: 1e-9)
    }

    func testPpk_Centered() {
        let result = PpPpkEngine.ppk(usl: 10, lsl: 4, mean: 7, sigmaOverall: 1)
        XCTAssertEqual(result, 1.0, accuracy: 1e-9)
    }

    func testPpk_Shifted() {
        let result = PpPpkEngine.ppk(usl: 10, lsl: 4, mean: 9, sigmaOverall: 1)
        XCTAssertEqual(result, 1.0/3.0, accuracy: 1e-9)
    }

    func testPpu() {
        let result = PpPpkEngine.ppu(usl: 10, mean: 7, sigmaOverall: 1)
        XCTAssertEqual(result, 1.0, accuracy: 1e-9)
    }

    func testPpl() {
        let result = PpPpkEngine.ppl(mean: 7, lsl: 4, sigmaOverall: 1)
        XCTAssertEqual(result, 1.0, accuracy: 1e-9)
    }

    func testOverallSigma() {
        let data = [2.0, 4.0, 4.0, 4.0, 5.0, 5.0, 7.0, 9.0]
        let result = PpPpkEngine.overallSigma(data)
        // Population std dev (N): sqrt(32/8) = 2.0
        XCTAssertEqual(result, 2.0, accuracy: 0.001)
    }

    func testZeroSigma() {
        let result = PpPpkEngine.pp(usl: 10, lsl: 4, sigmaOverall: 0)
        XCTAssertEqual(result, 0)
    }
}
