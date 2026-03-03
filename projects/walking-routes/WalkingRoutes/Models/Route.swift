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
}

struct Location: Codable {
    let latitude: Double
    let longitude: Double

    var clLocation: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
