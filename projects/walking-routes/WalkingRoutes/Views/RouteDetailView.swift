import SwiftUI
import MapKit
import os.log

struct RouteDetailView: View {
    let route: Route
    @State private var selectedLandmark: Landmark? = nil
    @State private var showNavigation = false
    @State private var showAllLandmarks = false

    @State private var showShareSheet = false
    @State private var showPhotosSheet = false
    @State private var showCollageSheet = false

    private let logger = Logger(subsystem: "com.walkingroutes", category: "RouteDetailView")

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HeroSection(route: route)

                // Route stats
                routeStatsSection
                    .padding(.horizontal)

                // Description
                VStack(alignment: .leading, spacing: 8) {
                    Text("About this route")
                        .font(.title3.weight(.bold))

                    Text(route.description)
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .lineSpacing(4)
                }
                .padding(.horizontal)

                // Start button
                Button {
                    showNavigation = true
                } label: {
                    HStack {
                        Image(systemName: "figure.walk.motion")
                        Text("Start Walking")
                    }
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppTheme.primaryColor)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding(.horizontal)

                // Map
                RouteMapViewRepresentable(route: route, routeColor: route.routeColor, showsNumberedPins: true, fitToRoute: true)
                    .frame(height: 260)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .padding(.horizontal)

                // Landmarks section
                landmarksSection

                // Photo credit
                Text("Photos: Wikimedia Commons")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .background(AppTheme.secondaryBackground)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $selectedLandmark) { landmark in
            LandmarkDetailView(landmark: landmark)
        }
        .sheet(isPresented: $showAllLandmarks) {
            NavigationStack {
                LandmarkListView(
                    landmarks: route.landmarks,
                    title: "Route Landmarks",
                    showGrouping: true
                )
            }
        }
        .fullScreenCover(isPresented: $showNavigation) {
            // Default to demo navigation (no GPS) for smoother demos. Real GPS nav can be enabled via UserDefaults.
            RouteNavigationView(route: route, useLocation: AppFlags.useRealGPSNavigation)
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheetView(route: route)
        }
        .sheet(isPresented: $showPhotosSheet) {
            // RouteDetailView is pre-walk; location is optional here.
            PhotoCaptureView(routeId: route.id, currentLocation: nil)
        }
        .sheet(isPresented: $showCollageSheet) {
            CollageEditorView(route: route)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        showShareSheet = true
                    } label: {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }

                    Button {
                        showPhotosSheet = true
                    } label: {
                        Label("Photos", systemImage: "camera")
                    }

                    Button {
                        showCollageSheet = true
                    } label: {
                        Label("Create Collage", systemImage: "photo.on.rectangle.angled")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
    }

    // MARK: - Sections

    private var routeStatsSection: some View {
        HStack(spacing: 16) {
            StatItem(
                icon: "clock",
                value: "\(route.duration)m",
                label: "Duration"
            )

            Divider()
                .frame(height: 40)

            StatItem(
                icon: "figure.walk",
                value: String(format: "%.1f km", route.distance),
                label: "Distance"
            )

            Divider()
                .frame(height: 40)

            StatItem(
                icon: "mappin",
                value: "\(route.landmarks.count)",
                label: "Stops"
            )

            if route.averageRating > 0 {
                Divider()
                    .frame(height: 40)

                StatItem(
                    icon: "star.fill",
                    value: String(format: "%.1f", route.averageRating),
                    label: "Rating",
                    iconColor: .yellow
                )
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var landmarksSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Highlights")
                        .font(.title3.weight(.bold))

                    if !route.landmarks.isEmpty {
                        Text("\(route.landmarks.count) stops along your route")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                if route.landmarks.count > 2 {
                    Button("See All") {
                        showAllLandmarks = true
                    }
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(AppTheme.primaryColor)
                }
            }
            .padding(.horizontal)

            if route.landmarks.isEmpty {
                // Empty state
                VStack(spacing: 12) {
                    Image(systemName: "mappin.slash")
                        .font(.system(size: 40))
                        .foregroundStyle(.secondary)

                    Text("No landmarks on this route")
                        .font(.headline)

                    Text("Enjoy the scenery as you walk!")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal)
            } else {
                // Show first 2 landmarks with full cards
                VStack(spacing: 12) {
                    ForEach(Array(route.landmarks.prefix(2).enumerated()), id: \.element.id) { index, landmark in
                        LandmarkCard(
                            landmark: landmark,
                            index: index + 1,
                            routeColor: route.routeColor.color,
                            estimatedWalkTime: estimatedWalkTime(to: landmark)
                        )
                        .padding(.horizontal)
                    }
                }

                // Show "more landmarks" preview if there are more
                if route.landmarks.count > 2 {
                    Button {
                        showAllLandmarks = true
                    } label: {
                        HStack {
                            // Thumbnail stack
                            HStack(spacing: -8) {
                                ForEach(Array(route.landmarks.dropFirst(2).prefix(3)), id: \.id) { landmark in
                                    AsyncImage(url: URL(string: landmark.imageURL ?? "")) { phase in
                                        switch phase {
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .scaledToFill()
                                        default:
                                            Color.gray
                                        }
                                    }
                                    .frame(width: 32, height: 32)
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white, lineWidth: 2)
                                    )
                                }
                            }

                            Text("+\(route.landmarks.count - 2) more landmarks")
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(.primary)

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(12)
                        .background(Color(.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal)
                }

                // Bookable landmarks indicator
                let bookableCount = route.landmarks.filter(\.isBookable).count
                if bookableCount > 0 {
                    HStack {
                        Image(systemName: "ticket.fill")
                            .foregroundStyle(AppTheme.primaryColor)
                        Text("\(bookableCount) bookable attraction\(bookableCount == 1 ? "" : "s") on this route")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal)
                }
            }
        }
    }

    // MARK: - Helpers

    private func estimatedWalkTime(to landmark: Landmark) -> Int? {
        // Simple estimation based on distance from start
        // In a real app, this would use the actual route geometry
        guard let firstCoord = route.pathCoordinates.first else { return nil }
        let landmarkCoord = landmark.location.clLocation
        let distance = CLLocation(latitude: firstCoord.latitude, longitude: firstCoord.longitude)
            .distance(from: CLLocation(latitude: landmarkCoord.latitude, longitude: landmarkCoord.longitude))

        // Assuming 4.8 km/h walking speed
        let minutes = Int((distance / 1000.0) / 4.8 * 60.0)
        return minutes > 0 ? minutes : nil
    }
}

// MARK: - Supporting Views

private struct StatItem: View {
    let icon: String
    let value: String
    let label: String
    var iconColor: Color? = nil

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(iconColor ?? AppTheme.primaryColor)

            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.primary)

            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct HeroSection: View {
    let route: Route
    private let logger = Logger(subsystem: "com.walkingroutes", category: "HeroSection")

    private var imageURL: URL? {
        guard let urlString = route.imageURL, !urlString.isEmpty else {
            logger.debug("No imageURL for route: \(route.name)")
            return nil
        }
        guard let url = URL(string: urlString) else {
            logger.warning("Invalid imageURL for route: \(route.name) - '\(urlString)'")
            return nil
        }
        return url
    }

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            if let url = imageURL {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure(let error):
                        placeholderView
                            .overlay(
                                Image(systemName: "photo")
                                    .font(.largeTitle)
                                    .foregroundStyle(.gray)
                            )
                            .onAppear {
                                logger.error("Failed to load hero image for '\(route.name)': \(error.localizedDescription)")
                            }
                    case .empty:
                        placeholderView
                            .overlay(ProgressView())
                    @unknown default:
                        placeholderView
                    }
                }
            } else {
                placeholderView
                    .overlay(
                        Image(systemName: "photo")
                            .font(.largeTitle)
                            .foregroundStyle(.gray)
                    )
            }

            LinearGradient(colors: [.clear, .black.opacity(0.55)], startPoint: .top, endPoint: .bottom)
                .clipShape(RoundedRectangle(cornerRadius: 20))

            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .firstTextBaseline, spacing: 10) {
                    Text(route.name)
                        .font(.title2.weight(.bold))
                        .foregroundStyle(.white)

                    if RouteCompletionStore.isCompleted(route.id) {
                        Text("Completed")
                            .font(.caption.weight(.semibold))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(.white.opacity(0.18))
                            .foregroundStyle(.white)
                            .clipShape(Capsule())
                            .accessibilityLabel("Route completed")
                    }

                    Spacer(minLength: 0)
                }

                HStack(spacing: 8) {
                    if route.averageRating > 0 {
                        Label(String(format: "%.1f", route.averageRating), systemImage: "star.fill")
                    }
                    if route.averageRating > 0 {
                        Text("•")
                    }
                    Text("\(route.duration) min")
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
            }
            .padding()
        }
        .frame(height: 280)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
        .padding(.horizontal)
    }

    private var placeholderView: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.2))
            .frame(height: 280)
            .frame(maxWidth: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

// MARK: - Preview

#Preview {
    let previewRoute = Route(
        id: UUID(),
        name: "Museum Quarter Walk",
        description: "A scenic walk through Amsterdam's famous Museumplein, featuring world-class museums and beautiful green spaces.",
        duration: 90,
        distance: 4.5,
        difficulty: .easy,
        category: .highlights,
        landmarks: Array(PointsOfInterest.all.prefix(4)),
        coordinates: [
            Location(latitude: 52.3780, longitude: 4.9006),
            Location(latitude: 52.3810, longitude: 4.9100),
            Location(latitude: 52.3720, longitude: 4.9150),
            Location(latitude: 52.3780, longitude: 4.9006)
        ],
        navigationSteps: nil,
        imageURL: nil,
        city: "Amsterdam"
    )

    NavigationStack {
        RouteDetailView(route: previewRoute)
    }
}
