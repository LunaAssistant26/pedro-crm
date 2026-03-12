import SwiftUI

/// Feature flags backed by UserDefaults.
enum AppFlags {
    static let useRealGPSNavigationKey = "useRealGPSNavigation"

    /// Always true by default — navigation uses real GPS.
    /// Set to false only for screenshot/preview captures.
    static var useRealGPSNavigation: Bool {
        let stored = UserDefaults.standard.object(forKey: useRealGPSNavigationKey)
        return stored == nil ? true : UserDefaults.standard.bool(forKey: useRealGPSNavigationKey)
    }
}

@main
struct WalkingRoutesApp: App {
    var body: some Scene {
        WindowGroup {
            // CaptureRootView lives in Views/CaptureViews.swift
            CaptureRootView()
                .preferredColorScheme(.light)
        }
    }
}

