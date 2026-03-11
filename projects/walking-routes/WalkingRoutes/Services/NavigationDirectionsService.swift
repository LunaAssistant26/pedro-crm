import Foundation
import MapKit
import CoreLocation
import os.log

/// Computes (and caches) turn-by-turn steps for a `Route`.
///
/// MVP constraints:
/// - Avoid excessive MKDirections calls (rate limits) by caching per route id.
/// - Use a small number of legs by simplifying waypoints.
actor NavigationDirectionsService {
    static let shared = NavigationDirectionsService()

    private let logger = Logger(subsystem: "com.walkingroutes", category: "NavigationDirectionsService")

    private struct CacheEntry {
        let createdAt: Date
        let steps: [NavigationStep]
    }

    private var cache: [UUID: CacheEntry] = [:]
    private let cacheTTL: TimeInterval = 60 * 30 // 30 minutes

    /// Get steps for a route, using persisted steps when present; otherwise computes a simplified set.
    func steps(for route: Route) async throws -> [NavigationStep] {
        if let persisted = route.navigationSteps, !persisted.isEmpty {
            return persisted
        }

        if let cached = cache[route.id], Date().timeIntervalSince(cached.createdAt) <= cacheTTL {
            logger.debug("Steps cache hit routeId=\(route.id.uuidString, privacy: .public) steps=\(cached.steps.count)")
            return cached.steps
        }

        let coords = route.pathCoordinates
        let waypoints = simplifyWaypoints(for: coords)
        guard waypoints.count >= 2 else { return [] }

        var all: [NavigationStep] = []
        all.reserveCapacity(64)

        for i in 0..<(waypoints.count - 1) {
            let leg = try await directions(from: waypoints[i], to: waypoints[i + 1])
            let legSteps = leg.steps.compactMap { NavigationStep.from(mapKitStep: $0) }
            all.append(contentsOf: legSteps)
        }

        // De-dupe identical consecutive instructions (MapKit sometimes repeats across legs)
        let collapsed = all.reduce(into: [NavigationStep]()) { acc, step in
            if acc.last?.instruction == step.instruction { return }
            acc.append(step)
        }

        cache[route.id] = CacheEntry(createdAt: Date(), steps: collapsed)
        logger.log("Computed steps routeId=\(route.id.uuidString, privacy: .public) legs=\(waypoints.count - 1) steps=\(collapsed.count)")
        return collapsed
    }

    /// Simple re-route: from current coordinate to a target coordinate.
    func reroute(from current: CLLocationCoordinate2D, to target: CLLocationCoordinate2D) async throws -> [NavigationStep] {
        let leg = try await directions(from: current, to: target)
        return leg.steps.compactMap { NavigationStep.from(mapKitStep: $0) }
    }

    // MARK: - Internals

    private func simplifyWaypoints(for coords: [CLLocationCoordinate2D]) -> [CLLocationCoordinate2D] {
        guard coords.count >= 2 else { return coords }

        // Prefer landmarks for demo routes (fewer legs, more meaningful turns).
        // If coords are already small, just use them.
        let maxPoints = 6 // => max 5 MKDirections calls

        if coords.count <= maxPoints {
            return ensureNoDuplicateConsecutive(coords)
        }

        // If it's a loop (start ~= end), sample around the polyline.
        let first = coords.first!
        let last = coords.last!
        let loop = CLLocation(latitude: first.latitude, longitude: first.longitude)
            .distance(from: CLLocation(latitude: last.latitude, longitude: last.longitude)) < 25

        if loop {
            // Pick 4 evenly spaced points + close the loop.
            let idxs = [0, coords.count / 4, coords.count / 2, (coords.count * 3) / 4, coords.count - 1]
            let sampled = idxs.map { coords[min(max($0, 0), coords.count - 1)] }
            return ensureNoDuplicateConsecutive(sampled)
        }

        // Non-loop: pick endpoints + a few midpoints.
        let idxs = [0, coords.count / 3, (coords.count * 2) / 3, coords.count - 1]
        let sampled = idxs.map { coords[min(max($0, 0), coords.count - 1)] }
        return ensureNoDuplicateConsecutive(sampled)
    }

    private func ensureNoDuplicateConsecutive(_ coords: [CLLocationCoordinate2D]) -> [CLLocationCoordinate2D] {
        coords.enumerated().compactMap { idx, c in
            if idx > 0 {
                let prev = coords[idx - 1]
                if abs(prev.latitude - c.latitude) < 0.0000001 && abs(prev.longitude - c.longitude) < 0.0000001 {
                    return nil
                }
            }
            return c
        }
    }

    private func directions(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) async throws -> MKRoute {
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: from))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: to))
        request.transportType = .walking
        request.requestsAlternateRoutes = false

        let directions = MKDirections(request: request)
        return try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { continuation in
                directions.calculate { response, error in
                    if let error {
                        continuation.resume(throwing: error)
                        return
                    }
                    guard let route = response?.routes.first else {
                        continuation.resume(throwing: NSError(domain: "NavigationDirectionsService", code: 1, userInfo: [NSLocalizedDescriptionKey: "No routes returned"]))
                        return
                    }
                    continuation.resume(returning: route)
                }
            }
        } onCancel: {
            directions.cancel()
        }
    }
}
