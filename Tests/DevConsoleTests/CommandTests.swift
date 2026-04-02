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

    @MainActor
    func testCommandHistory() {
        let console = DevConsole.shared
        console.registerCommand("test-hist") { "ok" }
        _ = console.executeAndRecord("test-hist")
        _ = console.executeAndRecord("test-hist")
        XCTAssertEqual(console.commandHistory().count, 2)
        console.clearHistory()
        XCTAssertTrue(console.commandHistory().isEmpty)
    }
}
