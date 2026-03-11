import Foundation
import MapKit
import CoreLocation

extension NavigationStep {
    static func from(mapKitStep step: MKRoute.Step) -> NavigationStep? {
        let trimmed = step.instructions.trimmingCharacters(in: .whitespacesAndNewlines)
        // MapKit includes empty / non-action steps; keep only meaningful ones.
        guard !trimmed.isEmpty else { return nil }

        let coord = step.polyline.lastCoordinate ?? step.polyline.firstCoordinate
        guard let coordinate = coord else { return nil }

        return NavigationStep(
            instruction: trimmed,
            distanceMeters: step.distance,
            coordinate: coordinate
        )
    }
}

private extension MKPolyline {
    var firstCoordinate: CLLocationCoordinate2D? {
        guard pointCount > 0 else { return nil }
        var c = kCLLocationCoordinate2DInvalid
        getCoordinates(&c, range: NSRange(location: 0, length: 1))
        return CLLocationCoordinate2DIsValid(c) ? c : nil
    }

    var lastCoordinate: CLLocationCoordinate2D? {
        guard pointCount > 0 else { return nil }
        var c = kCLLocationCoordinate2DInvalid
        getCoordinates(&c, range: NSRange(location: pointCount - 1, length: 1))
        return CLLocationCoordinate2DIsValid(c) ? c : nil
    }
}
