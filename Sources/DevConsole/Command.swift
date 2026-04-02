import Foundation

/// A registered developer command.
public struct Command: Sendable {
    /// The command name.
    public let name: String

    /// A short description of what the command does.
    public let description: String

    /// The handler that executes the command and returns output.
    public let handler: @Sendable () -> String

    public init(name: String, description: String = "", handler: @escaping @Sendable () -> String) {
        self.name = name
        self.description = description
        self.handler = handler
    }
}
