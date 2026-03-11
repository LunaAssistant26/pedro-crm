import Foundation

/// Lightweight demo route for SwiftUI previews.
enum DemoRoute {
    static var loop: Route {
        let coords: [Location] = [
            Location(latitude: 52.3780, longitude: 4.9006),
            Location(latitude: 52.3810, longitude: 4.9100),
            Location(latitude: 52.3720, longitude: 4.9150),
            Location(latitude: 52.3780, longitude: 4.9006)
        ]

        return Route(
            id: UUID(),
            name: "Preview Loop",
            description: "A simple loop route used for previews.",
            duration: 60,
            distance: 4.8,
            difficulty: .easy,
            category: .highlights,
            landmarks: Array(PointsOfInterest.all.prefix(2)),
            coordinates: coords,
            navigationSteps: nil,
            imageURL: nil,
            city: nil
        )
    }
}
