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

    // Food spots the user has opted to add to their walk
    @State private var addedFoodSpotIDs: Set<UUID> = []

    private var culturalLandmarks: [Landmark] { route.landmarks.filter { !$0.isFoodSpot } }
    private var foodLandmarks: [Landmark]     { route.landmarks.filter {  $0.isFoodSpot } }
    private var addedFoodSpots: [Landmark]    { foodLandmarks.filter { addedFoodSpotIDs.contains($0.id) } }

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

                // Map — cultural pins always visible, teal food pins appear when added
                RouteMapViewRepresentable(
                    route: route,
                    routeColor: route.routeColor,
                    showsNumberedPins: true,
                    fitToRoute: true,
                    addedFoodSpots: addedFoodSpots
                )
                .frame(height: 260)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding(.horizontal)

                // Cultural landmarks section
                landmarksSection

                // Food & café stops section
                if !foodLandmarks.isEmpty {
                    walkPastSection
                }

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
        // Lazy navigation — RouteNavigationView is only created when showNavigation becomes true.
        // NavigationLink(destination:isActive:) is eager (creates destination on every render) and causes freezes.
        .navigationDestination(isPresented: $showNavigation) {
            RouteNavigationView(route: route, useLocation: AppFlags.useRealGPSNavigation)
        }
        .sheet(item: $selectedLandmark) { landmark in
            LandmarkDetailView(
                landmark: landmark,
                isAddedToWalk: landmark.isFoodSpot ? addedFoodSpotIDs.contains(landmark.id) : nil,
                onAddToWalk: landmark.isFoodSpot ? {
                    if addedFoodSpotIDs.contains(landmark.id) {
                        addedFoodSpotIDs.remove(landmark.id)
                    } else {
                        addedFoodSpotIDs.insert(landmark.id)
                    }
                } : nil
            )
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

                    if !culturalLandmarks.isEmpty {
                        Text("\(culturalLandmarks.count) stops along your route")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                if culturalLandmarks.count > 2 {
                    Button("See All") {
                        showAllLandmarks = true
                    }
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(AppTheme.primaryColor)
                }
            }
            .padding(.horizontal)

            if culturalLandmarks.isEmpty {
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
                // Show first 2 cultural landmarks with full cards
                VStack(spacing: 12) {
                    ForEach(Array(culturalLandmarks.prefix(2).enumerated()), id: \.element.id) { index, landmark in
                        LandmarkCard(
                            landmark: landmark,
                            index: index + 1,
                            routeColor: route.routeColor.color,
                            estimatedWalkTime: estimatedWalkTime(to: landmark)
                        )
                        .onTapGesture { selectedLandmark = landmark }
                        .padding(.horizontal)
                    }
                }

                // Show "more landmarks" preview if there are more
                if culturalLandmarks.count > 2 {
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

                            Text("+\(culturalLandmarks.count - 2) more landmarks")
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
                let bookableCount = culturalLandmarks.filter(\.isBookable).count
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

    // MARK: - Walk Past (food & café spots)

    private var walkPastSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 6) {
                Image(systemName: "fork.knife")
                    .foregroundStyle(Color.teal)
                Text("You'll walk past")
                    .font(.title3.weight(.bold))
                Spacer()
                Text("\(foodLandmarks.count) spots")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal)

            Text("Restaurants & cafés along this route. Add the ones you like — they'll appear as teal pins on the map.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal)

            VStack(spacing: 12) {
                ForEach(foodLandmarks) { spot in
                    FoodSpotCard(
                        spot: spot,
                        isAdded: addedFoodSpotIDs.contains(spot.id)
                    ) {
                        if addedFoodSpotIDs.contains(spot.id) {
                            addedFoodSpotIDs.remove(spot.id)
                        } else {
                            addedFoodSpotIDs.insert(spot.id)
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        }
                    } onTap: {
                        selectedLandmark = spot
                    }
                    .padding(.horizontal)
                }
            }
        }
    }

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

// MARK: - FoodSpotCard

private struct FoodSpotCard: View {
    let spot: Landmark
    let isAdded: Bool
    let onToggle: () -> Void
    let onTap: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            // Photo or placeholder
            AsyncImage(url: URL(string: spot.imageURL ?? "")) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFill()
                default:
                    Color(.systemGray5)
                        .overlay(Image(systemName: "fork.knife").foregroundStyle(.secondary))
                }
            }
            .frame(width: 64, height: 64)
            .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 4) {
                Text(spot.name)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)

                if let rating = spot.rating {
                    HStack(spacing: 3) {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundStyle(.orange)
                        Text(String(format: "%.1f", rating))
                            .font(.caption.weight(.medium))
                        if let count = spot.admissionFee {
                            Text("· \(count)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                if let hours = spot.openingHours {
                    Text(hours)
                        .font(.caption)
                        .foregroundStyle(hours.lowercased().hasPrefix("open") ? .green : .secondary)
                        .lineLimit(1)
                }
            }
            .onTapGesture { onTap() }

            Spacer()

            Button(action: onToggle) {
                if isAdded {
                    Label("Added", systemImage: "checkmark.circle.fill")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10).padding(.vertical, 6)
                        .background(Color.teal)
                        .clipShape(Capsule())
                } else {
                    Label("Add", systemImage: "plus.circle")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.teal)
                        .padding(.horizontal, 10).padding(.vertical, 6)
                        .background(Color.teal.opacity(0.1))
                        .clipShape(Capsule())
                }
            }
        }
        .padding(12)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
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
