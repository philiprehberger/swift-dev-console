import XCTest
@testable import DevConsole

final class NetworkMonitorTests: XCTestCase {
    func testRecordAndRetrieve() {
        let monitor = NetworkMonitor()
        let record = NetworkRecord(
            method: "GET",
            url: "https://api.example.com/users",
            statusCode: 200,
            duration: 0.5
        )
        monitor.record(record)
        XCTAssertEqual(monitor.count, 1)
        XCTAssertEqual(monitor.all().first?.url, "https://api.example.com/users")
    }

    func testFilterByMethod() {
        let monitor = NetworkMonitor()
        monitor.record(NetworkRecord(method: "GET", url: "/a", duration: 0.1))
        monitor.record(NetworkRecord(method: "POST", url: "/b", duration: 0.2))
        monitor.record(NetworkRecord(method: "GET", url: "/c", duration: 0.1))
        XCTAssertEqual(monitor.filter(method: "GET").count, 2)
        XCTAssertEqual(monitor.filter(method: "POST").count, 1)
    }

    func testErrors() {
        let monitor = NetworkMonitor()
        monitor.record(NetworkRecord(method: "GET", url: "/ok", statusCode: 200, duration: 0.1))
        monitor.record(NetworkRecord(method: "GET", url: "/fail", statusCode: 500, duration: 0.5))
        monitor.record(NetworkRecord(method: "GET", url: "/err", duration: 0.1, error: "timeout"))
        XCTAssertEqual(monitor.errors().count, 2)
    }

    func testSearch() {
        let monitor = NetworkMonitor()
        monitor.record(NetworkRecord(method: "GET", url: "https://api.example.com/users", duration: 0.1))
        monitor.record(NetworkRecord(method: "GET", url: "https://api.example.com/posts", duration: 0.1))
        XCTAssertEqual(monitor.search("users").count, 1)
    }

    func testClear() {
        let monitor = NetworkMonitor()
        monitor.record(NetworkRecord(method: "GET", url: "/a", duration: 0.1))
        monitor.clear()
        XCTAssertEqual(monitor.count, 0)
    }

    func testAverageDuration() {
        let monitor = NetworkMonitor()
        monitor.record(NetworkRecord(method: "GET", url: "/a", duration: 1.0))
        monitor.record(NetworkRecord(method: "GET", url: "/b", duration: 3.0))
        XCTAssertEqual(monitor.averageDuration, 2.0, accuracy: 0.01)
    }

    func testMaxRecords() {
        let monitor = NetworkMonitor(maxRecords: 3)
        for i in 0..<5 {
            monitor.record(NetworkRecord(method: "GET", url: "/\(i)", duration: 0.1))
        }
        XCTAssertEqual(monitor.count, 3)
    }
}
