import XCTest
@testable import DevConsole

final class CommandTests: XCTestCase {
    func testCommandExecution() {
        let cmd = Command(name: "ping", description: "Ping test") {
            "pong"
        }
        XCTAssertEqual(cmd.handler(), "pong")
        XCTAssertEqual(cmd.name, "ping")
        XCTAssertEqual(cmd.description, "Ping test")
    }
}
