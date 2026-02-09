import XCTest
@testable import SPCTools

final class CpCpkEngineTests: XCTestCase {
    func testCp() {
        let result = CpCpkEngine.cp(usl: 10, lsl: 4, sigma: 1)
        XCTAssertEqual(result, 1.0, accuracy: 1e-9)
    }

    func testCpHighCapability() {
        let result = CpCpkEngine.cp(usl: 12, lsl: 0, sigma: 1)
        XCTAssertEqual(result, 2.0, accuracy: 1e-9)
    }

    func testCpk_Centered() {
        let result = CpCpkEngine.cpk(usl: 10, lsl: 4, mean: 7, sigma: 1)
        XCTAssertEqual(result, 1.0, accuracy: 1e-9)
    }

    func testCpk_ShiftedHigh() {
        let result = CpCpkEngine.cpk(usl: 10, lsl: 4, mean: 9, sigma: 1)
        // Cpu = (10-9)/(3*1) = 0.333
        // Cpl = (9-4)/(3*1) = 1.667
        XCTAssertEqual(result, 1.0/3.0, accuracy: 1e-9)
    }

    func testCpu() {
        let result = CpCpkEngine.cpu(usl: 10, mean: 7, sigma: 1)
        XCTAssertEqual(result, 1.0, accuracy: 1e-9)
    }

    func testCpl() {
        let result = CpCpkEngine.cpl(mean: 7, lsl: 4, sigma: 1)
        XCTAssertEqual(result, 1.0, accuracy: 1e-9)
    }

    func testStandardDeviation() {
        let data = [2.0, 4.0, 4.0, 4.0, 5.0, 5.0, 7.0, 9.0]
        let result = CpCpkEngine.standardDeviation(data)
        // Sample std dev (n-1): sqrt(32/7) ≈ 2.1381
        XCTAssertEqual(result, 2.1381, accuracy: 0.001)
    }

    func testZeroSigma() {
        let cp = CpCpkEngine.cp(usl: 10, lsl: 4, sigma: 0)
        XCTAssertEqual(cp, 0)
    }
}
