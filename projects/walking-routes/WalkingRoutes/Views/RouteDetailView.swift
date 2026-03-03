import SwiftUI

struct RouteDetailView: View {
    let route: Route
    @State private var selectedLandmark: Landmark?
    @State private var showNavigation = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HeroSection(route: route)

                Text("About this route")
                    .font(.title3.weight(.bold))

                Text(route.description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Button {
                    showNavigation = true
                } label: {
                    Label("Start Walking", systemImage: "figure.walk.motion")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppTheme.primaryColor)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }

                RouteMapViewRepresentable(route: route, routeColor: route.routeColor, showsNumberedPins: true)
                    .frame(height: 260)
                    .clipShape(RoundedRectangle(cornerRadius: 20))

                Text("Highlights (\(route.landmarks.count) stops)")
                    .font(.title3.weight(.bold))

                VStack(spacing: 12) {
                    ForEach(Array(route.landmarks.enumerated()), id: \.element.id) { index, landmark in
                        LandmarkCard(landmark: landmark, index: index + 1, routeColor: route.routeColor.color)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                print("[RouteDetailView] Landmark tapped: \(landmark.name)")
                                selectedLandmark = landmark
                            }
                    }
                }

                Text("Photos: Wikimedia Commons")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
        }
        .background(AppTheme.secondaryBackground)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $selectedLandmark) { landmark in
            LandmarkDetailView(landmark: landmark)
        }
        .fullScreenCover(isPresented: $showNavigation) {
            RouteNavigationView(route: route)
        }
    }
}

private struct HeroSection: View {
    let route: Route

    var body: some View {
        ZStack(alignment: .bottomLeading) {
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
            .frame(height: 280)
            .frame(maxWidth: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: 20))

            LinearGradient(colors: [.clear, .black.opacity(0.55)], startPoint: .top, endPoint: .bottom)
                .clipShape(RoundedRectangle(cornerRadius: 20))

            VStack(alignment: .leading, spacing: 8) {
                Text(route.name)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.white)

                HStack(spacing: 8) {
                    Label(String(format: "%.1f", route.averageRating), systemImage: "star.fill")
                    Text("•")
                    Text("\(route.duration) min")
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
            }
            .padding()
        }
        .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
    }
}

private struct LandmarkCard: View {
    let landmark: Landmark
    let index: Int
    let routeColor: Color

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack(alignment: .topLeading) {
                AsyncImage(url: URL(string: landmark.imageURL ?? "")) { phase in
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
                .frame(width: 100, height: 100)
                .clipShape(RoundedRectangle(cornerRadius: 14))

                Text("\(index)")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(width: 22, height: 22)
                    .background(routeColor)
                    .clipShape(Circle())
                    .offset(x: 6, y: 6)
            }

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(landmark.name)
                        .font(.headline)
                    Spacer()
                    Text("\(landmark.estimatedTime) min")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(routeColor)
                }

                Text(landmark.description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(4)

                if let rating = landmark.rating {
                    Label(String(format: "%.1f", rating), systemImage: "star.fill")
                        .font(.caption)
                        .foregroundStyle(.yellow)
                }
            }
        }
        .padding(12)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
        )
    }
}

#Preview {
    NavigationStack {
        RouteDetailView(route: SampleData.routes[0])
    }
}
