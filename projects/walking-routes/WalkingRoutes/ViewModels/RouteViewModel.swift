import Foundation
import CoreLocation
import MapKit
import os.log

@MainActor
final class RouteViewModel: ObservableObject {
    @Published private(set) var routes: [Route] = []
    @Published private(set) var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var usingDemoLocation: Bool = false

    private let logger = Logger(subsystem: "com.walkingroutes", category: "RouteViewModel")
    private let generationService = RouteGenerationService()

    private var generationTask: Task<Void, Never>?
    private var debounceTask: Task<Void, Never>?
    private var lastStart: CLLocationCoordinate2D?

    /// Demo-only fallback if location isn't available.
    static let demoStart = CLLocationCoordinate2D(latitude: 52.3780, longitude: 4.9006) // Amsterdam Centraal

    deinit {
        debounceTask?.cancel()
        generationTask?.cancel()
        Task { [generationService] in await generationService.cancelInFlightRequests() }
    }

    func generateRoutes(timeMinutes: Int, userCoordinate: CLLocationCoordinate2D?, locationAuthorized: Bool) {
        // Debounce rapid slider/location changes to avoid MKDirections throttling.
        debounceTask?.cancel()
        generationTask?.cancel()
        // Note: do NOT fire cancelInFlightRequests() here — it races with the new debounceTask's
        // generation that starts 2s later, cancelling the new requests. Task cancellation above is sufficient.

        let forceDemo = UserDefaults.standard.bool(forKey: "forceDemoLocation")

        let start: CLLocationCoordinate2D
        if !forceDemo, locationAuthorized, let userCoordinate {
            usingDemoLocation = false
            start = userCoordinate
        } else if forceDemo {
            usingDemoLocation = true
            start = Self.demoStart
        } else {
            // Location authorized but no fix yet — wait, don't fall back to Amsterdam.
            isLoading = false
            return
        }

        // Clear stale routes if start location shifted significantly (e.g. demo→real GPS).
        if let lastStart = lastStart {
            let prev = CLLocation(latitude: lastStart.latitude, longitude: lastStart.longitude)
            let next = CLLocation(latitude: start.latitude, longitude: start.longitude)
            if next.distance(from: prev) > 200 { routes = [] }
        }
        lastStart = start

        errorMessage = nil
        isLoading = true  // Show spinner immediately so user knows a generation is queued

        debounceTask = Task { [weak self] in
            // Wait until the user stops changing the slider for a moment.
            try? await Task.sleep(nanoseconds: 2_000_000_000) // 2s — wait until user stops sliding before firing
            guard !Task.isCancelled else { return }
            await self?.performGeneration(start: start, minutes: timeMinutes)
        }
    }

    private func performGeneration(start: CLLocationCoordinate2D, minutes: Int) async {
        // Guard: if this task was cancelled before we even started (rapid slider), bail early.
        guard !Task.isCancelled else { return }

        generationTask = Task { [weak self] in
            guard let self else { return }

            do {
                let generated = try await generationService.generateLoopRoutes(start: start, minutes: minutes)
                if Task.isCancelled { return }

                // Attach optional POIs near route geometry.
                let enriched: [Route] = generated.map { route in
                    let coords = route.pathCoordinates
                    let pois = PointsOfInterest.landmarks(near: coords)

                    if pois.isEmpty {
                        return route   // keep the generated description as-is
                    }

                    let highlightName = pois.first?.name
                    let labeledName = highlightName.map { "\(route.name) • Highlights: \($0)" } ?? route.name

                    return Route(
                        id: route.id,
                        name: labeledName,
                        description: route.description,
                        duration: route.duration,
                        distance: route.distance,
                        difficulty: route.difficulty,
                        category: route.category,
                        landmarks: pois,
                        coordinates: route.coordinates,
                        navigationSteps: route.navigationSteps,
                        imageURL: route.imageURL,
                        city: route.city
                    )
                }

                await MainActor.run {
                    self.routes = enriched
                    self.isLoading = false
                    self.errorMessage = nil
                }
                self.logger.log("Generated routes: \(enriched.count)")
            } catch is CancellationError {
                // Don't set isLoading = false here — if we're cancelled, a new generation
                // is starting and will set isLoading appropriately. Setting it false here
                // creates a race where the cancelled task overwrites the new task's isLoading = true.
                // Do NOT call cancelInFlightRequests() here — generateRoutes() already fires that
                // as a separate task, and calling it again here races with the new generation's requests.
                self.logger.debug("Route generation cancelled")
            } catch let throttle as RouteGenerationService.ThrottleError {
                let waitSecs = Int(ceil(throttle.waitSeconds)) + 2

                await MainActor.run {
                    self.isLoading = false
                    self.errorMessage = "⏳ Rate limited by Apple Maps. Auto-retrying in \(waitSecs)s…"
                }

                try? await Task.sleep(nanoseconds: UInt64(Double(waitSecs) * 1_000_000_000))
                guard !Task.isCancelled else { return }
                await self.performGeneration(start: start, minutes: minutes)
            } catch {
                await MainActor.run {
                    self.isLoading = false
                    // Keep last successful routes; just surface a message.
                    self.errorMessage = "Directions not available right now. Please try again in a moment."
                }
                self.logger.error("Route generation failed: \(error.localizedDescription)")
            }
        }
    }
}
