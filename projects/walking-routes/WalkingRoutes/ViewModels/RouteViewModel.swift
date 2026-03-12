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

    private struct RecentKey: Hashable {
        let latE3: Int
        let lonE3: Int
        let minutes: Int
    }

    private var lastGenerated: (key: RecentKey, at: Date)?

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
        Task { [generationService] in await generationService.cancelInFlightRequests() }

        let forceDemo = UserDefaults.standard.bool(forKey: "forceDemoLocation")

        let start: CLLocationCoordinate2D
        if !forceDemo, locationAuthorized, let userCoordinate {
            usingDemoLocation = false
            start = userCoordinate
        } else {
            usingDemoLocation = true
            start = Self.demoStart
        }

        // Clear any previous error but keep last successful routes on screen.
        errorMessage = nil
        isLoading = false

        debounceTask = Task { [weak self] in
            // Wait until the user stops changing the slider for a moment.
            try? await Task.sleep(nanoseconds: 2_000_000_000) // 2s — wait until user stops sliding before firing
            guard !Task.isCancelled else { return }
            await self?.performGeneration(start: start, minutes: timeMinutes)
        }
    }

    private func performGeneration(start: CLLocationCoordinate2D, minutes: Int) async {
        let key = RecentKey(
            latE3: Int((start.latitude * 1000.0).rounded()),
            lonE3: Int((start.longitude * 1000.0).rounded()),
            minutes: minutes
        )

        if let last = lastGenerated,
           last.key == key,
           Date().timeIntervalSince(last.at) <= 30,
           !routes.isEmpty {
            logger.debug("Skipping regeneration (same start+minutes within 30s)")
            return
        }

        // Guard: if this task was cancelled before we even started (rapid slider), bail early.
        guard !Task.isCancelled else { return }
        isLoading = true

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
                        return Route(
                            id: route.id,
                            name: route.name,
                            description: "Nice walk — a loop that starts and ends at the same spot.",
                            duration: route.duration,
                            distance: route.distance,
                            difficulty: route.difficulty,
                            category: route.category,
                            landmarks: [],
                            coordinates: route.coordinates,
                            navigationSteps: route.navigationSteps,
                            imageURL: route.imageURL,
                            city: route.city
                        )
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
                    self.lastGenerated = (key: key, at: Date())
                    self.isLoading = false
                    self.errorMessage = nil
                }
                self.logger.log("Generated routes: \(enriched.count)")
            } catch is CancellationError {
                await MainActor.run {
                    self.isLoading = false
                }
                await self.generationService.cancelInFlightRequests()
                self.logger.debug("Route generation cancelled")
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
