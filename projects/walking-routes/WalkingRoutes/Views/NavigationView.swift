import SwiftUI
import MapKit
import CoreLocation
import os.log
import UIKit
import Combine

/// Maps-like turn-by-turn navigation (walking) + in-nav photo capture + simple wrong-turn detection.
struct RouteNavigationView: View {
    let route: Route
    var useLocation: Bool = true

    @Environment(\.dismiss) private var dismiss

    @StateObject private var locationManager = LocationManager()
    @StateObject private var photoService = PhotoService.shared
    @StateObject private var navModel: RouteNavigationViewModel

    @State private var showCamera = false
    @State private var isDemoNavigation = false

    @State private var showFinishSheet = false
    @State private var showShareSheet = false
    @State private var showCollageSheet = false
    @State private var showMuterVideoSheet = false
    @State private var didAutoPresentFinish = false

    private let logger = Logger(subsystem: "com.walkingroutes", category: "RouteNavigationView")

    init(route: Route, useLocation: Bool = true) {
        self.route = route
        self.useLocation = useLocation
        _navModel = StateObject(wrappedValue: RouteNavigationViewModel(route: route))
    }

    private var effectiveUseLocation: Bool { useLocation && !isDemoNavigation }

    private var locationUpdates: AnyPublisher<CLLocationCoordinate2D, Never> {
        guard effectiveUseLocation else { return Empty().eraseToAnyPublisher() }
        return locationManager.$currentCoordinate
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }

    var body: some View {
        RouteMapViewRepresentable(
            route: route,
            routeColor: route.routeColor,
            showsUserLocation: effectiveUseLocation,
            followUser: effectiveUseLocation,
            userCoordinate: effectiveUseLocation ? locationManager.currentCoordinate : nil,
            showsNumberedPins: true,
            fitToRoute: false
        )
        .ignoresSafeArea()
        // Keep controls above the MKMapView so taps always land on buttons (Exit/Camera).
        .overlay(alignment: .top) {
            VStack(spacing: 0) {
                topControls

                if navModel.isOffRoute {
                    offRouteBanner
                        .padding(.horizontal)
                        .padding(.top, 10)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }

                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .zIndex(10)
        }
        .overlay(alignment: .bottom) {
            turnByTurnCard
                .padding(.horizontal)
                .padding(.bottom, 16)
                .zIndex(10)
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .onAppear {
            logger.log("NavigationView appeared for route: \(route.name)")

            navModel.loadStepsIfNeeded()

            // Default behaviour: demo navigation (no GPS, no permission prompt).
            isDemoNavigation = !useLocation
            if isDemoNavigation {
                locationManager.stopUpdating()
                navModel.enableDemoMode()
            }
            // LocationManager is always initialized (@StateObject). Updates start automatically
            // if authorized. No fallback to demo — real GPS is used if permission is granted.
        }
        .onDisappear {
            logger.log("NavigationView disappeared")
            locationManager.stopUpdating()
            navModel.disableDemoMode()
        }
        .onReceive(locationUpdates) { user in
            navModel.handleLocationUpdate(user)
        }
        .onChange(of: navModel.isAtLastStep) { isLast in
            // MVP: when the user reaches the final step, proactively prompt to finish.
            guard isLast else { return }
            guard !didAutoPresentFinish else { return }
            didAutoPresentFinish = true
            finishWalk()
        }
        .sheet(isPresented: $showCamera) {
            ImagePicker(sourceType: .camera) { image in
                savePhoto(image: image)
            }
            .ignoresSafeArea()
        }
        .sheet(isPresented: $showFinishSheet) {
            FinishWalkActionsSheetView(
                route: route,
                photoCount: photoService.photos(for: route.id).count,
                onCreateCollage: {
                    // Only open collage when photos exist (MVP requirement).
                    showFinishSheet = false
                    showCollageSheet = true
                },
                onCreateMuterVideo: {
                    showFinishSheet = false
                    showMuterVideoSheet = true
                },
                onShareRoute: {
                    showFinishSheet = false
                    showShareSheet = true
                },
                onDone: {
                    showFinishSheet = false
                    dismiss()
                }
            )
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheetView(route: route)
        }
        .sheet(isPresented: $showCollageSheet) {
            CollageEditorView(route: route)
        }
        .sheet(isPresented: $showMuterVideoSheet) {
            MuterVideoPreviewView(route: route)
        }
    }

    // MARK: - UI

    private var topControls: some View {
        HStack(spacing: 10) {
            Button {
                showCamera = true
            } label: {
                Image(systemName: "camera")
                    .font(.subheadline.weight(.semibold))
                    .padding(10)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
                    .accessibilityLabel("Take photo")
            }

            Spacer()

            // Toggle demo mode
            Button {
                isDemoNavigation.toggle()
                if isDemoNavigation {
                    locationManager.stopUpdating()
                    navModel.enableDemoMode()
                    logger.log("Switched to demo navigation")
                } else {
                    navModel.disableDemoMode()
                    logger.log("Switched to real GPS navigation")
                }
            } label: {
                Text(isDemoNavigation ? "GPS" : "Demo")
                    .font(.subheadline.weight(.semibold))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(isDemoNavigation ? .green.opacity(0.2) : .orange.opacity(0.2))
                    .clipShape(Capsule())
            }

            Button {
                logger.log("Exit button tapped - dismissing navigation view")
                dismiss()
            } label: {
                Label("Exit", systemImage: "xmark")
                    .font(.subheadline.weight(.semibold))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }

    private var turnByTurnCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(navModel.isAtLastStep ? "Arrived" : "Next")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)

                    Text(navModel.isAtLastStep ? "Arrive at destination" : navModel.currentInstruction)
                        .font(.title3.weight(.bold))
                        .foregroundStyle(.primary)
                        .lineLimit(3)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 6) {
                    Text("Step")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)

                    Text(navModel.progressText)
                        .font(.subheadline.weight(.semibold))
                }
            }

            Divider()

            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    distanceStatusView

                    Spacer()

                    if !route.landmarks.isEmpty {
                        Text("Stops: \(route.landmarks.count)")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }
                }

                if navModel.isAtLastStep {
                    Button {
                        finishWalk()
                    } label: {
                        Text("Finish Walk")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(route.routeColor.color)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                } else {
                    HStack {
                        Button {
                            finishWalk()
                        } label: {
                            Text("Finish Walk")
                                .font(.subheadline.weight(.semibold))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(route.routeColor.color.opacity(0.18))
                                .clipShape(Capsule())
                        }

                        Spacer()

                        if navModel.isDemoMode {
                            Button {
                                navModel.advanceStepManually()
                            } label: {
                                Text("Next")
                                    .font(.subheadline.weight(.semibold))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(route.routeColor.color.opacity(0.18))
                                    .clipShape(Capsule())
                            }
                        }
                    }

                    if navModel.isDemoMode {
                        Text("Demo navigation")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private var offRouteBanner: some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                Text("You’re off route")
                    .font(.subheadline.weight(.bold))

                if let d = navModel.offRouteDistanceMeters {
                    Text("~\(Int(d))m from the path")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Button {
                guard let user = locationManager.currentCoordinate else { return }
                navModel.reroute(from: user)
            } label: {
                Text("Re-route")
                    .font(.subheadline.weight(.semibold))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(route.routeColor.color.opacity(0.18))
                    .clipShape(Capsule())
            }
            .disabled(!navModel.canRerouteNow())
        }
        .padding(12)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    @ViewBuilder
    private var distanceStatusView: some View {
        if navModel.isDemoMode {
            Label("Demo", systemImage: "location.north.line")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
        } else if let meters = navModel.distanceToNextManeuverMeters {
            Label(distanceText(for: meters), systemImage: "location.north.line")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
        } else {
            HStack(spacing: 8) {
                ProgressView()
                    .controlSize(.small)
                Text(firstStepInstruction)
                    .lineLimit(1)
            }
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(.secondary)
        }
    }

    private var firstStepInstruction: String {
        if let first = route.navigationSteps?.first?.instruction, !first.isEmpty {
            return first
        }
        return navModel.currentInstruction
    }

    private func distanceText(for meters: CLLocationDistance) -> String {
        if meters < 1000 { return "\(Int(meters)) m" }
        return String(format: "%.1f km", meters / 1000)
    }

    // MARK: - Actions

    private func finishWalk() {
        RouteCompletionStore.markCompleted(route.id)
        showFinishSheet = true
    }

    private func savePhoto(image: UIImage) {
        // Store location:
        // - Prefer live GPS
        // - Else snap to nearest point on polyline
        // - Else step coordinate
        let live = locationManager.currentCoordinate
        let snapped = live.flatMap { PolylineMath.nearestPoint(onPolyline: route.pathCoordinates, to: $0) }
        let fallback = navModel.nextManeuverCoordinate
        let finalLocation = live ?? snapped ?? fallback

        _ = photoService.savePhoto(image: image, for: route.id, at: finalLocation)
    }
}

// MARK: - Map View

struct RouteMapViewRepresentable: UIViewRepresentable {
    let route: Route
    var routeColor: RouteColor = .canalRing
    var showsUserLocation: Bool = false
    var followUser: Bool = false
    var userCoordinate: CLLocationCoordinate2D?
    var showsNumberedPins: Bool = false
    var fitToRoute: Bool = false  // When true, fits map to show entire route + all landmarks

    private let logger = Logger(subsystem: "com.walkingroutes", category: "RouteMapView")

    func makeCoordinator() -> Coordinator { Coordinator(routeColor: routeColor, fitToRoute: fitToRoute) }

    func makeUIView(context: Context) -> MKMapView {
        logger.log("Creating MKMapView (fitToRoute: \(fitToRoute))")
        let mapView = MKMapView(frame: .zero)
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

        mapView.removeOverlays(mapView.overlays)
        mapView.removeAnnotations(mapView.annotations.filter { !($0 is MKUserLocation) })

        let points = route.pathCoordinates
        guard !points.isEmpty else {
            logger.warning("No path coordinates available for route: \(route.name)")
            return
        }

        // Add numbered annotations for landmarks
        if showsNumberedPins {
            for (index, landmark) in route.landmarks.enumerated() {
                let annotation = NumberedPointAnnotation()
                annotation.number = index + 1
                annotation.title = landmark.name
                annotation.subtitle = landmark.description
                annotation.coordinate = landmark.location.clLocation
                mapView.addAnnotation(annotation)
            }
        }

        // Calculate the bounding map rect that includes all landmarks
        let landmarkRects = route.landmarks.map { landmark in
            MKMapRect(origin: MKMapPoint(landmark.location.clLocation), size: MKMapSize(width: 0, height: 0))
        }
        let combinedRect = landmarkRects.reduce(MKMapRect.null) { $0.union($1) }
        context.coordinator.landmarksBoundingRect = combinedRect

        context.coordinator.drawWalkingRoute(points: points, on: mapView)

        if followUser, let userCoordinate {
            // Street-level zoom: ~500m span
            let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
            let region = MKCoordinateRegion(center: userCoordinate, span: span)
            mapView.setRegion(region, animated: true)
        } else if !fitToRoute, let firstPoint = points.first {
            // No user location yet: zoom to route start with street-level span
            let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            let region = MKCoordinateRegion(center: firstPoint, span: span)
            mapView.setRegion(region, animated: false)
        }
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var routeColor: RouteColor
        var fitToRoute: Bool
        var landmarksBoundingRect: MKMapRect = .null
        private var polylineCache: [String: MKPolyline] = [:]
        private var allPolylines: [MKPolyline] = []
        private let logger = Logger(subsystem: "com.walkingroutes", category: "MapCoordinator")

        init(routeColor: RouteColor, fitToRoute: Bool) {
            self.routeColor = routeColor
            self.fitToRoute = fitToRoute
        }

        func drawWalkingRoute(points: [CLLocationCoordinate2D], on mapView: MKMapView) {
            guard points.count >= 2 else {
                logger.warning("Not enough points to draw route: \(points.count)")
                return
            }

            allPolylines.removeAll()
            let group = DispatchGroup()

            for index in 0..<(points.count - 1) {
                let start = points[index]
                let end = points[index + 1]
                let key = "\(start.latitude),\(start.longitude)-\(end.latitude),\(end.longitude)"

                if let cached = polylineCache[key] {
                    mapView.addOverlay(cached)
                    allPolylines.append(cached)
                    continue
                }

                group.enter()
                let request = MKDirections.Request()
                request.source = MKMapItem(placemark: MKPlacemark(coordinate: start))
                request.destination = MKMapItem(placemark: MKPlacemark(coordinate: end))
                request.transportType = .walking

                let directions = MKDirections(request: request)
                directions.calculate { [weak self, weak mapView] response, error in
                    defer { group.leave() }
                    guard
                        let self,
                        let mapView
                    else { return }

                    if let error = error {
                        self.logger.error("Directions calculation failed: \(error.localizedDescription)")
                        // Fallback: draw straight line
                        let straightLine = MKPolyline(coordinates: [start, end], count: 2)
                        self.polylineCache[key] = straightLine
                        DispatchQueue.main.async {
                            mapView.addOverlay(straightLine)
                            self.allPolylines.append(straightLine)
                        }
                        return
                    }

                    guard let route = response?.routes.first else {
                        self.logger.warning("No route found between points")
                        return
                    }

                    let polyline = route.polyline
                    self.polylineCache[key] = polyline
                    DispatchQueue.main.async {
                        mapView.addOverlay(polyline)
                        self.allPolylines.append(polyline)
                    }
                }
            }

            // When all directions are calculated, fit the map to show everything
            group.notify(queue: .main) { [weak self, weak mapView] in
                guard let self, let mapView else { return }
                self.fitMapToShowAll(mapView: mapView)
            }
        }

        private func fitMapToShowAll(mapView: MKMapView) {
            guard fitToRoute else { return }

            // Combine all polyline bounding rects
            let routeRect = allPolylines.reduce(MKMapRect.null) { $0.union($1.boundingMapRect) }

            // Union with landmarks bounding rect
            let totalRect = routeRect.union(landmarksBoundingRect)

            guard !totalRect.isNull else {
                logger.warning("Cannot fit map: totalRect is null")
                return
            }

            // Add padding around the rect
            let padding = UIEdgeInsets(top: 60, left: 40, bottom: 60, right: 40)

            // Ensure minimum size for the rect (avoid zooming too far in for single points)
            var adjustedRect = totalRect
            let minSize: Double = 1000  // meters approximately
            if adjustedRect.size.width < minSize || adjustedRect.size.height < minSize {
                let center = MKMapPoint(x: adjustedRect.midX, y: adjustedRect.midY)
                let newSize = max(minSize, adjustedRect.size.width, adjustedRect.size.height)
                adjustedRect = MKMapRect(
                    x: center.x - newSize / 2,
                    y: center.y - newSize / 2,
                    width: newSize,
                    height: newSize
                )
            }

            mapView.setVisibleMapRect(adjustedRect, edgePadding: padding, animated: true)
            let segments = allPolylines.count
            let landmarksDesc = landmarksBoundingRect.isNull ? "0" : "multiple"
            logger.log("Fitted map to show route. Segments: \(segments). Landmarks: \(landmarksDesc).")
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            guard let polyline = overlay as? MKPolyline else { return MKOverlayRenderer(overlay: overlay) }
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = routeColor.uiColor
            renderer.lineWidth = 4
            renderer.lineJoin = .round
            renderer.lineCap = .round
            return renderer
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard let numbered = annotation as? NumberedPointAnnotation else { return nil }

            let identifier = "numbered-pin"
            let view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
                ?? MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)

            view.annotation = annotation
            view.markerTintColor = routeColor.uiColor
            view.glyphText = "\(numbered.number)"
            view.canShowCallout = true
            return view
        }
    }
}

final class NumberedPointAnnotation: MKPointAnnotation {
    var number: Int = 0
}

// MARK: - Location

final class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()

    @Published var currentCoordinate: CLLocationCoordinate2D?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined

    private let logger = Logger(subsystem: "com.walkingroutes", category: "LocationManager")

    var isAuthorized: Bool {
        switch authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            return true
        default:
            return false
        }
    }

    override init() {
        super.init()
        logger.log("LocationManager init")
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest

        refreshAuthorizationStatus()

        switch authorizationStatus {
        case .notDetermined:
            logger.log("Requesting when-in-use authorization")
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            logger.log("Already authorized, starting updates")
            manager.startUpdatingLocation()
        case .denied, .restricted:
            logger.warning("Location access denied or restricted")
        @unknown default:
            logger.warning("Unknown authorization status")
        }
    }

    func requestAuthorizationIfNeeded() {
        refreshAuthorizationStatus()
        if authorizationStatus == .notDetermined {
            manager.requestWhenInUseAuthorization()
        }
    }

    private func refreshAuthorizationStatus() {
        if #available(iOS 14.0, *) {
            authorizationStatus = manager.authorizationStatus
        } else {
            authorizationStatus = CLLocationManager.authorizationStatus()
        }
        logger.log("Current authorization status: \(String(describing: self.authorizationStatus))")
    }

    func stopUpdating() {
        logger.log("Stopping location updates")
        manager.stopUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        logger.log("Location updated: lat=\(location.coordinate.latitude), lon=\(location.coordinate.longitude)")
        currentCoordinate = location.coordinate
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        logger.error("Location manager failed: \(error.localizedDescription)")
    }

    @available(iOS 14.0, *)
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        logger.log("Authorization changed to: \(String(describing: manager.authorizationStatus))")
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
        case .denied, .restricted:
            logger.warning("Authorization denied/restricted after change")
        case .notDetermined:
            break
        @unknown default:
            break
        }
    }
}

// MARK: - UIImagePickerController bridge

private struct ImagePicker: UIViewControllerRepresentable {
    let sourceType: UIImagePickerController.SourceType
    let onImagePicked: (UIImage) -> Void

    @Environment(\.dismiss) private var dismiss

    func makeCoordinator() -> Coordinator { Coordinator(parent: self) }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.allowsEditing = false
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    final class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker

        init(parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.onImagePicked(image)
            }
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

#Preview {
    let previewRoute = Route(
        id: UUID(),
        name: "Preview Loop",
        description: "A simple loop route used for previews.",
        duration: 60,
        distance: 4.8,
        difficulty: .easy,
        category: .highlights,
        landmarks: Array(PointsOfInterest.all.prefix(2)),
        coordinates: [
            Location(latitude: 52.3780, longitude: 4.9006),
            Location(latitude: 52.3810, longitude: 4.9100),
            Location(latitude: 52.3720, longitude: 4.9150),
            Location(latitude: 52.3780, longitude: 4.9006)
        ],
        navigationSteps: nil,
        imageURL: nil,
        city: nil
    )

    return RouteNavigationView(route: previewRoute, useLocation: false)
}
