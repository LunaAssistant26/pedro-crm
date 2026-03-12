import Foundation
import MapKit
import CoreLocation
import os.log

/// Generates loop-only walking routes (start == end) around a given coordinate for a time budget.
///
/// Notes (throttle-safe):
/// - Hard-bounds MKDirections requests to <= 12 per generation attempt (4 candidates * 3 legs).
/// - Iterative radius calibration: up to 2 retries if MKDirections times are way off target.
/// - Deterministic candidates (no random expansion) + no heavy task-group concurrency.
/// - Short-lived cache (30s) to avoid repeated calls for identical inputs.
/// - Supports cancellation by calling `MKDirections.cancel()` for in-flight requests.
actor RouteGenerationService {
    struct CacheKey: Hashable {
        let latE3: Int
        let lonE3: Int
        let minutes: Int
    }

    struct DirectionsUnavailableError: LocalizedError {
        var errorDescription: String? { "Directions are currently unavailable." }
    }

    private struct CacheEntry {
        let createdAt: Date
        let routes: [Route]
    }

    private let logger = Logger(subsystem: "com.walkingroutes", category: "RouteGenerationService")

    private var cache: [CacheKey: CacheEntry] = [:]
    private var inFlight: [UUID: MKDirections] = [:]

    private let cacheTTL: TimeInterval = 30

    func cancelInFlightRequests() {
        for (_, d) in inFlight { d.cancel() }
        inFlight.removeAll()
    }

    /// Generate up to 3 loop route options.
    func generateLoopRoutes(start: CLLocationCoordinate2D, minutes: Int, toleranceMinutes: Int = 15) async throws -> [Route] {
        if Task.isCancelled { throw CancellationError() }

        let key = cacheKey(for: start, minutes: minutes)
        if let entry = cache[key], Date().timeIntervalSince(entry.createdAt) <= cacheTTL {
            logger.log("Cache hit (<=\(Int(self.cacheTTL))s) latE3=\(key.latE3) lonE3=\(key.lonE3) minutes=\(minutes). routes=\(entry.routes.count)")
            return entry.routes
        }

        let startLocation = CLLocation(latitude: start.latitude, longitude: start.longitude)

        let targetSeconds = TimeInterval(minutes * 60)
        let toleranceSeconds = TimeInterval(toleranceMinutes * 60)

        // walkingSpeedMetersPerSecond seeds the initial radius estimate ONLY.
        // MKDirections expectedTravelTime is the source of truth for route duration.
        let walkingSpeedMetersPerSecond: CLLocationDistance = 4.8 * 1000.0 / 3600.0
        let distanceBudgetMeters = walkingSpeedMetersPerSecond * targetSeconds
        // Start conservative (0.20) — real walking routes are 1.4–1.8x straight-line due to
        // bridges, pedestrian paths, and canals. Iterative calibration adjusts below.
        var radiusMeters = max(220, distanceBudgetMeters * 0.20)

        struct Candidate: Sendable {
            let id: String
            let wp1: CLLocationCoordinate2D
            let wp2: CLLocationCoordinate2D
        }

        let bearingPairs: [(CLLocationDegrees, CLLocationDegrees)] = [
            (0, 120),
            (45, 165),
            (90, 210),
            (135, 255)
        ]

        var loops: [LoopResult] = []
        let maxRetries = 2
        var attempt = 0

        repeat {
            if Task.isCancelled { throw CancellationError() }

            let candidates: [Candidate] = bearingPairs.enumerated().map { idx, pair in
                let (b1, b2) = pair
                return Candidate(
                    id: "c\(idx)",
                    wp1: startLocation.coordinate(atDistanceMeters: radiusMeters, bearingDegrees: b1),
                    wp2: startLocation.coordinate(atDistanceMeters: radiusMeters, bearingDegrees: b2)
                )
            }

            logger.log("Attempt \(attempt + 1): minutes=\(minutes), budget=\(Int(distanceBudgetMeters))m, radius=\(Int(radiusMeters))m")

            loops = []
            loops.reserveCapacity(candidates.count)

            for c in candidates {
                if Task.isCancelled { throw CancellationError() }
                do {
                    let loop = try await buildLoop(start: start, wp1: c.wp1, wp2: c.wp2)
                    loops.append(loop)
                } catch is CancellationError {
                    throw CancellationError()
                } catch {
                    logger.debug("Candidate \(c.id) failed: \(error.localizedDescription)")
                    continue
                }
            }

            attempt += 1

            // Stop if no results or we've exhausted retries.
            guard !loops.isEmpty, attempt <= maxRetries else { break }

            // Calibrate: check if all candidates are way off target.
            // Use median to be robust against outliers.
            let sortedTimes = loops.map { $0.expectedTravelTime }.sorted()
            let medianTime = sortedTimes[sortedTimes.count / 2]

            if loops.allSatisfy({ $0.expectedTravelTime < targetSeconds * 0.70 }) {
                radiusMeters *= 1.3
                logger.log("Calibration: median \(Int(medianTime / 60))min < 70% target, scaling radius up to \(Int(radiusMeters))m")
            } else if loops.allSatisfy({ $0.expectedTravelTime > targetSeconds * 1.30 }) {
                radiusMeters *= 0.75
                logger.log("Calibration: median \(Int(medianTime / 60))min > 130% target, scaling radius down to \(Int(radiusMeters))m")
            } else {
                break // radius is calibrated well enough
            }
        } while attempt <= maxRetries

        if loops.isEmpty { throw DirectionsUnavailableError() }

        let filtered = loops.filter { abs($0.expectedTravelTime - targetSeconds) <= toleranceSeconds }
        let pool = filtered.isEmpty ? loops : filtered

        let sorted = pool.sorted { abs($0.expectedTravelTime - targetSeconds) < abs($1.expectedTravelTime - targetSeconds) }
        let picked = Array(sorted.prefix(3))

        let routes: [Route] = picked.enumerated().map { index, loop in
            let distanceKm = loop.distanceMeters / 1000.0
            // Use MKDirections expectedTravelTime as source of truth for duration.
            let durationMin = Int(round(loop.expectedTravelTime / 60.0))

            return Route(
                id: UUID(),
                name: "Loop Option \(index + 1)",
                description: "A \(durationMin)-minute loop starting and ending where you are.",
                duration: durationMin,
                distance: distanceKm,
                difficulty: distanceKm < 4 ? .easy : (distanceKm < 7 ? .moderate : .challenging),
                category: .highlights,
                landmarks: [],
                coordinates: loop.polylineCoordinates.map { Location(latitude: $0.latitude, longitude: $0.longitude) },
                navigationSteps: loop.navigationSteps,
                imageURL: nil,
                city: nil
            )
        }

        cache[key] = CacheEntry(createdAt: Date(), routes: routes)
        logger.log("Generated \(routes.count) routes after \(attempt) attempt(s)")
        return routes
    }

    // MARK: - Internals

    private struct LoopResult: Sendable {
        let distanceMeters: CLLocationDistance
        let expectedTravelTime: TimeInterval
        let polylineCoordinates: [CLLocationCoordinate2D]
        let navigationSteps: [NavigationStep]
    }

    private func cacheKey(for coordinate: CLLocationCoordinate2D, minutes: Int) -> CacheKey {
        CacheKey(
            latE3: Int((coordinate.latitude * 1000.0).rounded()),
            lonE3: Int((coordinate.longitude * 1000.0).rounded()),
            minutes: minutes
        )
    }

    private func buildLoop(start: CLLocationCoordinate2D, wp1: CLLocationCoordinate2D, wp2: CLLocationCoordinate2D) async throws -> LoopResult {
        if Task.isCancelled { throw CancellationError() }

        let leg1 = try await directions(from: start, to: wp1)
        if Task.isCancelled { throw CancellationError() }
        let leg2 = try await directions(from: wp1, to: wp2)
        if Task.isCancelled { throw CancellationError() }
        let leg3 = try await directions(from: wp2, to: start)
        if Task.isCancelled { throw CancellationError() }

        let distance = leg1.distance + leg2.distance + leg3.distance
        let time = leg1.expectedTravelTime + leg2.expectedTravelTime + leg3.expectedTravelTime
        let coords = leg1.polyline.coordinates + leg2.polyline.coordinates + leg3.polyline.coordinates

        let steps = (leg1.steps + leg2.steps + leg3.steps)
            .compactMap { NavigationStep.from(mapKitStep: $0) }

        return LoopResult(
            distanceMeters: distance,
            expectedTravelTime: time,
            polylineCoordinates: coords,
            navigationSteps: steps
        )
    }

    private func directions(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) async throws -> MKRoute {
        if Task.isCancelled { throw CancellationError() }

        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: from))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: to))
        request.transportType = .walking
        request.requestsAlternateRoutes = false

        let directions = MKDirections(request: request)
        let token = UUID()
        inFlight[token] = directions
        defer { inFlight[token] = nil }

        return try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { continuation in
                directions.calculate { response, error in
                    if let error {
                        continuation.resume(throwing: error)
                        return
                    }
                    guard let route = response?.routes.first else {
                        continuation.resume(throwing: NSError(domain: "RouteGenerationService", code: 1, userInfo: [NSLocalizedDescriptionKey: "No routes returned"]))
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

private extension CLLocation {
    /// Destination coordinate given distance and bearing (approximation on WGS84 sphere).
    func coordinate(atDistanceMeters distance: CLLocationDistance, bearingDegrees: CLLocationDegrees) -> CLLocationCoordinate2D {
        let distRadians = distance / 6_371_000.0
        let bearing = bearingDegrees * .pi / 180.0

        let lat1 = coordinate.latitude * .pi / 180.0
        let lon1 = coordinate.longitude * .pi / 180.0

        let lat2 = asin(sin(lat1) * cos(distRadians) + cos(lat1) * sin(distRadians) * cos(bearing))
        let lon2 = lon1 + atan2(
            sin(bearing) * sin(distRadians) * cos(lat1),
            cos(distRadians) - sin(lat1) * sin(lat2)
        )

        return CLLocationCoordinate2D(latitude: lat2 * 180.0 / .pi, longitude: lon2 * 180.0 / .pi)
    }
}

private extension MKPolyline {
    var coordinates: [CLLocationCoordinate2D] {
        var coords = Array(repeating: kCLLocationCoordinate2DInvalid, count: pointCount)
        getCoordinates(&coords, range: NSRange(location: 0, length: pointCount))
        return coords.filter { CLLocationCoordinate2DIsValid($0) }
    }
}
