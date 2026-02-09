import XCTest
@testable import SPCTools

final class OEEEngineTests: XCTestCase {
    func testAvailability() {
        let result = OEEEngine.availability(plannedTime: 480, downtime: 48)
        XCTAssertEqual(result, 90.0, accuracy: 1e-9)
    }

    func testPerformance() {
        let result = OEEEngine.performance(idealCycleTime: 1.0, totalCount: 400, runTime: 432)
        XCTAssertEqual(result, 400.0/432.0 * 100, accuracy: 1e-9)
    }

    func testQuality() {
        let result = OEEEngine.quality(totalCount: 400, defectCount: 8)
        XCTAssertEqual(result, 98.0, accuracy: 1e-9)
    }

    func testOEE() {
        let result = OEEEngine.oee(availability: 90, performance: 92.593, quality: 98)
        // 90 * 92.593 * 98 / 10000 = 81.61...
        XCTAssertEqual(result, 90.0 * 92.593 * 98.0 / 10000.0, accuracy: 1e-3)
    }

    func testWorldClassOEE() {
        let result = OEEEngine.oee(availability: 95, performance: 95, quality: 95)
        // 95 * 95 * 95 / 10000 = 85.7375
        XCTAssertEqual(result, 85.7375, accuracy: 1e-4)
    }

    func testZeroPlannedTime() {
        let result = OEEEngine.availability(plannedTime: 0, downtime: 10)
        XCTAssertEqual(result, 0)
    }
}
