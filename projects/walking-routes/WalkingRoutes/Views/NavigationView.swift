import SwiftUI
import MapKit
import CoreLocation
import os.log

struct RouteNavigationView: View {
    let route: Route
    var useLocation: Bool = true
    @Environment(\.dismiss) private var dismiss
    @State private var locationManager: LocationManager?
    @State private var currentStopIndex: Int = 0
    @State private var arrivedMessage: String?
    @State private var mapError: Error?

    private let logger = Logger(subsystem: "com.walkingroutes", category: "NavigationView")

    private var currentLandmark: Landmark? {
        guard route.landmarks.indices.contains(currentStopIndex) else { return nil }
        return route.landmarks[currentStopIndex]
    }

    var body: some View {
        ZStack {
            RouteMapViewRepresentable(
                route: route,
                routeColor: route.routeColor,
                showsUserLocation: useLocation,
                followUser: useLocation,
                userCoordinate: useLocation ? locationManager?.currentCoordinate : nil,
                showsNumberedPins: true
            )
            .ignoresSafeArea()

            VStack {
                HStack {
                    Spacer()
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

                Spacer()

                if let landmark = currentLandmark {
                    NextLandmarkCard(
                        landmark: landmark,
                        routeColor: route.routeColor.color,
                        stopIndex: currentStopIndex + 1,
                        totalStops: route.landmarks.count,
                        distanceText: distanceText(to: landmark),
                        directionHint: directionHint(to: landmark)
                    )
                    .padding()
                }
            }

            if let arrivedMessage {
                VStack {
                    Text(arrivedMessage)
                        .font(.subheadline.weight(.semibold))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(.regularMaterial)
                        .clipShape(Capsule())
                        .padding(.top, 60)
                    Spacer()
                }
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .onAppear {
            logger.log("NavigationView appeared for route: \(route.name)")
            if useLocation {
                setupLocationManager()
            }
        }
        .onDisappear {
            logger.log("NavigationView disappeared")
            locationManager?.stopUpdating()
            locationManager = nil
        }
    }

    private func setupLocationManager() {
        do {
            locationManager = LocationManager()
            logger.log("LocationManager initialized successfully")
        } catch {
            logger.error("Failed to initialize LocationManager: \(error.localizedDescription)")
            mapError = error
        }
    }

    private func checkArrival() {
        guard
            let lm = locationManager,
            let user = lm.currentCoordinate,
            let landmark = currentLandmark
        else { return }

        let userLocation = CLLocation(latitude: user.latitude, longitude: user.longitude)
        let targetLocation = CLLocation(
            latitude: landmark.location.latitude,
            longitude: landmark.location.longitude
        )

        let distance = userLocation.distance(from: targetLocation)
        guard distance < 60 else { return }

        withAnimation {
            arrivedMessage = "Arrived at \(landmark.name)"
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
            withAnimation { arrivedMessage = nil }
        }

        if currentStopIndex < route.landmarks.count - 1 {
            currentStopIndex += 1
        }
    }

    private func distanceText(to landmark: Landmark) -> String {
        guard let lm = locationManager, let user = lm.currentCoordinate else { return "Locating..." }
        let userLocation = CLLocation(latitude: user.latitude, longitude: user.longitude)
        let target = CLLocation(latitude: landmark.location.latitude, longitude: landmark.location.longitude)
        let meters = userLocation.distance(from: target)
        let minutes = max(1, Int(meters / 75))
        if meters < 1000 {
            return "\(Int(meters))m ahead • ~\(minutes) min walk"
        }
        return String(format: "%.1f km ahead • ~%d min walk", meters / 1000, minutes)
    }

    private func directionHint(to landmark: Landmark) -> String {
        guard let lm = locationManager, let user = lm.currentCoordinate else { return "Finding your position..." }

        let latDelta = landmark.location.latitude - user.latitude
        let lonDelta = landmark.location.longitude - user.longitude

        if abs(latDelta) > abs(lonDelta) {
            return latDelta > 0 ? "⬆️ Head north" : "⬇️ Head south"
        } else {
            return lonDelta > 0 ? "➡️ Head east" : "⬅️ Head west"
        }
    }
}

private struct NextLandmarkCard: View {
    let landmark: Landmark
    let routeColor: Color
    let stopIndex: Int
    let totalStops: Int
    let distanceText: String
    let directionHint: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Stop \(stopIndex) of \(totalStops)")
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(routeColor.opacity(0.15))
                    .foregroundStyle(routeColor)
                    .clipShape(Capsule())
                Spacer()
                Text(distanceText)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }

            Text(landmark.name)
                .font(.title3.weight(.bold))

            Text(directionHint)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text(landmark.description)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .lineLimit(2)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}

struct RouteMapViewRepresentable: UIViewRepresentable {
    let route: Route
    var routeColor: RouteColor = .canalRing
    var showsUserLocation: Bool = false
    var followUser: Bool = false
    var userCoordinate: CLLocationCoordinate2D?
    var showsNumberedPins: Bool = false

    private let logger = Logger(subsystem: "com.walkingroutes", category: "RouteMapView")

    func makeCoordinator() -> Coordinator { Coordinator(routeColor: routeColor) }

    func makeUIView(context: Context) -> MKMapView {
        logger.log("Creating MKMapView")
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
        mapView.showsUserLocation = showsUserLocation

        mapView.removeOverlays(mapView.overlays)
        mapView.removeAnnotations(mapView.annotations.filter { !($0 is MKUserLocation) })

        let points = route.pathCoordinates
        guard !points.isEmpty else {
            logger.warning("No path coordinates available for route: \(route.name)")
            return
        }

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

        context.coordinator.drawWalkingRoute(points: points, on: mapView)

        if followUser, let userCoordinate {
            mapView.setCenter(userCoordinate, animated: true)
        } else if points.count >= 2 {
            let fallback = MKPolyline(coordinates: points, count: points.count)
            mapView.setVisibleMapRect(
                fallback.boundingMapRect,
                edgePadding: UIEdgeInsets(top: 60, left: 30, bottom: 60, right: 30),
                animated: true
            )
        }
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var routeColor: RouteColor
        private var polylineCache: [String: MKPolyline] = [:]
        private let logger = Logger(subsystem: "com.walkingroutes", category: "MapCoordinator")

        init(routeColor: RouteColor) {
            self.routeColor = routeColor
        }

        func drawWalkingRoute(points: [CLLocationCoordinate2D], on mapView: MKMapView) {
            guard points.count >= 2 else {
                logger.warning("Not enough points to draw route: \(points.count)")
                return
            }

            for index in 0..<(points.count - 1) {
                let start = points[index]
                let end = points[index + 1]
                let key = "\(start.latitude),\(start.longitude)-\(end.latitude),\(end.longitude)"

                if let cached = polylineCache[key] {
                    mapView.addOverlay(cached)
                    continue
                }

                let request = MKDirections.Request()
                request.source = MKMapItem(placemark: MKPlacemark(coordinate: start))
                request.destination = MKMapItem(placemark: MKPlacemark(coordinate: end))
                request.transportType = .walking

                let directions = MKDirections(request: request)
                directions.calculate { [weak self, weak mapView] response, error in
                    guard
                        let self,
                        let mapView
                    else { return }

                    if let error = error {
                        self.logger.error("Directions calculation failed: \(error.localizedDescription)")
                        return
                    }

                    guard let route = response?.routes.first else {
                        self.logger.warning("No route found between points")
                        return
                    }

                    let polyline = route.polyline
                    self.polylineCache[key] = polyline
                    mapView.addOverlay(polyline)

                    if index == 0 {
                        mapView.setVisibleMapRect(
                            polyline.boundingMapRect,
                            edgePadding: UIEdgeInsets(top: 60, left: 30, bottom: 60, right: 30),
                            animated: true
                        )
                    }
                }
            }
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

final class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    @Published var currentCoordinate: CLLocationCoordinate2D?

    private let logger = Logger(subsystem: "com.walkingroutes", category: "LocationManager")

    override init() {
        super.init()
        logger.log("LocationManager init")
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest

        let authorizationStatus: CLAuthorizationStatus
        if #available(iOS 14.0, *) {
            authorizationStatus = manager.authorizationStatus
        } else {
            authorizationStatus = CLLocationManager.authorizationStatus()
        }

        logger.log("Current authorization status: \(String(describing: authorizationStatus))")

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

#Preview {
    RouteNavigationView(route: SampleData.routes[0], useLocation: false)
}
