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

    private let route: Route
    private let offRouteThresholdMeters: CLLocationDistance = 60
    private let offRouteHoldSeconds: TimeInterval = 6
    private let stepAdvanceThresholdMeters: CLLocationDistance = 35
    private let rerouteCooldownSeconds: TimeInterval = 60

    private var offRouteSince: Date?
    private var lastRerouteAt: Date?

    private var demoAdvanceTask: Task<Void, Never>?

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
        Task {
            do {
                let computed = try await NavigationDirectionsService.shared.steps(for: route)
                await MainActor.run {
                    self.steps = computed
                    self.currentStepIndex = 0
                    if self.isDemoMode {
                        self.startDemoAutoAdvanceIfPossible()
                    }
                }
            } catch {
                // If NavigationDirectionsService fails (e.g., throttled), use persisted steps from route.
                let fallback = route.navigationSteps ?? []
                await MainActor.run {
                    self.steps = fallback
                    if self.isDemoMode && !fallback.isEmpty {
                        self.startDemoAutoAdvanceIfPossible()
                    }
                }
            }
        }
    }

    func handleLocationUpdate(_ user: CLLocationCoordinate2D) {
        guard !isDemoMode else { return }
        updateDistanceToNext(user: user)
        advanceStepIfNeeded(user: user)
        updateOffRoute(user: user)
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

        Task {
            do {
                let mini = try await NavigationDirectionsService.shared.reroute(from: user, to: target)

                // Prepend mini-route steps, then continue with remaining original steps.
                let remaining = steps.dropFirst(min(currentStepIndex, steps.count))
                let merged = mini + remaining

                await MainActor.run {
                    self.steps = merged
                    self.currentStepIndex = 0
                    self.isOffRoute = false
                    self.offRouteSince = nil
                }

                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            } catch {
                // If reroute fails, keep current steps.
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
