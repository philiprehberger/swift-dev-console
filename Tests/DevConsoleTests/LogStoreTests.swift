import XCTest
@testable import DevConsole

final class LogStoreTests: XCTestCase {
    func testLogAndRetrieve() {
        let store = LogStore()
        store.info("hello")
        store.error("oops")
        XCTAssertEqual(store.count, 2)
        XCTAssertEqual(store.all().count, 2)
    }

    func testLogLevels() {
        let store = LogStore()
        store.debug("d")
        store.info("i")
        store.warning("w")
        store.error("e")
        XCTAssertEqual(store.filter(level: .debug).count, 1)
        XCTAssertEqual(store.filter(level: .error).count, 1)
    }

    func testRecent() {
        let store = LogStore()
        for i in 0..<10 {
            store.info("msg \(i)")
        }
        let recent = store.recent(3)
        XCTAssertEqual(recent.count, 3)
        XCTAssertTrue(recent.last!.message.contains("9"))
    }

    func testSearch() {
        let store = LogStore()
        store.info("connection established")
        store.info("data loaded")
        store.error("connection failed")
        let results = store.search("connection")
        XCTAssertEqual(results.count, 2)
    }

    func testClear() {
        let store = LogStore()
        store.info("test")
        store.clear()
        XCTAssertEqual(store.count, 0)
    }

    func testMaxEntries() {
        let store = LogStore(maxEntries: 5)
        for i in 0..<10 {
            store.info("msg \(i)")
        }
        XCTAssertEqual(store.count, 5)
        XCTAssertTrue(store.all().first!.message.contains("5"))
    }

    func testExport() {
        let store = LogStore()
        store.info("hello world")
        let exported = store.export()
        XCTAssertTrue(exported.contains("[INFO]"))
        XCTAssertTrue(exported.contains("hello world"))
    }

    func testSourceTracking() {
        let store = LogStore()
        store.info("test", source: "NetworkLayer")
        let exported = store.export()
        XCTAssertTrue(exported.contains("[NetworkLayer]"))
    }
}
