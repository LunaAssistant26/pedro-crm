import SwiftUI
import os.log

/// Enhanced landmark card for use in lists and route timelines
struct LandmarkCard: View {
    let landmark: Landmark
    var index: Int? = nil
    var routeColor: Color? = nil
    var estimatedWalkTime: Int? = nil
    var showBookableBadge: Bool = true

    @State private var showDetail = false
    private let logger = Logger(subsystem: "com.walkingroutes", category: "LandmarkCard")

    private var imageURL: URL? {
        guard let urlString = landmark.imageURL, !urlString.isEmpty else {
            return nil
        }
        return URL(string: urlString)
    }

    var body: some View {
        Button(action: {
            logger.log("[LandmarkCard] Tapped: \(landmark.name)")
            showDetail = true
        }) {
            HStack(alignment: .top, spacing: 12) {
                // Image with optional index badge
                imageSection

                // Content
                contentSection
            }
            .padding(12)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.gray.opacity(0.15), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showDetail) {
            LandmarkDetailView(landmark: landmark)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint("Double tap to view details and booking options")
    }

    // MARK: - Sections

    private var imageSection: some View {
        ZStack(alignment: .topLeading) {
            if let url = imageURL {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure(_):
                        placeholderView
                    case .empty:
                        placeholderView
                            .overlay(ProgressView())
                    @unknown default:
                        placeholderView
                    }
                }
            } else {
                placeholderView
            }

            // Index badge
            if let index = index, let routeColor = routeColor {
                Text("\(index)")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(width: 24, height: 24)
                    .background(routeColor)
                    .clipShape(Circle())
                    .offset(x: 6, y: 6)
            }

            // Bookable badge
            if landmark.isBookable && showBookableBadge {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Image(systemName: "ticket.fill")
                            .font(.caption2)
                            .foregroundStyle(.white)
                            .padding(6)
                            .background(AppTheme.primaryColor)
                            .clipShape(Circle())
                    }
                }
                .padding(6)
            }
        }
        .frame(width: 100, height: 100)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var placeholderView: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.2))
            .overlay(
                Image(systemName: "photo")
                    .font(.title2)
                    .foregroundStyle(.gray)
            )
    }

    private var contentSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Title row
            HStack {
                Text(landmark.name)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                Spacer()

                // Time badge
                HStack(spacing: 3) {
                    Image(systemName: "clock")
                        .font(.caption2)
                    Text("\(landmark.estimatedTime)m")
                        .font(.caption.weight(.medium))
                }
                .foregroundStyle(routeColor ?? .secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background((routeColor ?? .gray).opacity(0.15))
                .clipShape(Capsule())
            }

            // Description
            Text(landmark.description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)

            Spacer(minLength: 4)

            // Bottom row: rating + tags + walk time
            HStack(spacing: 12) {
                // Rating
                if let rating = landmark.rating {
                    HStack(spacing: 3) {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundStyle(.yellow)
                        Text(String(format: "%.1f", rating))
                            .font(.caption.weight(.medium))
                    }
                    .foregroundStyle(.primary)
                }

                // Primary tag
                if let firstTag = landmark.tags.first {
                    Text(firstTag.capitalized)
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.gray.opacity(0.12))
                        .clipShape(Capsule())
                }

                Spacer()

                // Estimated walk time from start
                if let walkTime = estimatedWalkTime {
                    HStack(spacing: 3) {
                        Image(systemName: "figure.walk")
                            .font(.caption2)
                        Text("~\(walkTime)m")
                            .font(.caption2)
                    }
                    .foregroundStyle(.secondary)
                }
            }
        }
        .frame(minHeight: 90)
    }

    // MARK: - Accessibility

    private var accessibilityLabel: String {
        var parts = [landmark.name]
        if let rating = landmark.rating {
            parts.append("Rating \(String(format: "%.1f", rating))")
        }
        parts.append("\(landmark.estimatedTime) minutes to visit")
        if landmark.isBookable {
            parts.append("Tickets available")
        }
        return parts.joined(separator: ", ")
    }
}

// MARK: - Compact Landmark Card

/// Smaller card for compact lists
struct CompactLandmarkCard: View {
    let landmark: Landmark
    var showBookableIndicator: Bool = true

    @State private var showDetail = false

    var body: some View {
        Button(action: { showDetail = true }) {
            HStack(spacing: 10) {
                // Thumbnail
                AsyncImage(url: URL(string: landmark.imageURL ?? "")) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    default:
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                    }
                }
                .frame(width: 50, height: 50)
                .clipShape(RoundedRectangle(cornerRadius: 8))

                // Content
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text(landmark.name)
                            .font(.subheadline.weight(.semibold))
                            .lineLimit(1)

                        if landmark.isBookable && showBookableIndicator {
                            Image(systemName: "ticket.fill")
                                .font(.caption2)
                                .foregroundStyle(AppTheme.primaryColor)
                        }
                    }

                    Text(landmark.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)

                    HStack(spacing: 8) {
                        if let rating = landmark.rating {
                            Label(String(format: "%.1f", rating), systemImage: "star.fill")
                                .font(.caption2)
                                .foregroundStyle(.yellow)
                        }

                        Text("\(landmark.estimatedTime)m")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding(10)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showDetail) {
            LandmarkDetailView(landmark: landmark)
        }
    }
}

// MARK: - Preview

#Preview {
    ScrollView {
        VStack(spacing: 12) {
            LandmarkCard(
                landmark: Landmark(
                    id: UUID(),
                    name: "Rijksmuseum",
                    description: "Dutch national museum dedicated to arts and history.",
                    location: Location(latitude: 52.3600, longitude: 4.8852),
                    estimatedTime: 45,
                    imageURL: "https://upload.wikimedia.org/wikipedia/commons/thumb/6/6e/Rijksmuseum_Amsterdam.jpg/800px-Rijksmuseum_Amsterdam.jpg",
                    rating: 4.8,
                    detailedDescription: nil,
                    websiteURL: URL(string: "https://www.rijksmuseum.nl"),
                    bookingURL: URL(string: "https://www.rijksmuseum.nl/en/tickets"),
                    infoURL: nil,
                    openingHours: "Mon-Sun: 9:00-17:00",
                    admissionFee: "€22.50 adults",
                    phoneNumber: nil,
                    accessibilityInfo: nil,
                    tags: ["museum", "art"]
                ),
                index: 1,
                routeColor: .blue,
                estimatedWalkTime: 15
            )

            LandmarkCard(
                landmark: Landmark(
                    id: UUID(),
                    name: "Anne Frank House",
                    description: "The hiding place where Anne Frank wrote her famous diary during WWII.",
                    location: Location(latitude: 52.3752, longitude: 4.8839),
                    estimatedTime: 20,
                    imageURL: "https://upload.wikimedia.org/wikipedia/commons/thumb/c/cb/Anne_Frank_House_Amsterdam.jpg/800px-Anne_Frank_House_Amsterdam.jpg",
                    rating: 4.6,
                    bookingURL: URL(string: "https://www.annefrank.org/en/visit/"),
                    tags: ["museum", "history"]
                ),
                index: 2,
                routeColor: .green,
                estimatedWalkTime: 8
            )

            CompactLandmarkCard(
                landmark: Landmark(
                    id: UUID(),
                    name: "Vondelpark",
                    description: "Amsterdam's most famous park.",
                    location: Location(latitude: 52.3584, longitude: 4.8699),
                    estimatedTime: 15,
                    imageURL: "https://upload.wikimedia.org/wikipedia/commons/thumb/e/e1/Vondelpark_Amsterdam.jpg/1200px-Vondelpark_Amsterdam.jpg",
                    rating: 4.6,
                    tags: ["park", "outdoor"]
                )
            )
        }
        .padding()
    }
    .background(AppTheme.secondaryBackground)
}
