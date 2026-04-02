import XCTest
@testable import DevConsole

final class AnalyticsStoreTests: XCTestCase {
    func testTrackAndRetrieve() {
        let store = AnalyticsStore()
        store.track("page_view", properties: ["page": "home"])
        XCTAssertEqual(store.count, 1)
        XCTAssertEqual(store.all().first?.name, "page_view")
    }

    func testFilterByName() {
        let store = AnalyticsStore()
        store.track("page_view")
        store.track("button_click")
        store.track("page_view")
        XCTAssertEqual(store.events(named: "page_view").count, 2)
    }

    func testFilterByDateRange() {
        let store = AnalyticsStore()
        store.track("early")
        let start = Date()
        Thread.sleep(forTimeInterval: 0.01)
        store.track("in_range")
        let end = Date()
        let filtered = store.events(from: start, to: end)
        XCTAssertEqual(filtered.count, 1)
        XCTAssertEqual(filtered.first?.name, "in_range")
    }

    func testSummary() {
        let store = AnalyticsStore()
        store.track("a")
        store.track("b")
        store.track("a")
        let summary = store.summary()
        XCTAssertEqual(summary.count, 2)
        let aCount = summary.first { $0.name == "a" }?.count
        XCTAssertEqual(aCount, 2)
    }

    func testClear() {
        let store = AnalyticsStore()
        store.track("test")
        store.clear()
        XCTAssertEqual(store.count, 0)
    }

    func testMaxEvents() {
        let store = AnalyticsStore(maxEvents: 3)
        for i in 0..<5 {
            store.track("event_\(i)")
        }
        XCTAssertEqual(store.count, 3)
    }

    func testExport() {
        let store = AnalyticsStore()
        store.track("login", properties: ["user": "alice"])
        let exported = store.export()
        XCTAssertTrue(exported.contains("login"))
        XCTAssertTrue(exported.contains("user=alice"))
    }
}
