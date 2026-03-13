import Foundation
import CoreLocation
import Combine
import UIKit

@MainActor
final class RouteNavigationViewModel: ObservableObject {
    @Published private(set) var steps: [NavigationStep] = []
    @Published private(set) var currentStepIndex: Int = 0
    @Published private(set) var distanceToNextManeuverMeters: CLLocationDistance?

    @Published private(set) var isDemoMode: Bool = false

    @Published var isOffRoute: Bool = false
    @Published var offRouteDistanceMeters: CLLocationDistance?
    @Published var isRerouting: Bool = false

    private let route: Route
    private let offRouteThresholdMeters: CLLocationDistance = 30   // dense city streets — tight threshold
    private let offRouteHoldSeconds: TimeInterval = 3
    private let stepAdvanceThresholdMeters: CLLocationDistance = 25

    // No-progress detection: prompt reroute if no step advances for this long
    private let noProgressTimeoutSeconds: TimeInterval = 90
    @Published var showReroutePrompt: Bool = false
    private var lastStepAdvanceTime: Date = Date()
    private let rerouteCooldownSeconds: TimeInterval = 60

    private var offRouteSince: Date?
    private var lastRerouteAt: Date?

    private var demoAdvanceTask: Task<Void, Never>?

    // Direction detection — checked once after user walks ~50m from start
    private var directionChecked = false
    private var lastKnownCoord: CLLocationCoordinate2D?
    private var distanceTraveled: CLLocationDistance = 0

    init(route: Route) {
        self.route = route
    }

    deinit {
        demoAdvanceTask?.cancel()
    }

    var progressText: String {
        let total = max(steps.count, 1)
        return "\(min(currentStepIndex + 1, total)) / \(total)"
    }

    var isAtLastStep: Bool {
        guard !steps.isEmpty else { return false }
        return currentStepIndex >= steps.count - 1
    }

    var currentInstruction: String {
        guard steps.indices.contains(currentStepIndex) else { return "Starting…" }
        return steps[currentStepIndex].instruction
    }

    var nextManeuverCoordinate: CLLocationCoordinate2D? {
        guard steps.indices.contains(currentStepIndex) else { return nil }
        return steps[currentStepIndex].coordinate
    }

    func loadStepsIfNeeded() {
        guard steps.isEmpty else { return }

        // Use steps already embedded in the route (captured during generation) — avoids
        // burning MKDirections quota on navigation when we already have all the steps we need.
        if let persisted = route.navigationSteps, !persisted.isEmpty {
            steps = persisted
            currentStepIndex = 0
            if isDemoMode { startDemoAutoAdvanceIfPossible() }
            return
        }

        // Fallback: compute via NavigationDirectionsService (only if route has no persisted steps).
        // Race against a 3-second timeout so the UI never hangs forever if the service stalls.
        Task {
            do {
                let computed = try await withThrowingTaskGroup(of: [NavigationStep].self) { group in
                    group.addTask { try await NavigationDirectionsService.shared.steps(for: self.route) }
                    group.addTask {
                        try await Task.sleep(nanoseconds: 3_000_000_000)
                        throw CancellationError()   // timeout — fall through to catch
                    }
                    defer { group.cancelAll() }
                    guard let result = try await group.next() else { throw CancellationError() }
                    return result
                }
                self.steps = computed
                self.currentStepIndex = 0
                if self.isDemoMode {
                    self.startDemoAutoAdvanceIfPossible()
                }
            } catch {
                // NavigationDirectionsService failed or timed out — fall back to persisted steps.
                let fallback = route.navigationSteps ?? []
                self.steps = fallback
                if self.isDemoMode && !fallback.isEmpty {
                    self.startDemoAutoAdvanceIfPossible()
                }
            }
        }
    }

    func handleLocationUpdate(_ user: CLLocationCoordinate2D) {
        guard !isDemoMode else { return }
        checkWalkingDirection(user: user)
        updateDistanceToNext(user: user)
        advanceStepIfNeeded(user: user)
        updateOffRoute(user: user)
        checkNoProgress()
    }

    private func checkNoProgress() {
        guard !isAtLastStep, !isRerouting else { return }
        let stuck = Date().timeIntervalSince(lastStepAdvanceTime) >= noProgressTimeoutSeconds
        if stuck && !showReroutePrompt {
            showReroutePrompt = true
        }
    }

    /// Call this any time the user manually requests a reroute.
    func manualReroute(from user: CLLocationCoordinate2D) {
        showReroutePrompt = false
        lastStepAdvanceTime = Date()
        reroute(from: user)
    }

    /// After ~80m of walking, check if user is heading toward the END of the route instead of the start.
    /// If so, reverse the step order so they can walk the loop in their chosen direction.
    private func checkWalkingDirection(user: CLLocationCoordinate2D) {
        guard !directionChecked, steps.count > 3 else { return }

        // Accumulate distance from previous position
        if let last = lastKnownCoord {
            distanceTraveled += CLLocation(latitude: last.latitude, longitude: last.longitude)
                .distance(from: CLLocation(latitude: user.latitude, longitude: user.longitude))
        }
        lastKnownCoord = user

        guard distanceTraveled >= 50 else { return }   // wait until ~50m walked
        directionChecked = true

        // Compare distance to step 1 (forward direction) vs last step (reverse direction)
        guard let firstStep = steps.first, let lastStep = steps.last else { return }
        let firstCoord = firstStep.coordinate
        let lastCoord  = lastStep.coordinate

        let userLoc     = CLLocation(latitude: user.latitude, longitude: user.longitude)
        let distToFirst = userLoc.distance(from: CLLocation(latitude: firstCoord.latitude, longitude: firstCoord.longitude))
        let distToLast  = userLoc.distance(from: CLLocation(latitude: lastCoord.latitude,  longitude: lastCoord.longitude))

        // If the user is meaningfully closer to the LAST step, they're walking in reverse
        if distToLast < distToFirst * 0.6 {
            steps = steps.reversed()
            currentStepIndex = 0
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
    }

    func enableDemoMode() {
        isDemoMode = true
        distanceToNextManeuverMeters = nil
        isOffRoute = false
        offRouteDistanceMeters = nil
        offRouteSince = nil

        startDemoAutoAdvanceIfPossible()
    }

    func disableDemoMode() {
        isDemoMode = false
        demoAdvanceTask?.cancel()
        demoAdvanceTask = nil
    }

    func advanceStepManually() {
        advanceStepWithoutLocation()
    }

    func startDemoAutoAdvanceIfPossible() {
        guard isDemoMode else { return }
        guard steps.count > 1 else { return }

        demoAdvanceTask?.cancel()
        demoAdvanceTask = Task { [weak self] in
            guard let self else { return }
            while !Task.isCancelled {
                let seconds = Double.random(in: 5.0...8.0)
                try? await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
                if Task.isCancelled { return }
                self.advanceStepWithoutLocation()
            }
        }
    }

    func canRerouteNow() -> Bool {
        guard let lastRerouteAt else { return true }
        return Date().timeIntervalSince(lastRerouteAt) >= rerouteCooldownSeconds
    }

    func reroute(from user: CLLocationCoordinate2D) {
        guard canRerouteNow() else { return }
        guard let target = nextManeuverCoordinate else { return }

        lastRerouteAt = Date()
        isRerouting = true

        Task {
            do {
                let mini = try await NavigationDirectionsService.shared.reroute(from: user, to: target)

                // Prepend mini-route steps, then continue with remaining original steps.
                let remaining = steps.dropFirst(min(currentStepIndex, steps.count))
                let merged = Array(mini + remaining)

                await MainActor.run {
                    self.steps = merged
                    self.currentStepIndex = 0
                    self.isOffRoute = false
                    self.offRouteSince = nil
                    self.isRerouting = false
                }

                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            } catch {
                // Reroute failed — clear rerouting state and keep current steps.
                await MainActor.run { self.isRerouting = false }
            }
        }
    }

    // MARK: - Private

    private func updateDistanceToNext(user: CLLocationCoordinate2D) {
        guard let target = nextManeuverCoordinate else {
            distanceToNextManeuverMeters = nil
            return
        }
        let meters = CLLocation(latitude: user.latitude, longitude: user.longitude)
            .distance(from: CLLocation(latitude: target.latitude, longitude: target.longitude))
        distanceToNextManeuverMeters = meters
    }

    private func advanceStepIfNeeded(user: CLLocationCoordinate2D) {
        guard steps.indices.contains(currentStepIndex) else { return }
        guard let target = nextManeuverCoordinate else { return }

        let meters = CLLocation(latitude: user.latitude, longitude: user.longitude)
            .distance(from: CLLocation(latitude: target.latitude, longitude: target.longitude))

        guard meters <= stepAdvanceThresholdMeters else { return }
        guard currentStepIndex < steps.count - 1 else { return }

        currentStepIndex += 1
        lastStepAdvanceTime = Date()
        showReroutePrompt = false
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    private func advanceStepWithoutLocation() {
        guard steps.indices.contains(currentStepIndex) else { return }
        guard currentStepIndex < steps.count - 1 else { return }

        currentStepIndex += 1
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    private func updateOffRoute(user: CLLocationCoordinate2D) {
        let poly = route.pathCoordinates
        guard let dist = PolylineMath.distanceMeters(from: user, toPolyline: poly) else {
            isOffRoute = false
            offRouteSince = nil
            offRouteDistanceMeters = nil
            return
        }

        offRouteDistanceMeters = dist

        if dist > offRouteThresholdMeters {
            if offRouteSince == nil { offRouteSince = Date() }
            let held = Date().timeIntervalSince(offRouteSince ?? Date()) >= offRouteHoldSeconds
            isOffRoute = held
        } else {
            isOffRoute = false
            offRouteSince = nil
        }
    }
}
