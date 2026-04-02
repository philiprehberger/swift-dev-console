import XCTest
@testable import DevConsole

final class FeatureFlagStoreTests: XCTestCase {
    func testRegisterAndCheck() {
        let flags = FeatureFlagStore()
        flags.register("dark_mode", default: true)
        XCTAssertTrue(flags.isEnabled("dark_mode"))
    }

    func testDefaultFalse() {
        let flags = FeatureFlagStore()
        flags.register("beta", default: false)
        XCTAssertFalse(flags.isEnabled("beta"))
    }

    func testUnregisteredFlagReturnsFalse() {
        let flags = FeatureFlagStore()
        XCTAssertFalse(flags.isEnabled("nonexistent"))
    }

    func testOverride() {
        let flags = FeatureFlagStore()
        flags.register("feature", default: false)
        flags.setOverride("feature", enabled: true)
        XCTAssertTrue(flags.isEnabled("feature"))
    }

    func testRemoveOverride() {
        let flags = FeatureFlagStore()
        flags.register("feature", default: false)
        flags.setOverride("feature", enabled: true)
        flags.removeOverride("feature")
        XCTAssertFalse(flags.isEnabled("feature"))
    }

    func testClearOverrides() {
        let flags = FeatureFlagStore()
        flags.register("a", default: false)
        flags.register("b", default: false)
        flags.setOverride("a", enabled: true)
        flags.setOverride("b", enabled: true)
        flags.clearOverrides()
        XCTAssertFalse(flags.isEnabled("a"))
        XCTAssertFalse(flags.isEnabled("b"))
    }

    func testAllFlags() {
        let flags = FeatureFlagStore()
        flags.register("alpha", default: true)
        flags.register("beta", default: false)
        flags.setOverride("beta", enabled: true)
        let all = flags.allFlags()
        XCTAssertEqual(all.count, 2)
        let beta = all.first { $0.name == "beta" }!
        XCTAssertTrue(beta.enabled)
        XCTAssertTrue(beta.overridden)
    }

    func testCount() {
        let flags = FeatureFlagStore()
        flags.register("a", default: true)
        flags.register("b", default: false)
        XCTAssertEqual(flags.count, 2)
    }
}
