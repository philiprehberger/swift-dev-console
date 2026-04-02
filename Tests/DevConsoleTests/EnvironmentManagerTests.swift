import XCTest
@testable import DevConsole

final class EnvironmentManagerTests: XCTestCase {
    func testRegisterAndSwitch() {
        let env = EnvironmentManager()
        env.register("staging", config: ["api": "https://staging.example.com"])
        env.register("production", config: ["api": "https://api.example.com"])
        XCTAssertEqual(env.current, "staging") // first registered becomes current
        XCTAssertTrue(env.switchTo("production"))
        XCTAssertEqual(env.current, "production")
    }

    func testSwitchToNonexistent() {
        let env = EnvironmentManager()
        env.register("dev", config: [:])
        XCTAssertFalse(env.switchTo("nonexistent"))
        XCTAssertEqual(env.current, "dev")
    }

    func testCurrentConfig() {
        let env = EnvironmentManager()
        env.register("dev", config: ["api": "http://localhost:8080", "debug": "true"])
        XCTAssertEqual(env.currentConfig["api"], "http://localhost:8080")
    }

    func testValueForKey() {
        let env = EnvironmentManager()
        env.register("prod", config: ["api_key": "secret123"])
        XCTAssertEqual(env.value(for: "api_key"), "secret123")
        XCTAssertNil(env.value(for: "missing"))
    }

    func testAllEnvironments() {
        let env = EnvironmentManager()
        env.register("dev", config: [:])
        env.register("staging", config: [:])
        env.register("prod", config: [:])
        XCTAssertEqual(env.allEnvironments(), ["dev", "prod", "staging"])
    }
}
