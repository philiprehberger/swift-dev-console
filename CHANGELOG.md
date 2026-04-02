# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0] - 2026-04-02

### Added
- `DevConsole` singleton with show/hide/toggle
- `LogStore` with severity levels, search, filtering, export, and max capacity
- `NetworkMonitor` for recording HTTP request/response pairs with search and stats
- `FeatureFlagStore` with default values and runtime overrides
- `EnvironmentManager` for named environment switching with key-value config
- Custom command registration and execution via `registerCommand` / `executeCommand`
- Shake-to-open support on iOS via `ShakeDetectingWindow`
- Thread-safe storage across all components
- Zero external dependencies
