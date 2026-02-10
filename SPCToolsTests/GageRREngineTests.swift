import XCTest
@testable import SPCTools

final class GageRREngineTests: XCTestCase {
    func testBasicGageRR() {
        // 2 operators, 3 parts, 2 trials
        let measurements: [[[Double]]] = [
            // Operator 1
            [[10.1, 10.2], [10.3, 10.4], [10.5, 10.5]],
            // Operator 2
            [[10.0, 10.3], [10.2, 10.5], [10.4, 10.6]],
        ]
        let result = GageRREngine.calculate(measurements: measurements)
        XCTAssertNotNil(result)
        XCTAssertTrue(result!.percentGRR > 0)
        XCTAssertTrue(result!.totalVariation > 0)
    }

    func testGRRComponents() {
        let measurements: [[[Double]]] = [
            [[5.0, 5.1], [6.0, 6.1], [7.0, 7.1]],
            [[5.2, 5.0], [6.2, 6.0], [7.2, 7.0]],
        ]
        let result = GageRREngine.calculate(measurements: measurements)!
        // EV and AV should be non-negative
        XCTAssertTrue(result.repeatability >= 0)
        XCTAssertTrue(result.reproducibility >= 0)
        XCTAssertTrue(result.gageRR >= 0)
        XCTAssertTrue(result.ndc >= 0)
    }

    func testInterpretationAcceptable() {
        let interp = GageRREngine.interpretation(percentGRR: 5.0)
        XCTAssertFalse(interp.isEmpty)
    }

    func testInterpretationUnacceptable() {
        let interp = GageRREngine.interpretation(percentGRR: 35.0)
        XCTAssertFalse(interp.isEmpty)
    }

    func testTooFewInputs() {
        let result = GageRREngine.calculate(measurements: [[[1.0]]])
        XCTAssertNil(result)
    }
}
