import SwiftUI
import CoreLocation
import os.log
import UIKit

struct AppTheme {
    static let primaryColor = Color(red: 255/255, green: 107/255, blue: 53/255)
    static let primaryLight = Color(red: 255/255, green: 230/255, blue: 220/255)
    static let backgroundColor = Color.white
    static let cardBackground = Color.white
    static let secondaryBackground = Color(red: 248/255, green: 249/255, blue: 250/255)
    static let primaryText = Color.black
    static let secondaryText = Color.gray
}

struct ContentView: View {
    @StateObject private var viewModel = RouteViewModel()
    @StateObject private var locationManager = LocationManager()

    @State private var selectedTime: Int
    @State private var showFeedback = false
    @AppStorage("forceDemoLocation") private var forceDemoLocation: Bool = true
    @AppStorage("lockTimeTo60") private var lockTimeTo60: Bool = true

    var useLocation: Bool = true

    private let logger = Logger(subsystem: "com.walkingroutes", category: "ContentView")

    init(initialSelectedTime: Int = 60, useLocation: Bool = true) {
        _selectedTime = State(initialValue: initialSelectedTime)
        self.useLocation = useLocation
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    headerSection

                    Toggle("Demo location (Amsterdam)", isOn: $forceDemoLocation)
                        .font(.caption.weight(.semibold))
                        .tint(AppTheme.primaryColor)

                    if useLocation, !forceDemoLocation {
                        locationStatusCard
                    } else if useLocation, forceDemoLocation {
                        Text("Using demo start point (Amsterdam Centraal)")
                            .font(.caption)
                            .foregroundStyle(AppTheme.secondaryText)
                    } else {
                        Text("Location disabled (preview/demo mode)")
                            .font(.caption)
                            .foregroundStyle(AppTheme.secondaryText)
                    }

                    TimeSelectorView(selectedTime: $selectedTime)
                        .disabled(lockTimeTo60)
                        .onChange(of: selectedTime) { _ in
                            guard !lockTimeTo60 else { return }
                            regenerate()
                        }

                    if lockTimeTo60 {
                        Text("Demo: time locked to 60 min")
                            .font(.caption)
                            .foregroundStyle(AppTheme.secondaryText)
                    }

                    if viewModel.isLoading {
                        HStack(spacing: 12) {
                            ProgressView()
                            Text("Generating loops…")
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 10)
                    }

                    if let error = viewModel.errorMessage {
                        Text(error)
                            .font(.subheadline)
                            .foregroundStyle(.red)
                            .padding(.vertical, 4)
                    }

                    if viewModel.usingDemoLocation {
                        Text("Using Amsterdam Centraal as a demo start point. Enable location for routes around you.")
                            .font(.caption)
                            .foregroundStyle(AppTheme.secondaryText)
                            .padding(.horizontal, 4)
                    }

                    Text("Loop Options")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(AppTheme.primaryText)

                    VStack(spacing: 16) {
                        ForEach(viewModel.routes) { route in
                            NavigationLink(destination: RouteDetailView(route: route)) {
                                RouteCard(route: route)
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    Button {
                        showFeedback = true
                    } label: {
                        HStack {
                            Image(systemName: "envelope.bubble.fill")
                            Text("Send Feedback")
                        }
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(AppTheme.primaryColor)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(AppTheme.primaryColor.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.top, 8)
                }
                .padding()
            }
            .background(AppTheme.secondaryBackground.ignoresSafeArea())
            .navigationBarHidden(true)
            .sheet(isPresented: $showFeedback) {
                FeedbackView()
            }
        }
        .onAppear {
            if lockTimeTo60 { selectedTime = 60 }
            regenerate()
        }
        .onReceive(locationManager.$currentCoordinate) { _ in
            // Only regenerate on live GPS when we're not forcing demo location.
            guard useLocation, !forceDemoLocation else { return }
            regenerate()
        }
        .onChange(of: locationManager.authorizationStatus) { _ in
            guard useLocation, !forceDemoLocation else { return }
            regenerate()
        }
    }

    private func regenerate() {
        logger.log("Regenerating routes. minutes=\(selectedTime)")
        let authorized = useLocation ? locationManager.isAuthorized : false
        let coordinate = useLocation ? locationManager.currentCoordinate : nil
        viewModel.generateRoutes(timeMinutes: selectedTime, userCoordinate: coordinate, locationAuthorized: authorized)
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "figure.walk.circle.fill")
                    .font(.system(size: 30))
                    .foregroundStyle(AppTheme.primaryColor)
                Spacer()
                Text("Walking Routes")
                    .font(.headline)
                    .foregroundStyle(AppTheme.primaryText)
                Spacer()
                Color.clear.frame(width: 30, height: 30)
            }

            Text("Pick a time. Get a loop.")
                .font(.title2.weight(.bold))
                .foregroundStyle(AppTheme.primaryText)

            Text("\(viewModel.routes.count) loop options")
                .font(.system(size: 34, weight: .heavy, design: .rounded))
                .foregroundStyle(AppTheme.primaryText)
        }
    }

    private var locationStatusCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            switch locationManager.authorizationStatus {
            case .authorizedAlways, .authorizedWhenInUse:
                HStack(spacing: 8) {
                    Image(systemName: "location.fill")
                        .foregroundStyle(.green)
                    Text("Using your current location")
                        .font(.subheadline.weight(.semibold))
                    Spacer()
                }
                if let c = locationManager.currentCoordinate {
                    Text(String(format: "lat %.4f, lon %.4f", c.latitude, c.longitude))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    Text("Waiting for GPS fix…")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

            case .notDetermined:
                HStack(spacing: 8) {
                    Image(systemName: "location.slash")
                        .foregroundStyle(.orange)
                    Text("Enable location for routes around you")
                        .font(.subheadline.weight(.semibold))
                    Spacer()
                }
                Button("Allow Location") {
                    locationManager.requestAuthorizationIfNeeded()
                }
                .font(.caption.weight(.semibold))

            case .denied, .restricted:
                HStack(spacing: 8) {
                    Image(systemName: "location.slash")
                        .foregroundStyle(.red)
                    Text("Location permission is off")
                        .font(.subheadline.weight(.semibold))
                    Spacer()
                }
                Text("We'll use a demo start point (Amsterdam Centraal). To use your location, enable it in Settings.")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Button("Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                .font(.caption.weight(.semibold))

            @unknown default:
                EmptyView()
            }
        }
        .padding(12)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

// MARK: - Route Card

private struct RouteCard: View {
    let route: Route

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(route.name)
                        .font(.title3.weight(.bold))
                        .foregroundStyle(AppTheme.primaryText)
                    Text(route.description)
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.secondaryText)
                        .lineLimit(2)
                }
                Spacer()
                Text("\(route.duration)\nmin")
                    .font(.caption.weight(.bold))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(AppTheme.primaryColor)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }

            HStack(spacing: 8) {
                Image(systemName: "figure.walk")
                Text(String(format: "%.1f km", route.distance))
                Text("•")
                Text(route.difficulty.rawValue.capitalized)
            }
            .font(.caption.weight(.semibold))
            .foregroundStyle(AppTheme.secondaryText)
        }
        .padding(12)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 3)
    }
}

#Preview {
    ContentView(useLocation: false)
}
