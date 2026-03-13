import SwiftUI
import MapKit
import CoreLocation
import os.log
import UIKit
import Combine

// MARK: - Navigation View (clean rewrite)

struct RouteNavigationView: View {
    let route: Route
    var useLocation: Bool = true

    @Environment(\.dismiss) private var dismiss

    @ObservedObject private var locationManager = LocationManager.shared
    @StateObject private var navModel: RouteNavigationViewModel

    @State private var isDemoMode: Bool
    @State private var mapReady = false

    // Post-walk sheets
    @State private var showFinishSheet = false
    @State private var showShareSheet  = false
    @State private var showCollage     = false
    @State private var showMuter       = false
    @State private var showCamera      = false
    @State private var didFinish       = false

    // Route reporting
    @State private var showReportSheet = false
    @State private var didReport       = false

    private let logger = Logger(subsystem: "com.walkingroutes", category: "NavView")

    init(route: Route, useLocation: Bool = true) {
        self.route = route
        self.useLocation = useLocation
        _isDemoMode = State(initialValue: !useLocation)
        _navModel = StateObject(wrappedValue: RouteNavigationViewModel(route: route))
    }

    var body: some View {
        ZStack {
            // ── Map (created after onAppear to avoid Metal zero-size crash) ──
            if mapReady {
                RouteMapViewRepresentable(
                    route: route,
                    routeColor: route.routeColor,
                    showsUserLocation: false,
                    followUser: !isDemoMode,
                    userCoordinate: isDemoMode ? nil : locationManager.currentCoordinate,
                    userHeading: isDemoMode ? nil : locationManager.currentHeading,
                    showsNumberedPins: true,
                    fitToRoute: false,
                    detourPolyline: navModel.detourPolyline
                )
                .ignoresSafeArea()
            } else {
                Color(.systemBackground).ignoresSafeArea()
            }

            // ── Top bar ──
            VStack {
                HStack(spacing: 10) {
                    // Camera
                    Button { showCamera = true } label: {
                        Image(systemName: "camera")
                            .padding(10)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                    Spacer()
                    // GPS indicator (tap to force real GPS if stuck in demo)
                    if isDemoMode {
                        Button {
                            isDemoMode = false
                            navModel.disableDemoMode()
                            locationManager.startUpdating()
                        } label: {
                            Label("Using GPS", systemImage: "location.fill")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.green)
                                .padding(.horizontal, 10).padding(.vertical, 6)
                                .background(Color.green.opacity(0.15))
                                .clipShape(Capsule())
                        }
                    }
                    // Manual reroute button
                    Button {
                        guard let coord = locationManager.currentCoordinate else { return }
                        navModel.manualReroute(from: coord)
                    } label: {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .font(.subheadline.weight(.semibold))
                            .padding(10)
                            .background(Color(UIColor.systemBackground).opacity(0.7))
                            .clipShape(Circle())
                    }

                    // Report bad route
                    Button {
                        showReportSheet = true
                    } label: {
                        Image(systemName: didReport ? "flag.fill" : "flag")
                            .font(.subheadline.weight(.semibold))
                            .padding(10)
                            .background(didReport ? Color.red.opacity(0.15) : Color(UIColor.systemBackground).opacity(0.7))
                            .foregroundStyle(didReport ? .red : .primary)
                            .clipShape(Circle())
                    }

                    // Exit
                    Button {
                        dismiss()
                    } label: {
                        Label("Exit", systemImage: "xmark")
                            .font(.subheadline.weight(.semibold))
                            .padding(.horizontal, 12).padding(.vertical, 8)
                            .background(.ultraThinMaterial)
                            .clipShape(Capsule())
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)

                // Phase-driven banners
                switch navModel.phase {

                case .rerouting:
                    // Calculating detour
                    HStack(spacing: 8) {
                        ProgressView().tint(.white).controlSize(.small)
                        Text("Calculating route back…")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.white)
                    }
                    .padding(.horizontal, 16).padding(.vertical, 10)
                    .background(Color.orange)
                    .clipShape(Capsule())
                    .padding(.top, 8)
                    .transition(.move(edge: .top).combined(with: .opacity))

                case .detour:
                    // Following detour — orange banner with "on your way back" message
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.uturn.right.circle.fill")
                            .foregroundStyle(.white)
                        Text("Back to route")
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(.white)
                        Spacer()
                        Button {
                            guard let coord = locationManager.currentCoordinate else { return }
                            navModel.manualReroute(from: coord)
                        } label: {
                            Text("Try again")
                                .font(.caption.weight(.bold))
                                .padding(.horizontal, 10).padding(.vertical, 5)
                                .background(Color.white.opacity(0.25))
                                .clipShape(Capsule())
                                .foregroundStyle(.white)
                        }
                    }
                    .padding(.horizontal, 14).padding(.vertical, 10)
                    .background(Color.orange)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .padding(.horizontal, 12).padding(.top, 8)
                    .transition(.move(edge: .top).combined(with: .opacity))

                case .navigating where navModel.showNoProgressPrompt:
                    // No progress for 90s — prompt reroute
                    HStack(spacing: 10) {
                        Image(systemName: "questionmark.circle.fill").foregroundStyle(.white)
                        Text("Looks like you went a different way")
                            .font(.subheadline.weight(.semibold)).foregroundStyle(.white)
                        Spacer()
                        Button {
                            guard let coord = locationManager.currentCoordinate else { return }
                            navModel.manualReroute(from: coord)
                        } label: {
                            Text("Reroute")
                                .font(.subheadline.weight(.bold))
                                .padding(.horizontal, 10).padding(.vertical, 5)
                                .background(Color.white.opacity(0.25))
                                .clipShape(Capsule())
                                .foregroundStyle(.white)
                        }
                    }
                    .padding(.horizontal, 14).padding(.vertical, 10)
                    .background(Color.orange)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .padding(.horizontal, 12).padding(.top, 8)
                    .transition(.move(edge: .top).combined(with: .opacity))

                default:
                    EmptyView()
                }

                Spacer()
            }

            // ── Bottom card ──
            VStack {
                Spacer()
                    .allowsHitTesting(false)

                VStack(alignment: .leading, spacing: 12) {
                    // Instruction row
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(navModel.isAtLastStep ? "Arrived" : "Next")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.secondary)
                            Text(navModel.isAtLastStep ? "Arrive at destination" : navModel.currentInstruction)
                                .font(.title3.weight(.bold))
                                .lineLimit(3)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("Step").font(.caption.weight(.semibold)).foregroundStyle(.secondary)
                            Text(navModel.progressText).font(.subheadline.weight(.semibold))
                        }
                    }

                    Divider()

                    // Distance + controls row
                    HStack {
                        // Distance to next maneuver
                        if isDemoMode {
                            Label("Demo", systemImage: "location.north.line")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.secondary)
                        } else if let m = navModel.distanceToNextManeuverMeters {
                            Label(formatDistance(m), systemImage: "location.north.line")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.secondary)
                        } else {
                            HStack(spacing: 6) {
                                ProgressView().controlSize(.small)
                                Text("Locating…")
                            }
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.secondary)
                        }

                        Spacer()

                        if navModel.isDemoMode {
                            Button("Next step") { navModel.advanceStepManually() }
                                .font(.subheadline.weight(.semibold))
                                .padding(.horizontal, 12).padding(.vertical, 8)
                                .background(route.routeColor.color.opacity(0.18))
                                .clipShape(Capsule())
                        }
                    }

                    // Finish / Arrive button
                    if navModel.isAtLastStep {
                        Button { endWalk() } label: {
                            Text("Finish Walk")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(route.routeColor.color)
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                    } else {
                        Button { endWalk() } label: {
                            Text("Finish Walk")
                                .font(.subheadline.weight(.semibold))
                                .padding(.horizontal, 12).padding(.vertical, 8)
                                .background(route.routeColor.color.opacity(0.18))
                                .clipShape(Capsule())
                        }
                    }
                }
                .padding(16)
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .padding(.horizontal)
                .padding(.bottom, 16)
            }
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        // ── Lifecycle ──
        .onAppear {
            logger.log("NavView appeared: \(route.name)")
            navModel.loadStepsIfNeeded()
            if isDemoMode {
                navModel.enableDemoMode()
            } else {
                locationManager.startUpdating()
            }
            // Defer map creation by one run-loop tick so the push animation has
            // completed and SwiftUI has assigned a valid non-zero frame to the view.
            DispatchQueue.main.async { mapReady = true }
        }
        .onReceive(
            locationManager.$currentCoordinate.compactMap { $0 }
        ) { coord in
            guard !isDemoMode else { return }
            navModel.handleLocationUpdate(coord)
        }
        .onChange(of: navModel.isAtLastStep) { isLast in
            guard isLast, !didFinish else { return }
            didFinish = true
            endWalk()
        }
        // ── Sheets ──
        .sheet(isPresented: $showCamera) {
            NavImagePicker { img in
                PhotoService.shared.savePhoto(
                    image: img, for: route.id,
                    at: locationManager.currentCoordinate
                )
            }
            .ignoresSafeArea()
        }
        .sheet(isPresented: $showFinishSheet) {
            FinishWalkActionsSheetView(
                route: route,
                photoCount: PhotoService.shared.photos(for: route.id).count,
                onCreateCollage:   { showFinishSheet = false; showCollage = true },
                onCreateMuterVideo:{ showFinishSheet = false; showMuter   = true },
                onShareRoute:      { showFinishSheet = false; showShareSheet = true },
                onDone:            { showFinishSheet = false; dismiss() }
            )
        }
        .sheet(isPresented: $showShareSheet)  { ShareSheetView(route: route) }
        .sheet(isPresented: $showCollage)     { CollageEditorView(route: route) }
        .sheet(isPresented: $showMuter)       { MuterVideoPreviewView(route: route) }
        .confirmationDialog("Report this route", isPresented: $showReportSheet, titleVisibility: .visible) {
            ForEach(RouteReportStore.ReportReason.allCases, id: \.self) { reason in
                Button(reason.rawValue, role: reason == .other ? .cancel : .none) {
                    if reason != .other { submitReport(reason: reason) }
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Help us improve routes. This route will be flagged and a new one will be generated.")
        }
    }

    // MARK: - Helpers

    private func endWalk() {
        RouteCompletionStore.markCompleted(route.id)
        showFinishSheet = true
    }

    private func submitReport(reason: RouteReportStore.ReportReason) {
        // Calculate route center + radius for the avoidance zone
        let coords = route.pathCoordinates
        guard !coords.isEmpty else { return }

        let avgLat = coords.map(\.latitude).reduce(0, +) / Double(coords.count)
        let avgLon = coords.map(\.longitude).reduce(0, +) / Double(coords.count)
        let center = CLLocationCoordinate2D(latitude: avgLat, longitude: avgLon)

        let centerLoc = CLLocation(latitude: avgLat, longitude: avgLon)
        let radius = coords.map {
            centerLoc.distance(from: CLLocation(latitude: $0.latitude, longitude: $0.longitude))
        }.max() ?? 500

        RouteReportStore.report(routeID: route.id, reason: reason, routeCenter: center, routeRadius: radius)

        didReport = true
        UINotificationFeedbackGenerator().notificationOccurred(.success)

        // Dismiss navigation so ContentView regenerates a fresh route
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            dismiss()
        }
    }

    private func formatDistance(_ m: CLLocationDistance) -> String {
        m < 1000 ? "\(Int(m)) m" : String(format: "%.1f km", m / 1000)
    }
}

// MARK: - Map View

struct RouteMapViewRepresentable: UIViewRepresentable {
    let route: Route
    var routeColor: RouteColor = .canalRing
    var showsUserLocation: Bool = false
    var followUser: Bool = false
    var userCoordinate: CLLocationCoordinate2D?
    var userHeading: CLLocationDirection?   // degrees, nil = no arrow
    var showsNumberedPins: Bool = false
    var fitToRoute: Bool = false
    var addedFoodSpots: [Landmark] = []    // user-added café/restaurant pins (teal)
    var detourPolyline: [CLLocationCoordinate2D] = []   // orange dashed overlay during reroute

    private let logger = Logger(subsystem: "com.walkingroutes", category: "RouteMapView")

    func makeCoordinator() -> Coordinator { Coordinator(routeColor: routeColor, fitToRoute: fitToRoute) }

    func makeUIView(context: Context) -> MKMapView {
        logger.log("Creating MKMapView (fitToRoute: \(fitToRoute))")
        let mapView = MKMapView(frame: UIScreen.main.bounds)
        mapView.showsCompass = true
        mapView.showsScale = false
        mapView.showsUserLocation = showsUserLocation
        mapView.delegate = context.coordinator
        mapView.pointOfInterestFilter = .excludingAll
        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        context.coordinator.routeColor = routeColor
        context.coordinator.fitToRoute = fitToRoute
        mapView.showsUserLocation = showsUserLocation

        let routeChanged = context.coordinator.hasRouteChanged(to: route.id)

        if routeChanged {
            mapView.removeOverlays(mapView.overlays)
            mapView.removeAnnotations(mapView.annotations.filter { !($0 is MKUserLocation) })
            context.coordinator.resetFoodSpotIDs(on: mapView)

            let points = route.pathCoordinates
            guard !points.isEmpty else {
                logger.warning("No path coordinates for route: \(route.name)")
                return
            }

            context.coordinator.markRouteDrawn(route.id)

            if showsNumberedPins {
                // Cultural/historical landmarks → numbered orange pins
                let cultural = route.landmarks.filter { !$0.isFoodSpot }
                for (i, lm) in cultural.enumerated() {
                    let a = NumberedPointAnnotation()
                    a.number = i + 1
                    a.title = lm.name
                    a.subtitle = lm.description
                    a.coordinate = lm.location.clLocation
                    mapView.addAnnotation(a)
                }
            }

            let lmRects = route.landmarks.map {
                MKMapRect(origin: MKMapPoint($0.location.clLocation), size: MKMapSize(width: 0, height: 0))
            }
            context.coordinator.landmarksBoundingRect = lmRects.reduce(MKMapRect.null) { $0.union($1) }

            context.coordinator.drawWalkingRoute(points: points, on: mapView)
        }

        // Food spot pins — always diffed independently of route changes
        context.coordinator.updateFoodSpotPins(addedFoodSpots, on: mapView)

        // Detour overlay — orange dashed path back to planned route
        context.coordinator.updateDetourOverlay(detourPolyline, on: mapView)

        // User location puck (custom blue dot + heading arrow — avoids MKCoreLocationProvider conflict)
        context.coordinator.updateUserPuck(coordinate: userCoordinate, heading: userHeading, on: mapView)

        // Camera: follow GPS when walking (heading-aware, Apple Maps style)
        if followUser, let coord = userCoordinate {
            let heading = userHeading ?? mapView.camera.heading
            let camera  = MKMapCamera(lookingAtCenter: coord,
                                      fromDistance: 600,
                                      pitch: 0,
                                      heading: heading)
            mapView.setCamera(camera, animated: true)
        } else if !fitToRoute, let first = route.pathCoordinates.first {
            let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            mapView.setRegion(MKCoordinateRegion(center: first, span: span), animated: false)
        }
    }

    // MARK: Coordinator

    class Coordinator: NSObject, MKMapViewDelegate {
        var routeColor: RouteColor
        var fitToRoute: Bool
        var landmarksBoundingRect: MKMapRect = .null
        private var drawnRouteId: UUID?
        private var polylineCache: [String: MKPolyline] = [:]
        private var allPolylines: [MKPolyline] = []
        private let logger = Logger(subsystem: "com.walkingroutes", category: "MapCoordinator")

        // Track added food spot IDs so we can diff and update teal pins independently of route changes
        private var drawnFoodSpotIDs: Set<UUID> = []

        // Detour polyline overlay (orange dashed) — managed independently of route
        var drawnDetourPolyline: MKPolyline?

        init(routeColor: RouteColor, fitToRoute: Bool) {
            self.routeColor = routeColor
            self.fitToRoute = fitToRoute
        }

        func hasRouteChanged(to id: UUID) -> Bool { drawnRouteId != id }
        func markRouteDrawn(_ id: UUID)           { drawnRouteId = id }

        /// Add/replace/remove the orange dashed detour overlay.
        func updateDetourOverlay(_ coords: [CLLocationCoordinate2D], on mapView: MKMapView) {
            if let old = drawnDetourPolyline {
                mapView.removeOverlay(old)
                drawnDetourPolyline = nil
            }
            guard coords.count >= 2 else { return }
            let poly = MKPolyline(coordinates: coords, count: coords.count)
            mapView.addOverlay(poly, level: .aboveRoads)
            drawnDetourPolyline = poly
        }

        func resetFoodSpotIDs(on mapView: MKMapView? = nil) {
            if let mapView {
                let stale = mapView.annotations.compactMap { $0 as? FoodSpotAnnotation }
                mapView.removeAnnotations(stale)
            }
            drawnFoodSpotIDs = []
        }

        /// Diff the current food spot list and add/remove teal pins as needed.
        func updateFoodSpotPins(_ spots: [Landmark], on mapView: MKMapView) {
            let newIDs = Set(spots.map(\.id))
            guard newIDs != drawnFoodSpotIDs else { return }

            // Remove by landmark UUID — safe even when two spots share a name
            let removedIDs = drawnFoodSpotIDs.subtracting(newIDs)
            if !removedIDs.isEmpty {
                let toRemove = mapView.annotations
                    .compactMap { $0 as? FoodSpotAnnotation }
                    .filter { removedIDs.contains($0.landmarkID) }
                mapView.removeAnnotations(toRemove)
            }

            // Add newly added spots
            let addedIDs = newIDs.subtracting(drawnFoodSpotIDs)
            for spot in spots where addedIDs.contains(spot.id) {
                let a = FoodSpotAnnotation()
                a.landmarkID = spot.id
                a.title = spot.name
                a.subtitle = spot.openingHours ?? spot.description
                a.coordinate = spot.location.clLocation
                mapView.addAnnotation(a)
            }

            drawnFoodSpotIDs = newIDs
        }

        // MARK: User puck
        private var userPuck: UserPuckAnnotation?

        func updateUserPuck(coordinate: CLLocationCoordinate2D?, heading: CLLocationDirection?, on mapView: MKMapView) {
            guard let coord = coordinate else {
                if let existing = userPuck { mapView.removeAnnotation(existing) }
                userPuck = nil
                return
            }
            if let existing = userPuck {
                UIView.animate(withDuration: 0.3) {
                    existing.coordinate = coord
                    existing.heading = heading
                    if let view = mapView.view(for: existing) as? UserPuckAnnotationView {
                        view.updateHeading(heading)
                    }
                }
            } else {
                let puck = UserPuckAnnotation(coordinate: coord, heading: heading)
                userPuck = puck
                mapView.addAnnotation(puck)
            }
        }

        func drawWalkingRoute(points: [CLLocationCoordinate2D], on mapView: MKMapView) {
            let key = points.map { "\($0.latitude),\($0.longitude)" }.joined(separator: "|")
            let polyline: MKPolyline
            if let cached = polylineCache[key] {
                polyline = cached
            } else {
                polyline = MKPolyline(coordinates: points, count: points.count)
                polylineCache[key] = polyline
            }
            allPolylines = [polyline]
            mapView.addOverlay(polyline, level: .aboveRoads)

            if fitToRoute {
                var rect = polyline.boundingMapRect
                if !landmarksBoundingRect.isNull { rect = rect.union(landmarksBoundingRect) }
                let padded = rect.insetBy(dx: -rect.size.width * 0.15, dy: -rect.size.height * 0.15)
                mapView.setVisibleMapRect(padded, animated: false)
                logger.log("Fitted map to show route. Segments: \(points.count). Landmarks: \(self.landmarksBoundingRect.isNull ? 0 : 1)")
            }
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            guard let polyline = overlay as? MKPolyline else { return MKOverlayRenderer(overlay: overlay) }

            // Detour overlay — orange dashed line on top of planned route
            if polyline === drawnDetourPolyline {
                let r = MKPolylineRenderer(polyline: polyline)
                r.strokeColor = UIColor.systemOrange
                r.lineWidth   = 6
                r.lineDashPattern = [8, 5]
                r.lineCap     = .round
                return r
            }

            // Planned route polyline
            let r = MKPolylineRenderer(polyline: polyline)
            r.strokeColor = routeColor.uiColor
            r.lineWidth   = 5
            r.lineCap     = .round
            r.lineJoin    = .round
            return r
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if let puck = annotation as? UserPuckAnnotation {
                let id = "UserPuck"
                let view = (mapView.dequeueReusableAnnotationView(withIdentifier: id) as? UserPuckAnnotationView)
                    ?? UserPuckAnnotationView(annotation: annotation, reuseIdentifier: id)
                view.annotation = puck
                view.updateHeading(puck.heading)
                return view
            }
            if let food = annotation as? FoodSpotAnnotation {
                let id = "FoodSpot"
                let view = mapView.dequeueReusableAnnotationView(withIdentifier: id)
                    ?? FoodSpotAnnotationView(annotation: annotation, reuseIdentifier: id)
                view.annotation = food
                return view
            }
            guard let numbered = annotation as? NumberedPointAnnotation else { return nil }
            let id = "NumberedPin"
            let view = mapView.dequeueReusableAnnotationView(withIdentifier: id)
                ?? NumberedAnnotationView(annotation: annotation, reuseIdentifier: id)
            view.annotation = numbered
            return view
        }
    }
}

// MARK: - User Location Puck

final class UserPuckAnnotation: NSObject, MKAnnotation {
    dynamic var coordinate: CLLocationCoordinate2D
    var heading: CLLocationDirection?
    init(coordinate: CLLocationCoordinate2D, heading: CLLocationDirection?) {
        self.coordinate = coordinate
        self.heading = heading
    }
}

/// Apple Maps–style blue dot with a direction wedge.
final class UserPuckAnnotationView: MKAnnotationView {
    private let size: CGFloat = 22
    private let pulseLayer = CALayer()
    private var arrowLayer: CAShapeLayer?

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        frame = CGRect(origin: .zero, size: CGSize(width: size, height: size))
        centerOffset = .zero
        isEnabled = false

        // Outer pulse ring
        let pulse = CALayer()
        let pSize: CGFloat = size + 12
        pulse.frame = CGRect(x: -(pSize - size) / 2, y: -(pSize - size) / 2, width: pSize, height: pSize)
        pulse.cornerRadius = pSize / 2
        pulse.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.15).cgColor
        layer.addSublayer(pulse)
        pulseLayer.frame = pulse.bounds

        // White shadow ring
        let ring = CALayer()
        ring.frame = CGRect(x: -1, y: -1, width: size + 2, height: size + 2)
        ring.cornerRadius = (size + 2) / 2
        ring.backgroundColor = UIColor.white.cgColor
        layer.addSublayer(ring)

        // Blue dot
        let dot = CALayer()
        dot.frame = CGRect(x: 0, y: 0, width: size, height: size)
        dot.cornerRadius = size / 2
        dot.backgroundColor = UIColor.systemBlue.cgColor
        layer.addSublayer(dot)
    }
    required init?(coder: NSCoder) { fatalError() }

    func updateHeading(_ heading: CLLocationDirection?) {
        // Remove old arrow
        arrowLayer?.removeFromSuperlayer()
        arrowLayer = nil

        guard let heading else { return }

        // Direction wedge — white triangle on top of the dot
        let arrow = CAShapeLayer()
        let w: CGFloat = 8, h: CGFloat = 12
        let path = UIBezierPath()
        path.move(to:    CGPoint(x: 0,    y: -h))    // tip
        path.addLine(to: CGPoint(x:  w/2, y:  0))
        path.addLine(to: CGPoint(x: -w/2, y:  0))
        path.close()
        arrow.path      = path.cgPath
        arrow.fillColor = UIColor.white.cgColor
        arrow.position  = CGPoint(x: size / 2, y: size / 2)
        arrow.transform = CATransform3DMakeRotation(CGFloat(heading) * .pi / 180, 0, 0, 1)
        layer.addSublayer(arrow)
        arrowLayer = arrow
    }
}

// MARK: - Location

final class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    static let shared = LocationManager()

    private let manager = CLLocationManager()

    @Published var currentCoordinate: CLLocationCoordinate2D?
    @Published var currentHeading: CLLocationDirection?   // degrees from true north
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined

    private let logger = Logger(subsystem: "com.walkingroutes", category: "LocationManager")

    var isAuthorized: Bool {
        switch authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse: return true
        default: return false
        }
    }

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        refreshAuthorizationStatus()
        switch authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        default: break
        }
    }

    func startUpdating() {
        refreshAuthorizationStatus()
        guard isAuthorized else { manager.requestWhenInUseAuthorization(); return }
        manager.startUpdatingLocation()
        if CLLocationManager.headingAvailable() {
            manager.headingFilter = 5   // degrees — don't spam on tiny changes
            manager.startUpdatingHeading()
        }
    }

    func stopUpdating() {
        manager.stopUpdatingLocation()
        manager.stopUpdatingHeading()
    }

    func requestAuthorizationIfNeeded() {
        if authorizationStatus == .notDetermined { manager.requestWhenInUseAuthorization() }
    }

    private func refreshAuthorizationStatus() {
        if #available(iOS 14.0, *) {
            authorizationStatus = manager.authorizationStatus
        } else {
            authorizationStatus = CLLocationManager.authorizationStatus()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else { return }
        DispatchQueue.main.async { self.currentCoordinate = loc.coordinate }
        logger.log("Location updated: lat=\(loc.coordinate.latitude), lon=\(loc.coordinate.longitude)")
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        logger.warning("Location error: \(error.localizedDescription)")
    }

    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        guard newHeading.headingAccuracy >= 0 else { return }
        DispatchQueue.main.async { self.currentHeading = newHeading.trueHeading }
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        DispatchQueue.main.async {
            self.authorizationStatus = status
            if status == .authorizedWhenInUse || status == .authorizedAlways {
                self.manager.startUpdatingLocation()
            }
        }
        logger.log("Authorization changed to: \(String(describing: status))")
    }
}

// MARK: - Annotation types (used by RouteMapViewRepresentable)

final class NumberedPointAnnotation: MKPointAnnotation {
    var number: Int = 0
}

/// Teal pin for user-added food/café spots.
final class FoodSpotAnnotation: MKPointAnnotation {
    var landmarkID: UUID = UUID()   // used for safe diffing (name-based matching is fragile)
}

final class FoodSpotAnnotationView: MKAnnotationView {
    private static let reuseID = "FoodSpot"

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        frame = CGRect(x: 0, y: 0, width: 30, height: 36)
        canShowCallout = true
    }
    required init?(coder: NSCoder) { fatalError() }

    override func draw(_ rect: CGRect) {
        let ctx = UIGraphicsGetCurrentContext()!
        // Teal teardrop pin
        let pinRect = CGRect(x: 1, y: 1, width: rect.width - 2, height: rect.width - 2)
        ctx.setFillColor(UIColor.systemTeal.cgColor)
        ctx.fillEllipse(in: pinRect)
        // Triangle point at bottom
        let cx = rect.midX
        let top = rect.width - 1
        let tip = rect.height - 1
        ctx.move(to: CGPoint(x: cx - 4, y: top))
        ctx.addLine(to: CGPoint(x: cx + 4, y: top))
        ctx.addLine(to: CGPoint(x: cx, y: tip))
        ctx.closePath()
        ctx.fillPath()
        // Fork & knife icon
        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12),
            .foregroundColor: UIColor.white
        ]
        let s = "🍽" as NSString
        let sz = s.size(withAttributes: attrs)
        s.draw(at: CGPoint(x: (pinRect.width - sz.width) / 2 + 1,
                           y: (pinRect.height - sz.height) / 2 + 1),
               withAttributes: attrs)
    }
}

final class NumberedAnnotationView: MKAnnotationView {
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        frame = CGRect(x: 0, y: 0, width: 28, height: 28)
    }
    required init?(coder: NSCoder) { fatalError() }
    override func draw(_ rect: CGRect) {
        guard let n = (annotation as? NumberedPointAnnotation)?.number else { return }
        let ctx = UIGraphicsGetCurrentContext()!
        ctx.setFillColor(UIColor.systemOrange.cgColor)
        ctx.fillEllipse(in: rect.insetBy(dx: 1, dy: 1))
        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 12),
            .foregroundColor: UIColor.white
        ]
        let s = "\(n)" as NSString
        let sz = s.size(withAttributes: attrs)
        s.draw(at: CGPoint(x: (rect.width - sz.width) / 2,
                            y: (rect.height - sz.height) / 2),
               withAttributes: attrs)
    }
}

// MARK: - ImagePicker (camera sheet)

struct NavImagePicker: UIViewControllerRepresentable {
    let onImagePicked: (UIImage) -> Void
    @Environment(\.dismiss) private var dismiss

    func makeCoordinator() -> Coordinator { Coordinator(parent: self) }
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let p = UIImagePickerController()
        p.sourceType = .camera
        p.allowsEditing = false
        p.delegate = context.coordinator
        return p
    }
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    final class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: NavImagePicker
        init(parent: NavImagePicker) { self.parent = parent }
        func imagePickerController(_ p: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let img = info[.originalImage] as? UIImage { parent.onImagePicked(img) }
            parent.dismiss()
        }
        func imagePickerControllerDidCancel(_ p: UIImagePickerController) { parent.dismiss() }
    }
}
