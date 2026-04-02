import Foundation

/// A recorded network request/response pair.
public struct NetworkRecord: Sendable, Identifiable {
    public let id = UUID()
    public let timestamp: Date
    public let method: String
    public let url: String
    public let statusCode: Int?
    public let duration: TimeInterval
    public let requestHeaders: [String: String]
    public let responseHeaders: [String: String]
    public let requestBodySize: Int
    public let responseBodySize: Int
    public let error: String?

    public init(
        method: String,
        url: String,
        statusCode: Int? = nil,
        duration: TimeInterval,
        requestHeaders: [String: String] = [:],
        responseHeaders: [String: String] = [:],
        requestBodySize: Int = 0,
        responseBodySize: Int = 0,
        error: String? = nil
    ) {
        self.timestamp = Date()
        self.method = method
        self.url = url
        self.statusCode = statusCode
        self.duration = duration
        self.requestHeaders = requestHeaders
        self.responseHeaders = responseHeaders
        self.requestBodySize = requestBodySize
        self.responseBodySize = responseBodySize
        self.error = error
    }
}

/// Thread-safe store for network request records.
public final class NetworkMonitor: @unchecked Sendable {
    private let lock = NSLock()
    private var records: [NetworkRecord] = []
    private let maxRecords: Int

    public init(maxRecords: Int = 500) {
        self.maxRecords = maxRecords
    }

    /// Record a network request.
    public func record(_ entry: NetworkRecord) {
        lock.lock()
        records.append(entry)
        if records.count > maxRecords {
            records.removeFirst(records.count - maxRecords)
        }
        lock.unlock()
    }

    /// Get all records.
    public func all() -> [NetworkRecord] {
        lock.lock()
        defer { lock.unlock() }
        return records
    }

    /// Get records filtered by HTTP method.
    public func filter(method: String) -> [NetworkRecord] {
        lock.lock()
        defer { lock.unlock() }
        return records.filter { $0.method.uppercased() == method.uppercased() }
    }

    /// Get records with errors only.
    public func errors() -> [NetworkRecord] {
        lock.lock()
        defer { lock.unlock() }
        return records.filter { $0.error != nil || ($0.statusCode ?? 0) >= 400 }
    }

    /// Get records matching a URL substring.
    public func search(_ query: String) -> [NetworkRecord] {
        lock.lock()
        defer { lock.unlock() }
        let lowered = query.lowercased()
        return records.filter { $0.url.lowercased().contains(lowered) }
    }

    /// Clear all records.
    public func clear() {
        lock.lock()
        records.removeAll()
        lock.unlock()
    }

    /// Current record count.
    public var count: Int {
        lock.lock()
        defer { lock.unlock() }
        return records.count
    }

    /// Average response time across all records.
    public var averageDuration: TimeInterval {
        lock.lock()
        defer { lock.unlock() }
        guard !records.isEmpty else { return 0 }
        return records.reduce(0.0) { $0 + $1.duration } / Double(records.count)
    }
}
