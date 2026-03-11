import Foundation
import CoreLocation

enum PolylineMath {
    /// Returns the distance (meters) from `point` to the polyline described by `coordinates`.
    /// Uses a local equirectangular projection (good enough for short walking routes).
    static func distanceMeters(from point: CLLocationCoordinate2D, toPolyline coordinates: [CLLocationCoordinate2D]) -> CLLocationDistance? {
        guard coordinates.count >= 2 else { return nil }
        let origin = point
        let p = project(point, origin: origin)

        var best = Double.greatestFiniteMagnitude
        for i in 0..<(coordinates.count - 1) {
            let a = project(coordinates[i], origin: origin)
            let b = project(coordinates[i + 1], origin: origin)
            let d = distancePointToSegment(p: p, a: a, b: b)
            best = min(best, d)
        }
        return best
    }

    /// Returns the nearest coordinate on the polyline to `point` (approx; snapped to segment).
    static func nearestPoint(onPolyline coordinates: [CLLocationCoordinate2D], to point: CLLocationCoordinate2D) -> CLLocationCoordinate2D? {
        guard coordinates.count >= 2 else { return nil }
        let origin = point
        let p = project(point, origin: origin)

        var bestDist = Double.greatestFiniteMagnitude
        var bestXY: (Double, Double)?

        for i in 0..<(coordinates.count - 1) {
            let a = project(coordinates[i], origin: origin)
            let b = project(coordinates[i + 1], origin: origin)
            let (closest, dist) = closestPointOnSegment(p: p, a: a, b: b)
            if dist < bestDist {
                bestDist = dist
                bestXY = closest
            }
        }

        guard let xy = bestXY else { return nil }
        return unproject(xy, origin: origin)
    }

    // MARK: - Projection helpers

    /// Project lat/lon to local meters using equirectangular approximation.
    private static func project(_ c: CLLocationCoordinate2D, origin: CLLocationCoordinate2D) -> (Double, Double) {
        let earthRadius = 6_371_000.0
        let lat0 = origin.latitude * .pi / 180.0
        let x = (c.longitude - origin.longitude) * .pi / 180.0 * earthRadius * cos(lat0)
        let y = (c.latitude - origin.latitude) * .pi / 180.0 * earthRadius
        return (x, y)
    }

    private static func unproject(_ xy: (Double, Double), origin: CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        let earthRadius = 6_371_000.0
        let lat0 = origin.latitude * .pi / 180.0
        let dLon = (xy.0 / (earthRadius * cos(lat0))) * 180.0 / .pi
        let dLat = (xy.1 / earthRadius) * 180.0 / .pi
        return CLLocationCoordinate2D(latitude: origin.latitude + dLat, longitude: origin.longitude + dLon)
    }

    private static func distancePointToSegment(p: (Double, Double), a: (Double, Double), b: (Double, Double)) -> Double {
        closestPointOnSegment(p: p, a: a, b: b).1
    }

    private static func closestPointOnSegment(p: (Double, Double), a: (Double, Double), b: (Double, Double)) -> ((Double, Double), Double) {
        let (px, py) = p
        let (ax, ay) = a
        let (bx, by) = b

        let abx = bx - ax
        let aby = by - ay
        let apx = px - ax
        let apy = py - ay

        let abLen2 = abx * abx + aby * aby
        if abLen2 == 0 {
            let d = hypot(px - ax, py - ay)
            return ((ax, ay), d)
        }

        var t = (apx * abx + apy * aby) / abLen2
        t = min(1, max(0, t))

        let cx = ax + t * abx
        let cy = ay + t * aby

        let d = hypot(px - cx, py - cy)
        return ((cx, cy), d)
    }
}
