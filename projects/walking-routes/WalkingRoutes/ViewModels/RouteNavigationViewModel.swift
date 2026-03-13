import Foundation
import CoreLocation
import Combine
import UIKit

// MARK: - Navigation Phase

enum NavigationPhase: Equatable {
    case loading        // steps not yet loaded
    case navigating     // following original planned route
    case rerouting      // async reroute in flight (spinner)
    case detour         // following a detour back to the planned route
    case arrived
}

// MARK: - ViewModel

@MainActor
final class RouteNavigationViewModel: ObservableObject {

    // MARK: Published state

    @Published private(set) var steps: [NavigationStep] = []
    @Published private(set) var currentStepIndex: Int = 0
    @Published private(set) var distanceToNextManeuverMeters: CLLocationDistance?

    @Published private(set) var isDemoMode: Bool = false

    /// Current navigation phase — drives all UI states (replaces isOffRoute / isRerouting / showReroutePrompt)
    @Published private(set) var phase: NavigationPhase = .loading

    /// Detour polyline to draw on the map (orange dashed overlay). Non-empty only in .detour phase.
    @Published private(set) var detourPolyline: [CLLocationCoordinate2D] = []

    /// Instruction to show during a detour. Empty outside .detour phase.
    @Published private(set) var detourInstruction: String = ""

    // MARK: Private

    private let route: Route
    private let stepAdvanceThresholdMeters: CLLocationDistance = 25

    // Off-route detection thresholds
    private let offRouteThresholdMeters: CLLocationDistance = 50   // raised from 30 — reduces false positives in dense streets
    private let offRouteHoldSeconds: TimeInterval = 5              // raised from 3
    private var offRouteSince: Date?

    // Reroute cooldown — prevents hammering MKDirections
    private let rerouteCooldownSeconds: TimeInterval = 30
    private var lastRerouteAt: Date?

    // Detour state
    private var detourSteps: [NavigationStep] = []
    private var detourStepIndex: Int = 0
    private var resumeStepIndex: Int = 0                           // original step to resume at after detour
    private var reconnectionCoordinate: CLLocationCoordinate2D?

    // No-progress detection
    private let noProgressTimeoutSeconds: TimeInterval = 90
    private var lastStepAdvanceTime: Date = Date()
    @Published var showNoProgressPrompt: Bool = false

    // Direction detection
    private var directionChecked = false
    private var lastKnownCoord: CLLocationCoordinate2D?
    private var distanceTraveled: CLLocationDistance = 0

    private var demoAdvanceTask: Task<Void, Never>?

    // MARK: Init

    init(route: Route) {
        self.route = route
    }

    deinit {
        demoAdvanceTask?.cancel()
    }

    // MARK: - Computed

    var progressText: String {
        let total = max(steps.count, 1)
        return "\(min(currentStepIndex + 1, total)) / \(total)"
    }

    var isAtLastStep: Bool {
        guard !steps.isEmpty else { return false }
        return currentStepIndex >= steps.count - 1
    }

    var currentInstruction: String {
        switch phase {
        case .detour:
            return detourInstruction.isEmpty ? "Follow the route back" : detourInstruction
        default:
            guard steps.indices.contains(currentStepIndex) else { return "Starting…" }
            return steps[currentStepIndex].instruction
        }
    }

    var nextManeuverCoordinate: CLLocationCoordinate2D? {
        switch phase {
        case .detour:
            guard detourSteps.indices.contains(detourStepIndex) else { return reconnectionCoordinate }
            return detourSteps[detourStepIndex].coordinate
        default:
            guard steps.indices.contains(currentStepIndex) else { return nil }
            return steps[currentStepIndex].coordinate
        }
    }

    // MARK: - Load steps

    func loadStepsIfNeeded() {
        guard steps.isEmpty else { return }

        if let persisted = route.navigationSteps, !persisted.isEmpty {
            steps = persisted
            currentStepIndex = 0
            phase = .navigating
            if isDemoMode { startDemoAutoAdvanceIfPossible() }
            return
        }

        Task {
            do {
                let computed = try await withThrowingTaskGroup(of: [NavigationStep].self) { group in
                    group.addTask { try await NavigationDirectionsService.shared.steps(for: self.route) }
                    group.addTask {
                        try await Task.sleep(nanoseconds: 3_000_000_000)
                        throw CancellationError()
                    }
                    defer { group.cancelAll() }
                    guard let result = try await group.next() else { throw CancellationError() }
                    return result
                }
                self.steps = computed
                self.currentStepIndex = 0
                self.phase = .navigating
                if self.isDemoMode { self.startDemoAutoAdvanceIfPossible() }
            } catch {
                let fallback = route.navigationSteps ?? []
                self.steps = fallback
                self.phase = fallback.isEmpty ? .loading : .navigating
                if self.isDemoMode && !fallback.isEmpty { self.startDemoAutoAdvanceIfPossible() }
            }
        }
    }

    // MARK: - Location updates

    func handleLocationUpdate(_ user: CLLocationCoordinate2D) {
        guard !isDemoMode else { return }

        checkWalkingDirection(user: user)
        updateDistanceToNext(user: user)

        switch phase {
        case .navigating:
            advanceStepIfNeeded(user: user)
            detectOffRoute(user: user)
            checkNoProgress()

        case .detour:
            advanceDetourStepIfNeeded(user: user)
            checkDetourComplete(user: user)

        default:
            break
        }
    }

    // MARK: - Rerouting (public)

    /// Trigger reroute manually (e.g. from the ↺ button or no-progress prompt).
    func manualReroute(from user: CLLocationCoordinate2D) {
        showNoProgressPrompt = false
        lastStepAdvanceTime = Date()
        startReroute(from: user)
    }

    func dismissNoProgressPrompt() {
        showNoProgressPrompt = false
        lastStepAdvanceTime = Date()
    }

    // MARK: - Rerouting (private core)

    /// Apple Maps style: find nearest remaining step, route to it, show detour overlay.
    private func startReroute(from user: CLLocationCoordinate2D) {
        guard phase == .navigating || phase == .detour else { return }
        guard canRerouteNow() else { return }

        lastRerouteAt = Date()
        phase = .rerouting
        offRouteSince = nil
        detourPolyline = []
        detourSteps = []

        Task {
            do {
                // Step 1: find nearest remaining step to reconnect to
                let (target, resumeIdx) = nearestRemainingStep(to: user)

                // Step 2: get walking directions from current position → reconnection point
                let result = try await NavigationDirectionsService.shared.detourRoute(from: user, to: target.coordinate)

                // Step 3: apply detour
                self.detourSteps = result.steps
                self.detourStepIndex = 0
                self.detourPolyline = result.polylineCoordinates
                self.detourInstruction = result.steps.first?.instruction ?? "Head back to your route"
                self.resumeStepIndex = resumeIdx
                self.reconnectionCoordinate = target.coordinate
                self.phase = .detour

                UIImpactFeedbackGenerator(style: .medium).impactOccurred()

            } catch {
                // Reroute failed — go back to navigating so user can try again
                self.phase = .navigating
                self.detourPolyline = []
            }
        }
    }

    /// Find the nearest step in the remaining route (from currentStepIndex onwards).
    /// Returns the step and its index so we know where to resume the original route.
    private func nearestRemainingStep(to user: CLLocationCoordinate2D) -> (NavigationStep, Int) {
        let userLoc = CLLocation(latitude: user.latitude, longitude: user.longitude)

        var bestDist = CLLocationDistance.greatestFiniteMagnitude
        var bestStep = steps[max(0, min(currentStepIndex, steps.count - 1))]
        var bestIdx  = max(0, min(currentStepIndex, steps.count - 1))

        for i in currentStepIndex..<steps.count {
            let step = steps[i]
            let dist = userLoc.distance(from: CLLocation(latitude: step.latitude, longitude: step.longitude))
            if dist < bestDist {
                bestDist = dist
                bestStep = step
                bestIdx  = i
            }
        }
        return (bestStep, bestIdx)
    }

    // MARK: - Detour tracking

    private func advanceDetourStepIfNeeded(user: CLLocationCoordinate2D) {
        guard detourSteps.indices.contains(detourStepIndex) else { return }
        let target = detourSteps[detourStepIndex].coordinate
        let dist = CLLocation(latitude: user.latitude, longitude: user.longitude)
            .distance(from: CLLocation(latitude: target.latitude, longitude: target.longitude))

        guard dist <= stepAdvanceThresholdMeters else { return }
        guard detourStepIndex < detourSteps.count - 1 else { return }

        detourStepIndex += 1
        detourInstruction = detourSteps[detourStepIndex].instruction
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    private func checkDetourComplete(user: CLLocationCoordinate2D) {
        guard let reconnect = reconnectionCoordinate else { return }
        let dist = CLLocation(latitude: user.latitude, longitude: user.longitude)
            .distance(from: CLLocation(latitude: reconnect.latitude, longitude: reconnect.longitude))

        guard dist <= stepAdvanceThresholdMeters else { return }

        // Arrived back on route — resume original navigation
        currentStepIndex = min(resumeStepIndex, steps.count - 1)
        lastStepAdvanceTime = Date()
        detourSteps = []
        detourPolyline = []
        detourInstruction = ""
        reconnectionCoordinate = nil
        offRouteSince = nil
        phase = .navigating

        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    // MARK: - Off-route detection

    private func detectOffRoute(user: CLLocationCoordinate2D) {
        guard phase == .navigating else { return }

        let poly = route.pathCoordinates
        guard let dist = PolylineMath.distanceMeters(from: user, toPolyline: poly) else {
            offRouteSince = nil
            return
        }

        if dist > offRouteThresholdMeters {
            if offRouteSince == nil { offRouteSince = Date() }
            let held = Date().timeIntervalSince(offRouteSince!) >= offRouteHoldSeconds
            if held && canRerouteNow() {
                // Auto-reroute
                offRouteSince = nil
                startReroute(from: user)
            }
        } else {
            offRouteSince = nil
        }
    }

    // MARK: - No-progress detection

    private func checkNoProgress() {
        guard phase == .navigating, !isAtLastStep else { return }
        let stuck = Date().timeIntervalSince(lastStepAdvanceTime) >= noProgressTimeoutSeconds
        if stuck && !showNoProgressPrompt {
            showNoProgressPrompt = true
        }
    }

    // MARK: - Step advance (normal navigation)

    private func advanceStepIfNeeded(user: CLLocationCoordinate2D) {
        guard steps.indices.contains(currentStepIndex) else { return }
        guard let target = nextManeuverCoordinate else { return }

        let dist = CLLocation(latitude: user.latitude, longitude: user.longitude)
            .distance(from: CLLocation(latitude: target.latitude, longitude: target.longitude))

        guard dist <= stepAdvanceThresholdMeters else { return }
        guard currentStepIndex < steps.count - 1 else { return }

        currentStepIndex += 1
        lastStepAdvanceTime = Date()
        showNoProgressPrompt = false
        offRouteSince = nil
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    private func updateDistanceToNext(user: CLLocationCoordinate2D) {
        guard let target = nextManeuverCoordinate else {
            distanceToNextManeuverMeters = nil
            return
        }
        distanceToNextManeuverMeters = CLLocation(latitude: user.latitude, longitude: user.longitude)
            .distance(from: CLLocation(latitude: target.latitude, longitude: target.longitude))
    }

    // MARK: - Walking direction detection

    private func checkWalkingDirection(user: CLLocationCoordinate2D) {
        guard !directionChecked, steps.count > 3 else { return }

        if let last = lastKnownCoord {
            distanceTraveled += CLLocation(latitude: last.latitude, longitude: last.longitude)
                .distance(from: CLLocation(latitude: user.latitude, longitude: user.longitude))
        }
        lastKnownCoord = user

        guard distanceTraveled >= 50 else { return }
        directionChecked = true

        guard let firstStep = steps.first, let lastStep = steps.last else { return }
        let userLoc     = CLLocation(latitude: user.latitude, longitude: user.longitude)
        let distToFirst = userLoc.distance(from: CLLocation(latitude: firstStep.coordinate.latitude, longitude: firstStep.coordinate.longitude))
        let distToLast  = userLoc.distance(from: CLLocation(latitude: lastStep.coordinate.latitude, longitude: lastStep.coordinate.longitude))

        if distToLast < distToFirst * 0.6 {
            steps = steps.reversed()
            currentStepIndex = 0
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
    }

    // MARK: - Cooldown check

    private func canRerouteNow() -> Bool {
        guard let lastRerouteAt else { return true }
        return Date().timeIntervalSince(lastRerouteAt) >= rerouteCooldownSeconds
    }

    // MARK: - Demo mode

    func enableDemoMode() {
        isDemoMode = true
        distanceToNextManeuverMeters = nil
        offRouteSince = nil
        startDemoAutoAdvanceIfPossible()
    }

    func disableDemoMode() {
        isDemoMode = false
        demoAdvanceTask?.cancel()
        demoAdvanceTask = nil
    }

    func advanceStepManually() {
        guard steps.indices.contains(currentStepIndex) else { return }
        guard currentStepIndex < steps.count - 1 else { return }
        currentStepIndex += 1
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
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
                self.advanceStepManually()
            }
        }
    }
}
