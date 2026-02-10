import XCTest
@testable import SPCTools

final class IshikawaEngineTests: XCTestCase {

    func testStandard6M() {
        XCTAssertEqual(IshikawaEngine.standard6M.count, 6)
        XCTAssertTrue(IshikawaEngine.standard6M.contains("Man"))
        XCTAssertTrue(IshikawaEngine.standard6M.contains("Machine"))
        XCTAssertTrue(IshikawaEngine.standard6M.contains("Environment"))
    }

    func testCreateDiagram() {
        let diagram = IshikawaEngine.createDiagram(problem: "Defects")
        XCTAssertEqual(diagram.problem, "Defects")
        XCTAssertEqual(diagram.categories.count, 6)
        for cat in diagram.categories {
            XCTAssertTrue(cat.causes.isEmpty)
        }
    }

    func testTotalCauses() {
        var diagram = IshikawaEngine.createDiagram(problem: "Test")
        XCTAssertEqual(IshikawaEngine.totalCauses(diagram), 0)

        diagram.categories[0].causes.append("Cause A")
        diagram.categories[0].causes.append("Cause B")
        diagram.categories[2].causes.append("Cause C")
        XCTAssertEqual(IshikawaEngine.totalCauses(diagram), 3)
    }
}
