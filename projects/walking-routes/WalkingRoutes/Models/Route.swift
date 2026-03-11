import Foundation
import CoreLocation
import SwiftUI
import UIKit

struct Route: Identifiable, Codable {
    let id: UUID
    let name: String
    let description: String
    let duration: Int // minutes
    let distance: Double // kilometers
    let difficulty: Difficulty
    let category: RouteCategory
    let landmarks: [Landmark]
    let coordinates: [Location]
    /// Optional persisted turn-by-turn steps (MapKit directions) for this route.
    ///
    /// - Generated routes: populated during generation (cheap to reuse).
    /// - Demo/static routes: may be nil and can be regenerated on-demand.
    let navigationSteps: [NavigationStep]?
    let imageURL: String?
    let city: String? // For filtering by city

    var pathCoordinates: [CLLocationCoordinate2D] {
        let explicit = coordinates.map(\.clLocation)
        if !explicit.isEmpty { return explicit }
        return landmarks.map { $0.location.clLocation }
    }

    var averageRating: Double {
        let ratings = landmarks.compactMap(\.rating)
        guard !ratings.isEmpty else { return 0 }
        return ratings.reduce(0, +) / Double(ratings.count)
    }

    var routeColor: RouteColor {
        switch name.lowercased() {
        case let value where value.contains("canal"):
            return .canalRing
        case let value where value.contains("jordaan"):
            return .jordaan
        case let value where value.contains("vondelpark"):
            return .vondelpark
        case let value where value.contains("dom"):
            return .domTower
        case let value where value.contains("grift"):
            return .griftPark
        case let value where value.contains("oudegracht"):
            return .oudegracht
        default:
            return .canalRing
        }
    }

    enum Difficulty: String, Codable, CaseIterable {
        case easy = "Easy"
        case moderate = "Moderate"
        case challenging = "Challenging"

        var color: String {
            switch self {
            case .easy: return "green"
            case .moderate: return "orange"
            case .challenging: return "red"
            }
        }
    }

    enum RouteCategory: String, Codable, CaseIterable {
        case highlights = "City Highlights"
        case historic = "Historic"
        case nature = "Nature"
        case food = "Food & Drink"
        case photo = "Photo Walk"
    }
}

enum RouteColor: String, Codable {
    case canalRing
    case jordaan
    case vondelpark
    case domTower
    case griftPark
    case oudegracht

    var color: Color {
        switch self {
        case .canalRing: return .blue
        case .jordaan: return .green
        case .vondelpark: return .orange
        case .domTower: return .purple
        case .griftPark: return .teal
        case .oudegracht: return .indigo
        }
    }

    var uiColor: UIColor {
        switch self {
        case .canalRing: return .systemBlue
        case .jordaan: return .systemGreen
        case .vondelpark: return .systemOrange
        case .domTower: return .systemPurple
        case .griftPark: return .systemTeal
        case .oudegracht: return .systemIndigo
        }
    }
}

struct Landmark: Identifiable, Codable {
    let id: UUID
    let name: String
    let description: String
    let location: Location
    let estimatedTime: Int // minutes to spend here
    let imageURL: String?
    let rating: Double?

    // MARK: - Enhanced landmark details (Task 2)

    /// Longer text (roughly 200–500 chars). Use when available.
    var detailedDescription: String?

    /// Official landmark website.
    var websiteURL: URL?

    /// Direct booking / tickets link.
    var bookingURL: URL?

    /// Wikipedia / tourism site / extra info.
    var infoURL: URL?

    /// Human-readable opening hours, e.g. "Mon–Sun: 9:00–18:00".
    var openingHours: String?

    /// Human-readable admission pricing.
    var admissionFee: String?

    /// Phone number for bookings or info.
    var phoneNumber: String?

    /// Accessibility notes (wheelchair, elevators, etc.).
    var accessibilityInfo: String?

    /// Lightweight categorization & filtering.
    var tags: [String]

    var isBookable: Bool { bookingURL != nil }

    /// Convenience for grouping in UI.
    var primaryTag: String {
        tags.first ?? "other"
    }

    /// Coding keys for custom encoding/decoding of URLs
    enum CodingKeys: String, CodingKey {
        case id, name, description, location, estimatedTime, imageURL, rating
        case detailedDescription, openingHours, admissionFee, phoneNumber
        case accessibilityInfo, tags
        case websiteURLString, bookingURLString, infoURLString
    }

    init(
        id: UUID = UUID(),
        name: String,
        description: String,
        location: Location,
        estimatedTime: Int,
        imageURL: String? = nil,
        rating: Double? = nil,
        detailedDescription: String? = nil,
        websiteURL: URL? = nil,
        bookingURL: URL? = nil,
        infoURL: URL? = nil,
        openingHours: String? = nil,
        admissionFee: String? = nil,
        phoneNumber: String? = nil,
        accessibilityInfo: String? = nil,
        tags: [String] = []
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.location = location
        self.estimatedTime = estimatedTime
        self.imageURL = imageURL
        self.rating = rating
        self.detailedDescription = detailedDescription
        self.websiteURL = websiteURL
        self.bookingURL = bookingURL
        self.infoURL = infoURL
        self.openingHours = openingHours
        self.admissionFee = admissionFee
        self.phoneNumber = phoneNumber
        self.accessibilityInfo = accessibilityInfo
        self.tags = tags
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        description = try container.decode(String.self, forKey: .description)
        location = try container.decode(Location.self, forKey: .location)
        estimatedTime = try container.decode(Int.self, forKey: .estimatedTime)
        imageURL = try container.decodeIfPresent(String.self, forKey: .imageURL)
        rating = try container.decodeIfPresent(Double.self, forKey: .rating)
        detailedDescription = try container.decodeIfPresent(String.self, forKey: .detailedDescription)
        openingHours = try container.decodeIfPresent(String.self, forKey: .openingHours)
        admissionFee = try container.decodeIfPresent(String.self, forKey: .admissionFee)
        phoneNumber = try container.decodeIfPresent(String.self, forKey: .phoneNumber)
        accessibilityInfo = try container.decodeIfPresent(String.self, forKey: .accessibilityInfo)
        tags = try container.decodeIfPresent([String].self, forKey: .tags) ?? []

        // Decode URLs from strings
        if let urlString = try container.decodeIfPresent(String.self, forKey: .websiteURLString) {
            websiteURL = URL(string: urlString)
        } else {
            websiteURL = nil
        }
        if let urlString = try container.decodeIfPresent(String.self, forKey: .bookingURLString) {
            bookingURL = URL(string: urlString)
        } else {
            bookingURL = nil
        }
        if let urlString = try container.decodeIfPresent(String.self, forKey: .infoURLString) {
            infoURL = URL(string: urlString)
        } else {
            infoURL = nil
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(description, forKey: .description)
        try container.encode(location, forKey: .location)
        try container.encode(estimatedTime, forKey: .estimatedTime)
        try container.encodeIfPresent(imageURL, forKey: .imageURL)
        try container.encodeIfPresent(rating, forKey: .rating)
        try container.encodeIfPresent(detailedDescription, forKey: .detailedDescription)
        try container.encodeIfPresent(openingHours, forKey: .openingHours)
        try container.encodeIfPresent(admissionFee, forKey: .admissionFee)
        try container.encodeIfPresent(phoneNumber, forKey: .phoneNumber)
        try container.encodeIfPresent(accessibilityInfo, forKey: .accessibilityInfo)
        try container.encode(tags, forKey: .tags)
        try container.encodeIfPresent(websiteURL?.absoluteString, forKey: .websiteURLString)
        try container.encodeIfPresent(bookingURL?.absoluteString, forKey: .bookingURLString)
        try container.encodeIfPresent(infoURL?.absoluteString, forKey: .infoURLString)
    }
}

struct Location: Codable {
    let latitude: Double
    let longitude: Double

    var clLocation: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
