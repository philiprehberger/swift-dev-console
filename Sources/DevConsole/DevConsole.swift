import Foundation
#if canImport(UIKit)
import UIKit
#endif

/// In-app developer console for debugging, logging, and environment management.
@MainActor
public final class DevConsole: Sendable {
    /// Shared instance.
    public static let shared = DevConsole()

    /// Whether the console is currently visible.
    public private(set) var isVisible = false

    /// The log store.
    public let logs = LogStore()

    /// The network monitor.
    public let network = NetworkMonitor()

    /// The feature flag store.
    public let flags = FeatureFlagStore()

    /// The environment manager.
    public let environment = EnvironmentManager()

    /// The analytics event store.
    public let analytics = AnalyticsStore()

    /// History of executed commands.
    private var _commandHistory: [String] = []

    /// Registered custom commands.
    private var commands: [String: Command] = [:]

    private init() {}

    /// Show the console.
    public func show() {
        isVisible = true
    }

    /// Hide the console.
    public func hide() {
        isVisible = false
    }

    /// Toggle console visibility.
    public func toggle() {
        isVisible.toggle()
    }

    /// Register a custom command.
    ///
    /// - Parameters:
    ///   - name: The command name.
    ///   - description: A short description.
    ///   - handler: The closure to execute.
    public func registerCommand(_ name: String, description: String = "", handler: @escaping @Sendable () -> String) {
        commands[name] = Command(name: name, description: description, handler: handler)
    }

    /// Execute a registered command by name.
    ///
    /// - Parameter name: The command name.
    /// - Returns: The command output, or an error message.
    public func executeCommand(_ name: String) -> String {
        guard let command = commands[name] else {
            return "Unknown command: \(name). Available: \(availableCommands().joined(separator: ", "))"
        }
        return command.handler()
    }

    /// List all registered command names.
    public func availableCommands() -> [String] {
        commands.keys.sorted()
    }

    /// Execute a command and record it in history.
    ///
    /// - Parameter name: The command name.
    /// - Returns: The command output.
    public func executeAndRecord(_ name: String) -> String {
        _commandHistory.append(name)
        return executeCommand(name)
    }

    /// Get the command execution history.
    public func commandHistory() -> [String] {
        _commandHistory
    }

    /// Clear command history.
    public func clearHistory() {
        _commandHistory.removeAll()
    }

    /// Enable shake-to-open on iOS. Call this in your app's didFinishLaunching.
    #if canImport(UIKit)
    public func enableShakeToOpen() {
        ShakeDetector.shared.onShake = { [weak self] in
            self?.toggle()
        }
        ShakeDetector.shared.isEnabled = true
    }
    #endif
}
