import XCTest
@testable import SPCTools

final class AQLEngineTests: XCTestCase {
    func testCodeLetterLevelII() {
        // Lot size 500, Level II → H
        let code = AQLEngine.codeLetter(lotSize: 500, inspectionLevel: "II")
        XCTAssertEqual(code, "H")
    }

    func testCodeLetterLevelI() {
        // Lot size 500, Level I → F
        let code = AQLEngine.codeLetter(lotSize: 500, inspectionLevel: "I")
        XCTAssertEqual(code, "F")
    }

    func testSampleSize() {
        XCTAssertEqual(AQLEngine.sampleSize(codeLetter: "H"), 50)
        XCTAssertEqual(AQLEngine.sampleSize(codeLetter: "J"), 80)
        XCTAssertEqual(AQLEngine.sampleSize(codeLetter: "A"), 2)
    }

    func testSamplingPlan() {
        // Lot=500, Level II, AQL=1.0
        let plan = AQLEngine.samplingPlan(lotSize: 500, inspectionLevel: "II", aql: 1.0)
        XCTAssertNotNil(plan)
        XCTAssertEqual(plan!.codeLetter, "H")
        XCTAssertEqual(plan!.sampleSize, 50)
        XCTAssertEqual(plan!.acceptNumber, 3)
        XCTAssertEqual(plan!.rejectNumber, 4)
    }

    func testInvalidLotSize() {
        let code = AQLEngine.codeLetter(lotSize: 0)
        XCTAssertNil(code)
    }

    func testNotApplicableAQL() {
        // Very small sample with very low AQL → (-1,-1) = not applicable
        let ar = AQLEngine.acceptReject(codeLetter: "A", aql: 0.065)
        XCTAssertNil(ar) // Should be nil because Ac=-1
    }
}
