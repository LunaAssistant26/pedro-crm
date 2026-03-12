import Foundation

/// Lightweight feature flags / toggles backed by UserDefaults.
///
/// Defaults:
/// - Real GPS navigation is OFF (demo mode) unless explicitly enabled.
enum AppFlags {
    /// When true, the navigation screen will attempt to use live GPS.
    /// When false (default), navigation runs in demo mode without requesting location permission.
    static let useRealGPSNavigationKey = "useRealGPSNavigation"

    static var useRealGPSNavigation: Bool {
        // Default true — always use real GPS for navigation.
        // Only falls back to demo if explicitly set false (e.g. for screenshot captures).
        let stored = UserDefaults.standard.object(forKey: useRealGPSNavigationKey)
        return stored == nil ? true : UserDefaults.standard.bool(forKey: useRealGPSNavigationKey)
    }
}
