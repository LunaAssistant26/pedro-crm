import Foundation
import CoreLocation
import UIKit

/// Represents a photo taken during a walk, associated with a specific location
struct RoutePhoto: Identifiable, Codable {
    let id: UUID
    let routeId: UUID
    let timestamp: Date
    let latitude: Double
    let longitude: Double
    let filename: String
    let note: String?
    
    var location: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    /// Returns the full file URL for this photo in the app's documents directory.
    @MainActor
    func fileURL() -> URL {
        PhotoService.shared.photosDirectory.appendingPathComponent(filename)
    }
}

/// Extension to Route to support photos
extension Route {
    /// Returns the photos associated with this route from `PhotoService`.
    ///
    /// `PhotoService` is `@MainActor`, so accessing photos should be done from the main actor (e.g. SwiftUI views).
    @MainActor
    var photos: [RoutePhoto] {
        PhotoService.shared.photos(for: id)
    }
}
