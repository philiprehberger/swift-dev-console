# DevConsole

[![Tests](https://github.com/philiprehberger/swift-dev-console/actions/workflows/ci.yml/badge.svg)](https://github.com/philiprehberger/swift-dev-console/actions/workflows/ci.yml)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fphiliprehberger%2Fswift-dev-console%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/philiprehberger/swift-dev-console)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fphiliprehberger%2Fswift-dev-console%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/philiprehberger/swift-dev-console)

In-app developer console with logs, network monitoring, feature flags, and environment switching

## Requirements

- Swift >= 6.0
- macOS 13+ / iOS 16+ / tvOS 16+ / watchOS 9+

## Installation

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/philiprehberger/swift-dev-console.git", from: "0.2.0")
]
```

Then add `"DevConsole"` to your target dependencies:

```swift
.target(name: "YourTarget", dependencies: [
    .product(name: "DevConsole", package: "swift-dev-console")
])
```

## Usage

```swift
import DevConsole

let console = DevConsole.shared
console.logs.info("App launched")
console.show()
```

### Logging

Log messages with severity levels, then search, filter, or export:

```swift
console.logs.debug("Loading config")
console.logs.info("User signed in")
console.logs.warning("Cache miss")
console.logs.error("Request failed", source: "NetworkLayer")

// Search and filter
let errors = console.logs.filter(level: .error)
let recent = console.logs.recent(10)
let matches = console.logs.search("signed in")

// Export to string
let exported = console.logs.export()
```

### Network Monitoring

Record HTTP requests for inspection:

```swift
let record = NetworkRecord(
    method: "GET",
    url: "https://api.example.com/users",
    statusCode: 200,
    duration: 0.35,
    requestHeaders: ["Authorization": "Bearer ..."],
    responseHeaders: ["Content-Type": "application/json"],
    responseBodySize: 4096
)
console.network.record(record)

// Query
let failures = console.network.errors()
let getRequests = console.network.filter(method: "GET")
let avgTime = console.network.averageDuration
```

### Feature Flags

Register flags with defaults, then override at runtime:

```swift
console.flags.register("dark_mode", default: true)
console.flags.register("new_checkout", default: false)

console.flags.isEnabled("dark_mode")  // true

// Override at runtime (e.g., from the console UI)
console.flags.setOverride("new_checkout", enabled: true)
console.flags.isEnabled("new_checkout")  // true

// Revert to default
console.flags.removeOverride("new_checkout")
```

### Environment Switching

Register named environments and switch between them:

```swift
console.environment.register("production", config: [
    "api": "https://api.example.com",
    "analytics": "true"
])
console.environment.register("staging", config: [
    "api": "https://staging.example.com",
    "analytics": "false"
])

console.environment.switchTo("staging")
console.environment.value(for: "api")  // "https://staging.example.com"
```

### Custom Commands

Register commands that can be executed from the console:

```swift
console.registerCommand("clear-cache", description: "Clear all caches") {
    // ... clear caches ...
    return "Cache cleared"
}

let output = console.executeCommand("clear-cache")  // "Cache cleared"
```

### Analytics Events

Track custom events with properties:

```swift
console.analytics.track("button_click", properties: ["button": "checkout"])
console.analytics.track("page_view", properties: ["page": "home"])

let clicks = console.analytics.events(named: "button_click")
let summary = console.analytics.summary()  // [(name: "button_click", count: 1), ...]
let exported = console.analytics.export()
```

### Command History

Track and recall executed commands:

```swift
let output = console.executeAndRecord("clear-cache")
console.commandHistory()  // ["clear-cache"]
```

### Shake to Open (iOS)

Enable shake gesture to toggle the console:

```swift
// In your AppDelegate or App init:
DevConsole.shared.enableShakeToOpen()

// Use ShakeDetectingWindow as your app's window class:
// In SceneDelegate:
window = ShakeDetectingWindow(windowScene: windowScene)
```

## API

### `DevConsole`

| Method | Description |
|--------|-------------|
| `.shared` | Singleton instance |
| `.show()` | Show the console |
| `.hide()` | Hide the console |
| `.toggle()` | Toggle visibility |
| `.registerCommand(_:description:handler:)` | Register a custom command |
| `.executeCommand(_:)` | Execute a command by name |
| `.availableCommands()` | List all command names |
| `.analytics` | Access the analytics store |
| `.executeAndRecord(_:)` | Execute a command and record in history |
| `.commandHistory()` | List previously executed commands |
| `.clearHistory()` | Clear command history |
| `.enableShakeToOpen()` | Enable shake gesture (iOS) |

### `LogStore`

| Method | Description |
|--------|-------------|
| `.debug(_:source:)` | Log at debug level |
| `.info(_:source:)` | Log at info level |
| `.warning(_:source:)` | Log at warning level |
| `.error(_:source:)` | Log at error level |
| `.all()` | Get all entries |
| `.filter(level:)` | Filter by severity |
| `.recent(_:)` | Get N most recent entries |
| `.search(_:)` | Search by message content |
| `.clear()` | Clear all entries |
| `.export()` | Export as formatted string |

### `NetworkMonitor`

| Method | Description |
|--------|-------------|
| `.record(_:)` | Record a network request |
| `.all()` | Get all records |
| `.filter(method:)` | Filter by HTTP method |
| `.errors()` | Get failed requests |
| `.search(_:)` | Search by URL |
| `.clear()` | Clear all records |
| `.averageDuration` | Average response time |

### `FeatureFlagStore`

| Method | Description |
|--------|-------------|
| `.register(_:default:)` | Register a flag with default value |
| `.isEnabled(_:)` | Check if flag is enabled |
| `.setOverride(_:enabled:)` | Override a flag value |
| `.removeOverride(_:)` | Revert to default |
| `.clearOverrides()` | Remove all overrides |
| `.allFlags()` | List all flags with status |

### `AnalyticsStore`

| Method | Description |
|--------|-------------|
| `.track(_:properties:)` | Track a named event |
| `.all()` | Get all events |
| `.events(named:)` | Filter by event name |
| `.events(from:to:)` | Filter by date range |
| `.summary()` | Unique event names with counts |
| `.clear()` | Clear all events |
| `.count` | Number of tracked events |
| `.export()` | Export as formatted string |

### `EnvironmentManager`

| Method | Description |
|--------|-------------|
| `.register(_:config:)` | Register a named environment |
| `.switchTo(_:)` | Switch active environment |
| `.current` | Current environment name |
| `.currentConfig` | Current environment config |
| `.value(for:)` | Get a config value |
| `.allEnvironments()` | List environment names |

## Development

```bash
swift build
swift test
```

## Support

If you find this project useful:

⭐ [Star the repo](https://github.com/philiprehberger/swift-dev-console)

🐛 [Report issues](https://github.com/philiprehberger/swift-dev-console/issues?q=is%3Aissue+is%3Aopen+label%3Abug)

💡 [Suggest features](https://github.com/philiprehberger/swift-dev-console/issues?q=is%3Aissue+is%3Aopen+label%3Aenhancement)

❤️ [Sponsor development](https://github.com/sponsors/philiprehberger)

🌐 [All Open Source Projects](https://philiprehberger.com/open-source-packages)

💻 [GitHub Profile](https://github.com/philiprehberger)

🔗 [LinkedIn Profile](https://www.linkedin.com/in/philiprehberger)

## License

[MIT](LICENSE)
