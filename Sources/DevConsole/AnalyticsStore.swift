import Foundation

/// A tracked analytics event.
public struct AnalyticsEvent: Sendable, Identifiable {
    public let id = UUID()
    public let name: String
    public let properties: [String: String]
    public let timestamp: Date

    public init(name: String, properties: [String: String] = [:]) {
        self.name = name
        self.properties = properties
        self.timestamp = Date()
    }
}

/// Thread-safe store for analytics events.
public final class AnalyticsStore: @unchecked Sendable {
    private let lock = NSLock()
    private var events: [AnalyticsEvent] = []
    private let maxEvents: Int

    public init(maxEvents: Int = 5000) {
        self.maxEvents = maxEvents
    }

    /// Track a new event.
    public func track(_ name: String, properties: [String: String] = [:]) {
        let event = AnalyticsEvent(name: name, properties: properties)
        lock.lock()
        events.append(event)
        if events.count > maxEvents {
            events.removeFirst(events.count - maxEvents)
        }
        lock.unlock()
    }

    /// Get all events.
    public func all() -> [AnalyticsEvent] {
        lock.lock()
        defer { lock.unlock() }
        return events
    }

    /// Filter events by name.
    public func events(named name: String) -> [AnalyticsEvent] {
        lock.lock()
        defer { lock.unlock() }
        return events.filter { $0.name == name }
    }

    /// Filter events within a date range.
    public func events(from start: Date, to end: Date) -> [AnalyticsEvent] {
        lock.lock()
        defer { lock.unlock() }
        return events.filter { $0.timestamp >= start && $0.timestamp <= end }
    }

    /// Get unique event names and their counts.
    public func summary() -> [(name: String, count: Int)] {
        lock.lock()
        defer { lock.unlock() }
        var counts: [String: Int] = [:]
        for event in events {
            counts[event.name, default: 0] += 1
        }
        return counts.sorted { $0.key < $1.key }.map { (name: $0.key, count: $0.value) }
    }

    /// Clear all events.
    public func clear() {
        lock.lock()
        events.removeAll()
        lock.unlock()
    }

    /// Number of tracked events.
    public var count: Int {
        lock.lock()
        defer { lock.unlock() }
        return events.count
    }

    /// Export events as formatted string.
    public func export() -> String {
        let formatter = ISO8601DateFormatter()
        return all().map { event in
            let props = event.properties.isEmpty ? "" : " " + event.properties.map { "\($0.key)=\($0.value)" }.joined(separator: " ")
            return "\(formatter.string(from: event.timestamp)) \(event.name)\(props)"
        }.joined(separator: "\n")
    }
}
