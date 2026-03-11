import Foundation
import CoreLocation

/// Lightweight, Codable representation of a turn-by-turn step (derived from MapKit `MKRoute.Step`).
///
/// We persist only what we need for the MVP UI + re-routing:
/// - instruction text
/// - step distance
/// - maneuver coordinate (end of step polyline)
struct NavigationStep: Identifiable, Codable, Hashable {
    let id: UUID
    let instruction: String
    let distanceMeters: Double
    let latitude: Double
    let longitude: Double

    init(
        id: UUID = UUID(),
        instruction: String,
        distanceMeters: Double,
        coordinate: CLLocationCoordinate2D
    ) {
        self.id = id
        self.instruction = instruction
        self.distanceMeters = distanceMeters
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
    }

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
