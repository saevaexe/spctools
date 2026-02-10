import XCTest
@testable import SPCTools

final class FMEAEngineTests: XCTestCase {

    func testRPN() {
        XCTAssertEqual(FMEAEngine.rpn(severity: 5, occurrence: 4, detection: 3), 60)
        XCTAssertEqual(FMEAEngine.rpn(severity: 10, occurrence: 10, detection: 10), 1000)
        XCTAssertEqual(FMEAEngine.rpn(severity: 1, occurrence: 1, detection: 1), 1)
    }

    func testClamp() {
        XCTAssertEqual(FMEAEngine.clamp(0), 1)
        XCTAssertEqual(FMEAEngine.clamp(5), 5)
        XCTAssertEqual(FMEAEngine.clamp(15), 10)
    }

    func testCreateItem() {
        let item = FMEAEngine.createItem(failureMode: "Crack", severity: 8, occurrence: 5, detection: 4)
        XCTAssertEqual(item.rpn, 160)
        XCTAssertEqual(item.severity, 8)
        XCTAssertEqual(item.occurrence, 5)
        XCTAssertEqual(item.detection, 4)
        XCTAssertEqual(item.failureMode, "Crack")
    }

    func testSortByRPN() {
        let items = [
            FMEAEngine.createItem(failureMode: "A", severity: 2, occurrence: 2, detection: 2),
            FMEAEngine.createItem(failureMode: "B", severity: 9, occurrence: 8, detection: 7),
            FMEAEngine.createItem(failureMode: "C", severity: 5, occurrence: 5, detection: 5),
        ]
        let sorted = FMEAEngine.sortByRPN(items)
        XCTAssertEqual(sorted[0].failureMode, "B")
        XCTAssertEqual(sorted[1].failureMode, "C")
        XCTAssertEqual(sorted[2].failureMode, "A")
    }

    func testPriorityLevels() {
        // RPN >= 200 → high
        let highItem = FMEAEngine.createItem(failureMode: "H", severity: 10, occurrence: 5, detection: 5)
        XCTAssertEqual(highItem.rpn, 250)

        // RPN 120-199 → medium
        let medItem = FMEAEngine.createItem(failureMode: "M", severity: 5, occurrence: 5, detection: 5)
        XCTAssertEqual(medItem.rpn, 125)

        // RPN < 120 → low
        let lowItem = FMEAEngine.createItem(failureMode: "L", severity: 2, occurrence: 3, detection: 4)
        XCTAssertEqual(lowItem.rpn, 24)
    }
}
