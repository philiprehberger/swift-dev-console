#if canImport(UIKit)
import UIKit

/// Detects device shake gestures to trigger the console.
@MainActor
public final class ShakeDetector {
    public static let shared = ShakeDetector()

    /// Called when a shake is detected.
    public var onShake: (() -> Void)?

    /// Whether shake detection is enabled.
    public var isEnabled = false

    private init() {}

    /// Call this from your UIWindow subclass or motion handler.
    public func handleShake() {
        guard isEnabled else { return }
        onShake?()
    }
}

/// UIWindow subclass that detects shake gestures.
open class ShakeDetectingWindow: UIWindow {
    override open func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        super.motionEnded(motion, with: event)
        if motion == .motionShake {
            ShakeDetector.shared.handleShake()
        }
    }
}
#endif
