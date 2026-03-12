import Foundation
import MapKit
import CoreLocation
import os.log

/// Generates loop-only walking routes (start == end) around a given coordinate for a time budget.
///
/// Design:
/// - 3 candidates × 3 legs = 9 MKDirections requests per attempt (fast).
/// - Triangle loops (start→wp1→wp2→start) minimize same-road backtracking.
/// - Throttle detection: if Apple returns GEOErrorDomain -3, waits for reset before retry.
/// - Iterative radius calibration: adjusts radius if routes are too short/long.
/// - Short-lived cache (10s) to skip redundant calls for same inputs.
actor RouteGenerationService {

    struct CacheKey: Hashable {
        let latE3: Int
        let lonE3: Int
        let minutes: Int
    }

    struct DirectionsUnavailableError: LocalizedError {
        var errorDescription: String? { "Directions are currently unavailable." }
    }

    private struct ThrottleError: Error {
        let waitSeconds: Double
    }

    private struct CacheEntry {
        let createdAt: Date
        let routes: [Route]
    }

    private let logger = Logger(subsystem: "com.walkingroutes", category: "RouteGenerationService")

    private var cache: [CacheKey: CacheEntry] = [:]
    private var inFlight: [UUID: MKDirections] = [:]

    private let cacheTTL: TimeInterval = 10

    func cancelInFlightRequests() {
        for (_, d) in inFlight { d.cancel() }
        inFlight.removeAll()
    }

    /// Generate up to 3 loop route options from `start` for the given `minutes` budget.
    func generateLoopRoutes(start: CLLocationCoordinate2D, minutes: Int, toleranceMinutes: Int = 15) async throws -> [Route] {
        if Task.isCancelled { throw CancellationError() }

        let key = cacheKey(for: start, minutes: minutes)
        if let entry = cache[key], Date().timeIntervalSince(entry.createdAt) <= cacheTTL {
            logger.log("Cache hit latE3=\(key.latE3) lonE3=\(key.lonE3) minutes=\(minutes)")
            return entry.routes
        }

        let startLocation = CLLocation(latitude: start.latitude, longitude: start.longitude)
        let targetSeconds = TimeInterval(minutes * 60)
        let toleranceSeconds = TimeInterval(toleranceMinutes * 60)

        // Seeds the initial radius only. MKDirections expectedTravelTime is source of truth.
        let seedSpeed: CLLocationDistance = 4.8 * 1000.0 / 3600.0
        let distanceBudgetMeters = seedSpeed * targetSeconds

        // Calibrated for 4-leg geometry on straight roads (factor ~1.2×):
        // r ≈ budget / (4.17 × 1.2) ≈ budget × 0.20. Works well for suburban/rural terrain.
        // Calibration loop handles winding terrain (Amsterdam canals etc) by scaling down if too long.
        var radiusMeters = max(200, distanceBudgetMeters * 0.20)

        // 3 candidates at 120° apart, each a 3-leg triangle loop.
        // Triangle: start → wp1(b°, r) → wp2(b+120°, r) → start
        // 3 candidates × 3 legs = 9 requests (25% faster than 4-leg).
        struct Candidate: Sendable {
            let id: String
            let wp1: CLLocationCoordinate2D
            let wp2: CLLocationCoordinate2D
        }

        func makeCandidates(radius: CLLocationDistance) -> [Candidate] {
            [(0.0, "A"), (120.0, "B"), (240.0, "C")].map { (offset, id) in
                Candidate(
                    id: id,
                    wp1: startLocation.coordinate(atDistanceMeters: radius, bearingDegrees: offset),
                    wp2: startLocation.coordinate(atDistanceMeters: radius, bearingDegrees: offset + 120)
                )
            }
        }

        var loops: [LoopResult] = []
        let maxAttempts = 3
        var attempt = 0

        while attempt < maxAttempts {
            if Task.isCancelled { throw CancellationError() }

            let candidates = makeCandidates(radius: radiusMeters)
            logger.log("Attempt \(attempt + 1)/\(maxAttempts): radius=\(Int(radiusMeters))m target=\(minutes)min")

            loops = []
            var throttleWait: Double = 0

            for c in candidates {
                if Task.isCancelled { throw CancellationError() }
                do {
                    let loop = try await buildLoop(start: start, wp1: c.wp1, wpMid: c.wpMid, wp2: c.wp2)
                    loops.append(loop)
                } catch is CancellationError {
                    throw CancellationError()
                } catch let throttle as ThrottleError {
                    // Throttled by Apple. Record the wait time and stop this attempt.
                    throttleWait = max(throttleWait, throttle.waitSeconds)
                    logger.warning("Throttled on candidate \(c.id). Will wait \(Int(throttle.waitSeconds))s before retry.")
                    break
                } catch {
                    logger.debug("Candidate \(c.id) failed: \(error.localizedDescription)")
                }
            }

            attempt += 1

            // If throttled, wait for Apple's rate limit reset, then retry.
            if throttleWait > 0 {
                let waitNs = UInt64((throttleWait + 2.0) * 1_000_000_000)
                logger.log("Waiting \(Int(throttleWait + 2))s for rate limit reset…")
                try await Task.sleep(nanoseconds: waitNs)
                // Reset radius (start fresh after throttle).
                radiusMeters = max(200, distanceBudgetMeters * 0.20)
                continue
            }

            guard !loops.isEmpty else {
                // All candidates failed (no pedestrian paths at this radius) — give up.
                break
            }

            // Calibrate radius based on actual MKDirections times.
            let sortedTimes = loops.map { $0.expectedTravelTime }.sorted()
            let medianTime = sortedTimes[sortedTimes.count / 2]
            let ratio = medianTime / targetSeconds
            logger.log("Median: \(Int(medianTime / 60))min (ratio=\(String(format: "%.2f", ratio)))")

            if ratio < 0.70 && attempt < maxAttempts {
                radiusMeters *= 1.3
                logger.log("Too short → scaling radius up to \(Int(radiusMeters))m")
            } else if ratio > 1.30 && attempt < maxAttempts {
                radiusMeters *= 0.75
                logger.log("Too long → scaling radius down to \(Int(radiusMeters))m")
            } else {
                break // Good enough.
            }
        }

        if loops.isEmpty { throw DirectionsUnavailableError() }

        // Pick up to 3 best routes. Prefer those within tolerance; fall back to all if fewer than 3.
        let filtered = loops.filter { abs($0.expectedTravelTime - targetSeconds) <= toleranceSeconds }
        let pool = filtered.count >= 3 ? filtered : loops
        let picked = pool
            .sorted { abs($0.expectedTravelTime - targetSeconds) < abs($1.expectedTravelTime - targetSeconds) }
            .prefix(3)

        let routes: [Route] = picked.enumerated().map { index, loop in
            let distanceKm = loop.distanceMeters / 1000.0
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
        logger.log("Done: \(routes.count) routes after \(attempt) attempt(s)")
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

    /// Build a 3-leg triangle loop: start → wp1 → wp2 → start.
    private func buildLoop(start: CLLocationCoordinate2D,
                           wp1: CLLocationCoordinate2D,
                           wp2: CLLocationCoordinate2D) async throws -> LoopResult {
        if Task.isCancelled { throw CancellationError() }
        let leg1 = try await directions(from: start, to: wp1)
        if Task.isCancelled { throw CancellationError() }
        let leg2 = try await directions(from: wp1,   to: wp2)
        if Task.isCancelled { throw CancellationError() }
        let leg3 = try await directions(from: wp2,   to: start)

        let distance = leg1.distance + leg2.distance + leg3.distance
        let time     = leg1.expectedTravelTime + leg2.expectedTravelTime + leg3.expectedTravelTime
        let coords   = leg1.polyline.coordinates + leg2.polyline.coordinates + leg3.polyline.coordinates
        let steps    = (leg1.steps + leg2.steps + leg3.steps).compactMap { NavigationStep.from(mapKitStep: $0) }

        return LoopResult(distanceMeters: distance, expectedTravelTime: time,
                          polylineCoordinates: coords, navigationSteps: steps)
    }

    private func directions(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) async throws -> MKRoute {
        if Task.isCancelled { throw CancellationError() }

        let request = MKDirections.Request()
        request.source      = MKMapItem(placemark: MKPlacemark(coordinate: from))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: to))
        request.transportType = .walking
        request.requestsAlternateRoutes = false

        let dir = MKDirections(request: request)
        let token = UUID()
        inFlight[token] = dir
        defer { inFlight[token] = nil }

        return try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { continuation in
                dir.calculate { response, error in
                    if let error {
                        // Detect Apple's MKDirections rate-limit (GEOErrorDomain Code=-3).
                        let ns = error as NSError
                        if ns.domain == "GEOErrorDomain" && ns.code == -3 {
                            var wait: Double = 32
                            // NSDictionary doesn't bridge cleanly to [String:Any] — cast via NSDictionary.
                            let rawDetails = ns.userInfo["details"]
                            let details = (rawDetails as? NSDictionary) ?? (rawDetails as? [AnyHashable: Any]).map { NSDictionary(dictionary: $0) }
                            if let reset = (details?["timeUntilReset"] as? NSNumber)?.doubleValue {
                                wait = reset
                            }
                            continuation.resume(throwing: ThrottleError(waitSeconds: wait))
                        } else {
                            continuation.resume(throwing: error)
                        }
                        return
                    }
                    guard let route = response?.routes.first else {
                        continuation.resume(throwing: NSError(domain: "RouteGenerationService", code: 1,
                            userInfo: [NSLocalizedDescriptionKey: "No routes returned"]))
                        return
                    }
                    continuation.resume(returning: route)
                }
            }
        } onCancel: {
            dir.cancel()
        }
    }
}

// MARK: - CLLocation helpers

private extension CLLocation {
    func coordinate(atDistanceMeters distance: CLLocationDistance, bearingDegrees: CLLocationDegrees) -> CLLocationCoordinate2D {
        let distRadians = distance / 6_371_000.0
        let bearing = bearingDegrees * .pi / 180.0
        let lat1 = coordinate.latitude  * .pi / 180.0
        let lon1 = coordinate.longitude * .pi / 180.0
        let lat2 = asin(sin(lat1) * cos(distRadians) + cos(lat1) * sin(distRadians) * cos(bearing))
        let lon2 = lon1 + atan2(sin(bearing) * sin(distRadians) * cos(lat1),
                                cos(distRadians) - sin(lat1) * sin(lat2))
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
