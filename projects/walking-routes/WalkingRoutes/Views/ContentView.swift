import SwiftUI
import CoreLocation

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
    @State private var locationManager: LocationManager?
    @State private var selectedTime: Int
    @State private var showFeedback = false
    var useLocation: Bool = true

    init(initialSelectedTime: Int = 60, useLocation: Bool = true) {
        _selectedTime = State(initialValue: initialSelectedTime)
        self.useLocation = useLocation
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    headerSection

                    TimeSelectorView(selectedTime: $selectedTime)
                        .onChange(of: selectedTime) { newTime in
                            viewModel.filterRoutes(by: newTime)
                        }

                    if !viewModel.nearbyRoutes.isEmpty {
                        nearbySection
                    }

                    Text("All Routes")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(AppTheme.primaryText)

                    VStack(spacing: 16) {
                        ForEach(viewModel.filteredRoutes) { route in
                            NavigationLink(destination: RouteDetailView(route: route)) {
                                RouteCard(route: route)
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    // Feedback Button
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
            viewModel.filterRoutes(by: selectedTime)
            if useLocation {
                setupLocationManager()
            }
        }
    }

    private func setupLocationManager() {
        do {
            locationManager = LocationManager()
        } catch {
            print("[ContentView] Failed to setup LocationManager: \(error.localizedDescription)")
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 30))
                    .foregroundStyle(AppTheme.primaryColor)
                Spacer()
                Text("Walking Routes")
                    .font(.headline)
                    .foregroundStyle(AppTheme.primaryText)
                Spacer()
                Color.clear.frame(width: 30, height: 30)
            }

            Text("Discover Amsterdam")
                .font(.title2.weight(.bold))
                .foregroundStyle(AppTheme.primaryText)

            Text("\(viewModel.filteredRoutes.count) walking routes")
                .font(.system(size: 34, weight: .heavy, design: .rounded))
                .foregroundStyle(AppTheme.primaryText)
        }
    }

    private var nearbySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "location.fill")
                    .foregroundStyle(AppTheme.primaryColor)
                Text("Near You")
                    .font(.title3.weight(.bold))
                Spacer()
            }

            Text("Routes starting nearby")
                .font(.subheadline)
                .foregroundStyle(AppTheme.secondaryText)

            ForEach(viewModel.nearbyRoutes.prefix(2)) { route in
                NavigationLink(destination: RouteDetailView(route: route)) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(route.name)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(AppTheme.primaryText)
                            Text(viewModel.distanceText(for: route))
                                .font(.caption)
                                .foregroundStyle(AppTheme.secondaryText)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.secondary)
                    }
                    .padding(12)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .buttonStyle(.plain)
            }
        }
    }
}

struct RouteCard: View {
    let route: Route

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack(alignment: .topTrailing) {
                AsyncImage(url: URL(string: route.imageURL ?? "")) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure(_):
                        Rectangle().fill(Color.gray.opacity(0.25))
                    case .empty:
                        Rectangle().fill(Color.gray.opacity(0.2))
                    @unknown default:
                        Rectangle().fill(Color.gray.opacity(0.2))
                    }
                }
                .frame(maxWidth: .infinity)
                .aspectRatio(16/9, contentMode: .fill)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .overlay(alignment: .bottom) {
                    LinearGradient(
                        colors: [.clear, .black.opacity(0.55)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                }

                Text("\(route.duration)\nmin")
                    .font(.caption.weight(.bold))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(AppTheme.primaryColor)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(12)
            }

            Text(route.name)
                .font(.title3.weight(.bold))
                .foregroundStyle(AppTheme.primaryText)

            Text(route.description)
                .font(.subheadline)
                .foregroundStyle(AppTheme.secondaryText)
                .lineLimit(2)

            HStack(spacing: 8) {
                Label(String(format: "%.1f", route.averageRating), systemImage: "star.fill")
                Text("•")
                Text(String(format: "%.1f km", route.distance))
            }
            .font(.caption.weight(.semibold))
            .foregroundStyle(AppTheme.secondaryText)
        }
        .padding(12)
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.10), radius: 10, x: 0, y: 4)
    }
}

#Preview {
    ContentView()
}
