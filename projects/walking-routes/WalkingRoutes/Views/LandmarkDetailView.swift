import SwiftUI
import SafariServices
import MapKit
import os.log

// MARK: - Safari View Controller Wrapper

struct SafariView: UIViewControllerRepresentable {
    let url: URL
    var onDismiss: (() -> Void)?

    func makeUIViewController(context: Context) -> SFSafariViewController {
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = false
        let safari = SFSafariViewController(url: url, configuration: config)
        safari.delegate = context.coordinator
        safari.preferredBarTintColor = UIColor(AppTheme.primaryColor)
        safari.preferredControlTintColor = .white
        return safari
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onDismiss: onDismiss)
    }

    class Coordinator: NSObject, SFSafariViewControllerDelegate {
        var onDismiss: (() -> Void)?

        init(onDismiss: (() -> Void)?) {
            self.onDismiss = onDismiss
        }

        func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
            onDismiss?()
        }
    }
}

// MARK: - Analytics Service

enum AnalyticsEvent {
    case landmarkViewed(name: String)
    case bookingLinkTapped(landmark: String, url: String)
    case websiteVisited(landmark: String, url: String)
    case directionsRequested(landmark: String)
    case phoneCallInitiated(landmark: String)

    var name: String {
        switch self {
        case .landmarkViewed: return "landmark_viewed"
        case .bookingLinkTapped: return "booking_link_tapped"
        case .websiteVisited: return "website_visited"
        case .directionsRequested: return "directions_requested"
        case .phoneCallInitiated: return "phone_call_initiated"
        }
    }
}

@MainActor
final class AnalyticsService {
    static let shared = AnalyticsService()
    private let logger = Logger(subsystem: "com.walkingroutes", category: "Analytics")

    private init() {}

    func log(_ event: AnalyticsEvent) {
        // In production, this would send to Firebase, Mixpanel, etc.
        // For now, we log to console
        switch event {
        case .landmarkViewed(let name):
            logger.log("📊 Analytics: Landmark viewed - \(name)")
        case .bookingLinkTapped(let landmark, let url):
            logger.log("📊 Analytics: Booking link tapped - \(landmark) - \(url)")
        case .websiteVisited(let landmark, let url):
            logger.log("📊 Analytics: Website visited - \(landmark) - \(url)")
        case .directionsRequested(let landmark):
            logger.log("📊 Analytics: Directions requested - \(landmark)")
        case .phoneCallInitiated(let landmark):
            logger.log("📊 Analytics: Phone call initiated - \(landmark)")
        }
    }
}

// MARK: - Landmark Detail View

struct LandmarkDetailView: View {
    let landmark: Landmark
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    /// If non-nil, this is a food spot — shows "Visit This Spot" / "Added to Walk ✓"
    var isAddedToWalk: Bool? = nil
    var onAddToWalk: (() -> Void)? = nil

    @State private var showSafari = false
    @State private var safariURL: URL?
    // Local mirror — reflects parent state on open, stays in sync via onAddToWalk closure
    @State private var addedToWalkLocal: Bool = false

    private let logger = Logger(subsystem: "com.walkingroutes", category: "LandmarkDetailView")

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Hero Image
                    heroImageSection

                    VStack(alignment: .leading, spacing: 20) {
                        // Title and Rating
                        titleSection

                        // Tags
                        if !landmark.tags.isEmpty {
                            tagsSection
                        }

                        // Description
                        descriptionSection

                        // Practical Info
                        practicalInfoSection

                        // Action Buttons
                        actionButtonsSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 24)
                }
            }
            .background(AppTheme.secondaryBackground.ignoresSafeArea())
            .navigationTitle("Landmark")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .sheet(isPresented: $showSafari) {
                if let url = safariURL {
                    SafariView(url: url) {
                        self.safariURL = nil
                    }
                }
            }
            .onAppear {
                AnalyticsService.shared.log(.landmarkViewed(name: landmark.name))
                addedToWalkLocal = isAddedToWalk ?? false
            }
        }
    }

    // MARK: - Sections

    private var heroImageSection: some View {
        ZStack(alignment: .bottomLeading) {
            AsyncImage(url: URL(string: landmark.imageURL ?? "")) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure(_):
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay(
                            Image(systemName: "photo")
                                .font(.system(size: 50))
                                .foregroundStyle(.gray)
                        )
                case .empty:
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .overlay(ProgressView())
                @unknown default:
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                }
            }
            .frame(height: 280)
            .frame(maxWidth: .infinity)
            .clipped()

            // Gradient overlay
            LinearGradient(
                colors: [.clear, .black.opacity(0.6)],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 100)
            .frame(maxWidth: .infinity, alignment: .bottom)

            // Bookable badge
            if landmark.isBookable {
                HStack(spacing: 4) {
                    Image(systemName: "ticket.fill")
                    Text("Book Tickets")
                }
                .font(.caption.weight(.bold))
                .foregroundStyle(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(AppTheme.primaryColor)
                .clipShape(Capsule())
                .padding([.leading, .bottom], 16)
            }
        }
    }

    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(landmark.name)
                .font(.title.weight(.bold))
                .foregroundStyle(.primary)
                .accessibilityAddTraits(.isHeader)

            HStack(spacing: 12) {
                if let rating = landmark.rating {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundStyle(.yellow)
                        Text(String(format: "%.1f", rating))
                            .fontWeight(.semibold)
                    }
                    .font(.subheadline)
                    .foregroundStyle(.primary)
                }

                HStack(spacing: 4) {
                    Image(systemName: "clock")
                    Text("\(landmark.estimatedTime) min")
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
        }
    }

    private var tagsSection: some View {
        FlowLayout(spacing: 8) {
            ForEach(landmark.tags, id: \.self) { tag in
                TagView(tag: tag)
            }
        }
    }

    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("About")
                .font(.headline)

            if let detailed = landmark.detailedDescription {
                Text(detailed)
                    .font(.body)
                    .foregroundStyle(.primary)
                    .lineSpacing(4)
            } else {
                Text(landmark.description)
                    .font(.body)
                    .foregroundStyle(.primary)
                    .lineSpacing(4)
            }
        }
    }

    private var practicalInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Practical Information")
                .font(.headline)

            VStack(alignment: .leading, spacing: 12) {
                if let hours = landmark.openingHours {
                    InfoRow(
                        icon: "clock.fill",
                        iconColor: .blue,
                        title: "Opening Hours",
                        value: hours
                    )
                }

                if let fee = landmark.admissionFee {
                    InfoRow(
                        icon: "eurosign.circle.fill",
                        iconColor: .green,
                        title: "Admission",
                        value: fee
                    )
                }

                if let phone = landmark.phoneNumber {
                    InfoRow(
                        icon: "phone.fill",
                        iconColor: .indigo,
                        title: "Phone",
                        value: phone
                    )
                }

                if let accessibility = landmark.accessibilityInfo {
                    InfoRow(
                        icon: "accessibility.fill",
                        iconColor: .orange,
                        title: "Accessibility",
                        value: accessibility
                    )
                }
            }
            .padding(16)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    private var actionButtonsSection: some View {
        VStack(spacing: 12) {
            // Primary: Book Tickets
            if let bookingURL = landmark.bookingURL {
                ActionButton(
                    title: "Book Tickets",
                    icon: "ticket.fill",
                    style: .primary
                ) {
                    openURL(bookingURL, event: .bookingLinkTapped(landmark: landmark.name, url: bookingURL.absoluteString))
                }
            }

            // Secondary: Visit Website
            if let websiteURL = landmark.websiteURL {
                ActionButton(
                    title: "Visit Website",
                    icon: "globe",
                    style: .secondary
                ) {
                    openURL(websiteURL, event: .websiteVisited(landmark: landmark.name, url: websiteURL.absoluteString))
                }
            }

            // Tertiary: More Info
            if let infoURL = landmark.infoURL {
                ActionButton(
                    title: "More Info",
                    icon: "info.circle",
                    style: .tertiary
                ) {
                    openURL(infoURL, event: .websiteVisited(landmark: landmark.name, url: infoURL.absoluteString))
                }
            }

            // Call button
            if let phone = landmark.phoneNumber,
               let phoneURL = URL(string: "tel:\(phone.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "-", with: ""))") {
                ActionButton(
                    title: "Call",
                    icon: "phone.fill",
                    style: .tertiary
                ) {
                    AnalyticsService.shared.log(.phoneCallInitiated(landmark: landmark.name))
                    UIApplication.shared.open(phoneURL)
                }
            }

            // Visit This Spot (only shown for food spots)
            if isAddedToWalk != nil {
                ActionButton(
                    title: addedToWalkLocal ? "Added to Walk ✓" : "Visit This Spot",
                    icon: addedToWalkLocal ? "checkmark.circle.fill" : "mappin.circle.fill",
                    style: .tertiary
                ) {
                    addedToWalkLocal.toggle()
                    onAddToWalk?()
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    AnalyticsService.shared.log(.directionsRequested(landmark: landmark.name))
                }
            }
        }
    }

    // MARK: - Actions

    private func openURL(_ url: URL, event: AnalyticsEvent) {
        AnalyticsService.shared.log(event)
        safariURL = url
        showSafari = true
    }


}

// MARK: - Supporting Views

private struct InfoRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let value: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(iconColor)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
            }
        }
    }
}

enum ActionButtonStyle {
    case primary
    case secondary
    case tertiary

    var backgroundColor: Color {
        switch self {
        case .primary: return AppTheme.primaryColor
        case .secondary: return AppTheme.primaryColor.opacity(0.15)
        case .tertiary: return Color(.systemBackground)
        }
    }

    var foregroundColor: Color {
        switch self {
        case .primary: return .white
        case .secondary: return AppTheme.primaryColor
        case .tertiary: return .primary
        }
    }

    var strokeColor: Color? {
        switch self {
        case .tertiary: return .gray.opacity(0.3)
        default: return nil
        }
    }
}

private struct ActionButton: View {
    let title: String
    let icon: String
    let style: ActionButtonStyle
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                Text(title)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(style.backgroundColor)
            .foregroundStyle(style.foregroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(style.strokeColor ?? .clear, lineWidth: 1)
            )
        }
        .accessibilityLabel(title)
    }
}

private struct TagView: View {
    let tag: String

    var body: some View {
        Text(tag.capitalized)
            .font(.caption.weight(.medium))
            .foregroundStyle(.secondary)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Color.gray.opacity(0.15))
            .clipShape(Capsule())
    }
}

// MARK: - Flow Layout

private struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.replacingUnspecifiedDimensions().width, subviews: subviews, spacing: spacing)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x, y: bounds.minY + result.positions[index].y), proposal: .unspecified)
        }
    }

    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var rowHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)

                if x + size.width > maxWidth && x > 0 {
                    x = 0
                    y += rowHeight + spacing
                    rowHeight = 0
                }

                positions.append(CGPoint(x: x, y: y))
                rowHeight = max(rowHeight, size.height)
                x += size.width + spacing
            }

            self.size = CGSize(width: maxWidth, height: y + rowHeight)
        }
    }
}

// MARK: - Preview

#Preview {
    LandmarkDetailView(
        landmark: Landmark(
            id: UUID(),
            name: "Rijksmuseum",
            description: "Dutch national museum dedicated to arts and history.",
            location: Location(latitude: 52.3600, longitude: 4.8852),
            estimatedTime: 45,
            imageURL: "https://upload.wikimedia.org/wikipedia/commons/thumb/6/6e/Rijksmuseum_Amsterdam.jpg/800px-Rijksmuseum_Amsterdam.jpg",
            rating: 4.8,
            detailedDescription: "The Rijksmuseum is the national museum of the Netherlands dedicated to Dutch arts and history. Located at the Museum Square in Amsterdam, the museum is home to masterpieces by Rembrandt, Vermeer, and Van Gogh. The building itself is a stunning example of Gothic and Renaissance Revival architecture.",
            websiteURL: URL(string: "https://www.rijksmuseum.nl"),
            bookingURL: URL(string: "https://www.rijksmuseum.nl/en/tickets"),
            infoURL: URL(string: "https://en.wikipedia.org/wiki/Rijksmuseum"),
            openingHours: "Mon-Sun: 9:00-17:00",
            admissionFee: "€22.50 adults, free under 18",
            phoneNumber: "+31 20 6747 000",
            accessibilityInfo: "Wheelchair accessible, elevators available",
            tags: ["museum", "art", "history", "must-see"]
        )
    )
}
