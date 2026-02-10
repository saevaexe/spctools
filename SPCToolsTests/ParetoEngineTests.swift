import XCTest
@testable import SPCTools

final class ParetoEngineTests: XCTestCase {
    func testBasicPareto() {
        let items = ParetoEngine.analyze(
            categories: ["A", "B", "C", "D"],
            counts: [40, 30, 20, 10]
        )
        XCTAssertEqual(items.count, 4)
        XCTAssertEqual(items[0].category, "A")
        XCTAssertEqual(items[0].count, 40)
        XCTAssertEqual(items[0].percentage, 40.0, accuracy: 0.01)
        XCTAssertEqual(items.last?.cumulativePercentage ?? 0, 100.0, accuracy: 0.01)
    }

    func testSortedDescending() {
        let items = ParetoEngine.analyze(
            categories: ["X", "Y", "Z"],
            counts: [5, 50, 20]
        )
        XCTAssertEqual(items[0].category, "Y")
        XCTAssertEqual(items[1].category, "Z")
        XCTAssertEqual(items[2].category, "X")
    }

    func testVitalFew() {
        let items = ParetoEngine.analyze(
            categories: ["A", "B", "C", "D", "E"],
            counts: [50, 25, 10, 10, 5]
        )
        let vital = ParetoEngine.vitalFew(items)
        // A=50% + B=25% = 75%, need C=10% to reach 85% > 80%
        XCTAssertEqual(vital.count, 3)
    }

    func testEmptyInput() {
        let items = ParetoEngine.analyze(categories: [], counts: [])
        XCTAssertTrue(items.isEmpty)
    }

    func testMismatchedCounts() {
        let items = ParetoEngine.analyze(categories: ["A", "B"], counts: [1])
        XCTAssertTrue(items.isEmpty)
    }
}
