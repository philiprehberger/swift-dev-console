import Foundation

/// Manages named environments (e.g., production, staging, development).
public final class EnvironmentManager: @unchecked Sendable {
    private let lock = NSLock()
    private var environments: [String: [String: String]] = [:]
    private var _current: String = ""

    public init() {}

    /// Register an environment with key-value configuration.
    public func register(_ name: String, config: [String: String]) {
        lock.lock()
        environments[name] = config
        if _current.isEmpty {
            _current = name
        }
        lock.unlock()
    }

    /// Switch to a named environment.
    ///
    /// - Returns: True if the environment exists and was activated.
    @discardableResult
    public func switchTo(_ name: String) -> Bool {
        lock.lock()
        defer { lock.unlock() }
        guard environments[name] != nil else { return false }
        _current = name
        return true
    }

    /// The currently active environment name.
    public var current: String {
        lock.lock()
        defer { lock.unlock() }
        return _current
    }

    /// Get the configuration for the current environment.
    public var currentConfig: [String: String] {
        lock.lock()
        defer { lock.unlock() }
        return environments[_current] ?? [:]
    }

    /// Get a specific value from the current environment.
    public func value(for key: String) -> String? {
        lock.lock()
        defer { lock.unlock() }
        return environments[_current]?[key]
    }

    /// List all registered environment names.
    public func allEnvironments() -> [String] {
        lock.lock()
        defer { lock.unlock() }
        return environments.keys.sorted()
    }
}
