import XCTest
@testable import SPCTools

final class ControlChartEngineTests: XCTestCase {
    func testIMRChart() {
        let data = [10.0, 12.0, 11.0, 13.0, 10.0, 11.0, 14.0, 12.0]
        let result = ControlChartEngine.imrChart(data: data)
        XCTAssertNotNil(result)

        let i = result!.i
        let mr = result!.mr
        XCTAssertEqual(i.points.count, 8)
        XCTAssertEqual(mr.points.count, 7) // moving ranges = n-1
        XCTAssertTrue(i.ucl > i.cl)
        XCTAssertTrue(i.lcl < i.cl)
    }

    func testXbarRChart() {
        let subgroups: [[Double]] = [
            [10, 12, 11], [13, 10, 11], [14, 12, 13], [11, 10, 12], [12, 13, 11]
        ]
        let result = ControlChartEngine.xbarRChart(subgroups: subgroups)
        XCTAssertNotNil(result)

        let xbar = result!.xbar
        let r = result!.r
        XCTAssertEqual(xbar.points.count, 5)
        XCTAssertEqual(r.points.count, 5)
        XCTAssertTrue(xbar.ucl > xbar.cl)
        XCTAssertTrue(r.ucl > r.cl)
    }

    func testOutOfControlPoints() {
        let result = ControlChartEngine.ChartResult(cl: 10, ucl: 15, lcl: 5, points: [10, 12, 16, 8, 4, 11])
        let ooc = ControlChartEngine.outOfControlPoints(result)
        XCTAssertEqual(ooc, [2, 4]) // index 2 (16>15) and index 4 (4<5)
    }

    func testIMRChartTooFewPoints() {
        let result = ControlChartEngine.imrChart(data: [10])
        XCTAssertNil(result)
    }

    func testXbarRUnequalSubgroups() {
        let subgroups: [[Double]] = [[10, 12], [13, 10, 11]]
        let result = ControlChartEngine.xbarRChart(subgroups: subgroups)
        XCTAssertNil(result)
    }
}
