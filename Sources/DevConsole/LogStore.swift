import Foundation

/// Severity level for log entries.
public enum LogLevel: String, Sendable, CaseIterable {
    case debug = "DEBUG"
    case info = "INFO"
    case warning = "WARNING"
    case error = "ERROR"
}

/// A single log entry.
public struct LogEntry: Sendable, Identifiable {
    public let id = UUID()
    public let timestamp: Date
    public let level: LogLevel
    public let message: String
    public let source: String?

    public init(level: LogLevel, message: String, source: String? = nil) {
        self.timestamp = Date()
        self.level = level
        self.message = message
        self.source = source
    }
}

/// Thread-safe in-memory log store with max capacity.
public final class LogStore: @unchecked Sendable {
    private let lock = NSLock()
    private var entries: [LogEntry] = []
    private let maxEntries: Int

    /// Create a log store with a maximum entry count.
    public init(maxEntries: Int = 1000) {
        self.maxEntries = maxEntries
    }

    /// Add a log entry.
    public func log(_ level: LogLevel, _ message: String, source: String? = nil) {
        let entry = LogEntry(level: level, message: message, source: source)
        lock.lock()
        entries.append(entry)
        if entries.count > maxEntries {
            entries.removeFirst(entries.count - maxEntries)
        }
        lock.unlock()
    }

    /// Convenience: log at debug level.
    public func debug(_ message: String, source: String? = nil) {
        log(.debug, message, source: source)
    }

    /// Convenience: log at info level.
    public func info(_ message: String, source: String? = nil) {
        log(.info, message, source: source)
    }

    /// Convenience: log at warning level.
    public func warning(_ message: String, source: String? = nil) {
        log(.warning, message, source: source)
    }

    /// Convenience: log at error level.
    public func error(_ message: String, source: String? = nil) {
        log(.error, message, source: source)
    }

    /// Get all log entries.
    public func all() -> [LogEntry] {
        lock.lock()
        defer { lock.unlock() }
        return entries
    }

    /// Get entries filtered by level.
    public func filter(level: LogLevel) -> [LogEntry] {
        lock.lock()
        defer { lock.unlock() }
        return entries.filter { $0.level == level }
    }

    /// Get the N most recent entries.
    public func recent(_ count: Int) -> [LogEntry] {
        lock.lock()
        defer { lock.unlock() }
        return Array(entries.suffix(count))
    }

    /// Search entries by message content.
    public func search(_ query: String) -> [LogEntry] {
        lock.lock()
        defer { lock.unlock() }
        let lowered = query.lowercased()
        return entries.filter { $0.message.lowercased().contains(lowered) }
    }

    /// Clear all entries.
    public func clear() {
        lock.lock()
        entries.removeAll()
        lock.unlock()
    }

    /// Current entry count.
    public var count: Int {
        lock.lock()
        defer { lock.unlock() }
        return entries.count
    }

    /// Export all entries as a formatted string.
    public func export() -> String {
        let formatter = ISO8601DateFormatter()
        return all().map { entry in
            let ts = formatter.string(from: entry.timestamp)
            let src = entry.source.map { " [\($0)]" } ?? ""
            return "\(ts) [\(entry.level.rawValue)]\(src) \(entry.message)"
        }.joined(separator: "\n")
    }
}
