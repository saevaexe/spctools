import XCTest
@testable import SPCTools

final class SigmaLevelEngineTests: XCTestCase {
    func testDPMO() {
        let result = SigmaLevelEngine.dpmo(defects: 10, units: 1000, opportunities: 5)
        XCTAssertEqual(result, 2000.0, accuracy: 1e-9)
    }

    func testYieldFromDPMO() {
        let result = SigmaLevelEngine.yieldFromDPMO(3.4)
        XCTAssertEqual(result, 99.99966, accuracy: 1e-4)
    }

    func testSigmaFromDPMO_SixSigma() {
        // 3.4 DPMO should give approximately 6 sigma
        let result = SigmaLevelEngine.sigmaFromDPMO(3.4)
        XCTAssertEqual(result, 6.0, accuracy: 0.1)
    }

    func testSigmaFromDPMO_ThreeSigma() {
        // ~66807 DPMO ≈ 3 sigma
        let result = SigmaLevelEngine.sigmaFromDPMO(66807)
        XCTAssertEqual(result, 3.0, accuracy: 0.1)
    }

    func testDPMOFromSigma() {
        let result = SigmaLevelEngine.dpmoFromSigma(6.0)
        XCTAssertEqual(result, 3.4, accuracy: 1.0)
    }

    func testNormalCDF() {
        let result = SigmaLevelEngine.normalCDF(0)
        XCTAssertEqual(result, 0.5, accuracy: 1e-6)
    }

    func testInverseNormalCDF() {
        let result = SigmaLevelEngine.inverseNormalCDF(0.5)
        XCTAssertEqual(result, 0.0, accuracy: 1e-6)
    }

    func testZeroDPMO() {
        let result = SigmaLevelEngine.sigmaFromDPMO(0)
        XCTAssertEqual(result, 6.0, accuracy: 1e-9)
    }
}
