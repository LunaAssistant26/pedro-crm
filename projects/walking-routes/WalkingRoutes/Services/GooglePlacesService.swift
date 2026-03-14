import Foundation
import CoreLocation

// MARK: - Models

struct GooglePlaceDetail {
    let placeID: String
    let name: String
    let rating: Double?
    let userRatingsTotal: Int?
    let openNow: Bool?
    let todayHours: String?
    let phoneNumber: String?
    let website: URL?
    let priceLevel: Int?         // 0–4
    let photoReference: String?  // first photo ref
    let types: [String]          // e.g. ["restaurant","food","establishment"]

    /// True if Google confirmed this is a food/drink establishment.
    var isFoodEstablishment: Bool {
        let foodTypes: Set<String> = ["restaurant", "cafe", "bakery", "bar",
                                      "food", "meal_takeaway", "meal_delivery",
                                      "night_club", "coffee_shop"]
        return types.contains { foodTypes.contains($0) }
    }

    /// True if Google confirmed this is a cultural/tourist place.
    var isCulturalPlace: Bool {
        let culturalTypes: Set<String> = ["tourist_attraction", "museum", "church",
                                          "place_of_worship", "art_gallery", "library",
                                          "park", "stadium", "amusement_park",
                                          "natural_feature", "university", "cemetery",
                                          "historic_site", "monument"]
        return types.contains { culturalTypes.contains($0) }
    }
}

// MARK: - Service

actor GooglePlacesService {
    static let shared = GooglePlacesService()

    private let apiKey = Config.googlePlacesAPIKey
    private let session = URLSession.shared

    // Cache: place name + grid cell → detail (60 min TTL)
    private var cache: [String: CacheEntry] = [:]
    private let cacheTTL: TimeInterval = 3600

    private struct CacheEntry {
        let detail: GooglePlaceDetail?
        let createdAt: Date
    }

    // MARK: - Public

    /// Look up Google Places detail for a named POI near a coordinate.
    /// Returns nil if not found or if rating < minRating (for restaurants/cafés).
    func detail(
        name: String,
        coordinate: CLLocationCoordinate2D,
        minRating: Double? = nil
    ) async -> GooglePlaceDetail? {
        let key = cacheKey(name: name, coordinate: coordinate)
        if let entry = cache[key], Date().timeIntervalSince(entry.createdAt) < cacheTTL {
            return entry.detail
        }

        let detail = await fetchDetail(name: name, coordinate: coordinate)

        // Apply minimum rating filter
        if let min = minRating, let rating = detail?.rating, rating < min {
            cache[key] = CacheEntry(detail: nil, createdAt: Date())
            return nil
        }

        cache[key] = CacheEntry(detail: detail, createdAt: Date())
        return detail
    }

    /// Build a photo URL from a photo reference.
    nonisolated func photoURL(reference: String, maxWidth: Int = 400) -> URL? {
        URL(string: "https://maps.googleapis.com/maps/api/place/photo?maxwidth=\(maxWidth)&photo_reference=\(reference)&key=\(Config.googlePlacesAPIKey)")
    }

    // MARK: - Private

    private func fetchDetail(name: String, coordinate: CLLocationCoordinate2D) async -> GooglePlaceDetail? {
        guard let placeID = await findPlaceID(name: name, coordinate: coordinate) else { return nil }
        return await fetchPlaceDetails(placeID: placeID)
    }

    private func findPlaceID(name: String, coordinate: CLLocationCoordinate2D) async -> String? {
        var components = URLComponents(string: "https://maps.googleapis.com/maps/api/place/findplacefromtext/json")!
        components.queryItems = [
            .init(name: "input", value: name),
            .init(name: "inputtype", value: "textquery"),
            .init(name: "locationbias", value: "point:\(coordinate.latitude),\(coordinate.longitude)"),
            .init(name: "fields", value: "place_id,name,rating"),
            .init(name: "key", value: apiKey),
        ]
        guard let url = components.url else { return nil }

        do {
            let (data, _) = try await session.data(from: url)
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            let candidates = json?["candidates"] as? [[String: Any]]
            return candidates?.first?["place_id"] as? String
        } catch {
            return nil
        }
    }

    private func fetchPlaceDetails(placeID: String) async -> GooglePlaceDetail? {
        var components = URLComponents(string: "https://maps.googleapis.com/maps/api/place/details/json")!
        components.queryItems = [
            .init(name: "place_id", value: placeID),
            .init(name: "fields", value: "place_id,name,rating,user_ratings_total,opening_hours,formatted_phone_number,website,price_level,photos,types"),
            .init(name: "key", value: apiKey),
        ]
        guard let url = components.url else { return nil }

        do {
            let (data, _) = try await session.data(from: url)
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            guard let result = json?["result"] as? [String: Any] else { return nil }

            let rating = result["rating"] as? Double
            let userRatingsTotal = result["user_ratings_total"] as? Int
            let priceLevel = result["price_level"] as? Int
            let phone = result["formatted_phone_number"] as? String
            let websiteStr = result["website"] as? String
            let website = websiteStr.flatMap { URL(string: $0) }

            // Opening hours
            let openingHours = result["opening_hours"] as? [String: Any]
            let openNow = openingHours?["open_now"] as? Bool
            let weekdayText = openingHours?["weekday_text"] as? [String]
            let todayHours = todayHoursText(from: weekdayText)

            // First photo reference
            let photos = result["photos"] as? [[String: Any]]
            let photoRef = photos?.first?["photo_reference"] as? String

            let name = result["name"] as? String ?? ""
            let types = result["types"] as? [String] ?? []

            return GooglePlaceDetail(
                placeID: placeID,
                name: name,
                rating: rating,
                userRatingsTotal: userRatingsTotal,
                openNow: openNow,
                todayHours: todayHours,
                phoneNumber: phone,
                website: website,
                priceLevel: priceLevel,
                photoReference: photoRef,
                types: types
            )
        } catch {
            return nil
        }
    }

    /// Extract today's opening hours from weekday_text array.
    private func todayHoursText(from weekdayText: [String]?) -> String? {
        guard let texts = weekdayText, !texts.isEmpty else { return nil }
        // weekday_text[0] = Monday, [6] = Sunday
        let weekday = Calendar.current.component(.weekday, from: Date()) // 1=Sun, 2=Mon...
        let index = (weekday + 5) % 7  // convert to Mon=0 index
        guard texts.indices.contains(index) else { return texts.first }
        // Format: "Monday: 9:00 AM – 10:00 PM" → strip day name
        let text = texts[index]
        if let colonIdx = text.firstIndex(of: ":") {
            return String(text[text.index(after: colonIdx)...]).trimmingCharacters(in: .whitespaces)
        }
        return text
    }

    private func cacheKey(name: String, coordinate: CLLocationCoordinate2D) -> String {
        let latGrid = Int(coordinate.latitude * 1000)
        let lonGrid = Int(coordinate.longitude * 1000)
        return "\(name.lowercased().prefix(20))_\(latGrid)_\(lonGrid)"
    }
}
