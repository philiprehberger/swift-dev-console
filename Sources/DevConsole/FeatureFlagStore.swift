import Foundation

/// Thread-safe feature flag store with override support.
public final class FeatureFlagStore: @unchecked Sendable {
    private let lock = NSLock()
    private var defaults: [String: Bool] = [:]
    private var overrides: [String: Bool] = [:]

    public init() {}

    /// Register a flag with a default value.
    public func register(_ name: String, default defaultValue: Bool) {
        lock.lock()
        defaults[name] = defaultValue
        lock.unlock()
    }

    /// Check if a flag is enabled (overrides take priority).
    public func isEnabled(_ name: String) -> Bool {
        lock.lock()
        defer { lock.unlock() }
        return overrides[name] ?? defaults[name] ?? false
    }

    /// Set an override for a flag.
    public func setOverride(_ name: String, enabled: Bool) {
        lock.lock()
        overrides[name] = enabled
        lock.unlock()
    }

    /// Remove an override, reverting to the default.
    public func removeOverride(_ name: String) {
        lock.lock()
        overrides.removeValue(forKey: name)
        lock.unlock()
    }

    /// Remove all overrides.
    public func clearOverrides() {
        lock.lock()
        overrides.removeAll()
        lock.unlock()
    }

    /// List all registered flag names and their current values.
    public func allFlags() -> [(name: String, enabled: Bool, overridden: Bool)] {
        lock.lock()
        defer { lock.unlock() }
        return defaults.keys.sorted().map { name in
            let overridden = overrides[name] != nil
            let enabled = overrides[name] ?? defaults[name] ?? false
            return (name: name, enabled: enabled, overridden: overridden)
        }
    }

    /// Number of registered flags.
    public var count: Int {
        lock.lock()
        defer { lock.unlock() }
        return defaults.count
    }
}
