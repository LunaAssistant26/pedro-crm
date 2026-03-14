import Foundation
import MapKit
import CoreLocation

/// Fetches real points of interest globally using Apple's MKLocalPointsOfInterestRequest.
/// Replaces the static Amsterdam/Utrecht-only landmark list with dynamic worldwide POI data.
actor DynamicPOIService {
    static let shared = DynamicPOIService()

    // Cache: region key → landmarks (5-minute TTL)
    private var cache: [String: CacheEntry] = [:]
    private let cacheTTL: TimeInterval = 300

    private struct CacheEntry {
        let landmarks: [Landmark]
        let createdAt: Date
    }

    // Minimum Google rating for cultural/landmark POIs (food uses 4.4)
    private static let minCulturalRating: Double = 4.0

    // Food categories — these go through the 4.4 rating filter
    private static let foodCategories: Set<MKPointOfInterestCategory> = [.restaurant, .cafe, .bakery]

    // MARK: - Public API

    /// Fetch landmarks near a walking route polyline. Returns up to `limit` results sorted by proximity.
    func landmarks(
        near polyline: [CLLocationCoordinate2D],
        maxDistanceMeters: CLLocationDistance = 200,
        limit: Int = 6
    ) async -> [Landmark] {
        guard !polyline.isEmpty else { return [] }

        // Use route center + bounding radius as the search area
        let center = routeCenter(polyline)
        let radius = min(routeRadius(center: center, polyline: polyline) + 200, 2000) // cap at 2km

        let key = cacheKey(center: center, radius: radius)
        if let entry = cache[key], Date().timeIntervalSince(entry.createdAt) < cacheTTL {
            return filterAndSort(entry.landmarks, polyline: polyline, maxDist: maxDistanceMeters, limit: limit)
        }

        let region = MKCoordinateRegion(
            center: center,
            latitudinalMeters: radius * 2,
            longitudinalMeters: radius * 2
        )

        // No category filter — let Apple return everything (banks, churches, monuments, etc.)
        // Google Places acts as the quality gate: only POIs with a real rating are shown.
        // This catches famous landmarks (Domtoren, cathedrals, monuments) that Apple only
        // exposes via .landmark/.castle categories which require iOS 18+.
        let request = MKLocalPointsOfInterestRequest(center: center, radius: radius)
        // pointOfInterestFilter intentionally left as default (nil = all categories)

        do {
            let search = MKLocalSearch(request: request)
            let response = try await search.start()
            let candidates = response.mapItems.compactMap { Landmark.from(mapItem: $0) }

            // Larger initial pool because unfiltered search returns noise (banks, ATMs, etc.)
            let nearby = filterAndSort(candidates, polyline: polyline, maxDist: maxDistanceMeters, limit: limit * 6)

            // Enrich every POI with Google Places.
            // Hard rules — a POI is only shown when ALL of these pass:
            //   1. Has a Google Places match
            //   2. Rating ≥ threshold (food: 4.4, cultural: 4.0)
            //   3. Google types confirm it's the right kind of place
            //      – food spots: must have a food/restaurant type (blocks offices like GRUND Inc.)
            //      – cultural: any place with sufficient reviews is fine
            //   4. Minimum review count (food: 20+, cultural: 30+)
            var enriched: [Landmark] = []
            for landmark in nearby {
                let isFood = landmark.isFoodSpot
                let minRating: Double = isFood ? 4.4 : Self.minCulturalRating
                let minReviews = isFood ? 20 : 30
                let coord = CLLocationCoordinate2D(latitude: landmark.location.latitude,
                                                  longitude: landmark.location.longitude)
                guard let gDetail = await GooglePlacesService.shared.detail(
                    name: landmark.name,
                    coordinate: coord,
                    minRating: minRating
                ) else { continue }   // no match or below rating threshold

                // Type validation: food spots must be confirmed as food establishments
                if isFood && !gDetail.isFoodEstablishment { continue }

                // Minimum reviews: filter out obscure/unverified places
                if let total = gDetail.userRatingsTotal, total < minReviews { continue }

                enriched.append(landmark.enriched(with: gDetail))
                if enriched.count >= limit { break }
            }

            // Fallback: if food filter left nothing, relax rating to 4.0 (but still require food type + 20 reviews)
            let foodInEnriched = enriched.filter { $0.isFoodSpot }
            if foodInEnriched.isEmpty {
                for landmark in nearby where landmark.isFoodSpot {
                    let coord = CLLocationCoordinate2D(latitude: landmark.location.latitude,
                                                      longitude: landmark.location.longitude)
                    if let gDetail = await GooglePlacesService.shared.detail(
                        name: landmark.name, coordinate: coord, minRating: 4.0
                    ), gDetail.isFoodEstablishment,
                       (gDetail.userRatingsTotal ?? 0) >= 20 {
                        enriched.append(landmark.enriched(with: gDetail))
                        if enriched.count >= limit { break }
                    }
                }
            }

            cache[key] = CacheEntry(landmarks: enriched, createdAt: Date())
            return Array(enriched.prefix(limit))
        } catch {
            return []
        }
    }

    // MARK: - Helpers

    private func routeCenter(_ coords: [CLLocationCoordinate2D]) -> CLLocationCoordinate2D {
        let lat = coords.map(\.latitude).reduce(0, +) / Double(coords.count)
        let lon = coords.map(\.longitude).reduce(0, +) / Double(coords.count)
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }

    private func routeRadius(center: CLLocationCoordinate2D, polyline: [CLLocationCoordinate2D]) -> CLLocationDistance {
        let centerLoc = CLLocation(latitude: center.latitude, longitude: center.longitude)
        return polyline.map {
            centerLoc.distance(from: CLLocation(latitude: $0.latitude, longitude: $0.longitude))
        }.max() ?? 500
    }

    private func filterAndSort(
        _ landmarks: [Landmark],
        polyline: [CLLocationCoordinate2D],
        maxDist: CLLocationDistance,
        limit: Int
    ) -> [Landmark] {
        let polylineLocs = polyline.map { CLLocation(latitude: $0.latitude, longitude: $0.longitude) }

        let scored: [(Landmark, CLLocationDistance)] = landmarks.compactMap { poi in
            let poiLoc = CLLocation(latitude: poi.location.latitude, longitude: poi.location.longitude)
            let minDist = polylineLocs.reduce(CLLocationDistance.greatestFiniteMagnitude) {
                min($0, $1.distance(from: poiLoc))
            }
            guard minDist <= maxDist else { return nil }
            return (poi, minDist)
        }

        return scored
            .sorted { $0.1 < $1.1 }
            .prefix(limit)
            .map { $0.0 }
    }

    private func cacheKey(center: CLLocationCoordinate2D, radius: Double) -> String {
        // ~500m grid cells
        let latGrid = Int(center.latitude * 200)
        let lonGrid = Int(center.longitude * 200)
        return "\(latGrid),\(lonGrid),\(Int(radius))"
    }
}



// MARK: - Landmark + Google enrichment

extension Landmark {
    func enriched(with g: GooglePlaceDetail) -> Landmark {
        let photoURLStr = g.photoReference.flatMap {
            GooglePlacesService.shared.photoURL(reference: $0, maxWidth: 800)?.absoluteString
        }
        var hours = g.todayHours
        if let open = g.openNow {
            let prefix = open ? "Open now" : "Closed now"
            hours = [prefix, g.todayHours].compactMap { $0 }.joined(separator: " · ")
        }
        let priceStr: String? = g.priceLevel.map { String(repeating: "€", count: max(1, $0)) }

        return Landmark(
            id: self.id,
            name: g.name.isEmpty ? self.name : g.name,
            description: self.description,
            location: self.location,
            estimatedTime: self.estimatedTime,
            imageURL: photoURLStr ?? self.imageURL,
            rating: g.rating ?? self.rating,
            detailedDescription: self.detailedDescription,
            websiteURL: g.website ?? self.websiteURL,
            bookingURL: self.bookingURL,
            infoURL: self.infoURL,
            openingHours: hours ?? self.openingHours,
            admissionFee: priceStr ?? self.admissionFee,
            phoneNumber: g.phoneNumber ?? self.phoneNumber,
            accessibilityInfo: self.accessibilityInfo,
            tags: self.tags
        )
    }
}

// MARK: - Landmark from MKMapItem

extension Landmark {
    static func from(mapItem: MKMapItem) -> Landmark? {
        let coord = mapItem.placemark.coordinate
        guard CLLocationCoordinate2DIsValid(coord) else { return nil }
        guard let name = mapItem.name, !name.isEmpty else { return nil }

        let category = mapItem.pointOfInterestCategory
        let description = Self.description(for: category, name: name)
        let tags = Self.tags(for: category)
        let estimatedTime = Self.estimatedTime(for: category)

        return Landmark(
            id: UUID(),
            name: name,
            description: description,
            location: Location(latitude: coord.latitude, longitude: coord.longitude),
            estimatedTime: estimatedTime,
            imageURL: nil,
            rating: nil,
            detailedDescription: nil,
            websiteURL: mapItem.url,
            bookingURL: nil,
            infoURL: nil,
            openingHours: nil,
            admissionFee: nil,
            phoneNumber: mapItem.phoneNumber,
            accessibilityInfo: nil,
            tags: tags
        )
    }

    private static func description(for category: MKPointOfInterestCategory?, name: String) -> String {
        guard let category else { return "Notable stop along your route." }
        switch category {
        case .museum:       return "Museum worth visiting along your route."
        case .park:         return "Park — a great spot to rest or explore."
        case .nationalPark: return "National park or protected area."
        case .theater:      return "Theater or performing arts venue."
        case .library:      return "Public library."
        case .university:   return "University or educational institution."
        case .restaurant:   return "Restaurant — fuel up here."
        case .cafe:         return "Café — perfect for a coffee break."
        case .bakery:       return "Bakery — great for a quick snack."
        case .beach:        return "Beach or waterfront area."
        case .zoo:          return "Zoo or wildlife attraction."
        case .aquarium:     return "Aquarium."
        case .stadium:      return "Stadium or sports venue."
        case .nightlife:    return "Bar or nightlife venue."
        case .hotel:        return "Hotel or accommodation."
        default:
            if #available(iOS 18.0, *) {
                switch category {
                case .landmark: return "Notable landmark on your walk."
                case .castle:   return "Castle or historic fortification."
                default: break
                }
            }
            // Church, monument, historical site, or other cultural POI
            return "Landmark worth a look on your walk."
        }
    }

    private static func tags(for category: MKPointOfInterestCategory?) -> [String] {
        guard let category else { return ["landmark", "culture"] }
        switch category {
        case .museum:                  return ["museum", "culture"]
        case .park, .nationalPark:     return ["park", "outdoor", "free"]
        case .theater:                 return ["theater", "culture"]
        case .library:                 return ["library", "free"]
        case .university:              return ["university"]
        case .restaurant:              return ["dining", "food"]
        case .cafe, .bakery:           return ["cafe", "food"]
        case .beach:                   return ["outdoor", "beach"]
        case .zoo, .aquarium:          return ["attraction", "family-friendly"]
        case .nightlife:               return ["nightlife", "food"]
        case .hotel:                   return ["hotel"]
        default:
            if #available(iOS 18.0, *) {
                switch category {
                case .landmark, .castle: return ["landmark", "history"]
                default: break
                }
            }
            // Catch-all for churches, monuments, historical sites (no specific iOS 16 category)
            return ["landmark", "culture"]
        }
    }

    private static func estimatedTime(for category: MKPointOfInterestCategory?) -> Int {
        guard let category else { return 15 }
        switch category {
        case .museum:       return 60
        case .park, .nationalPark: return 30
        case .restaurant:   return 45
        case .cafe, .bakery: return 20
        case .theater:      return 90
        default:            return 15
        }
    }
}
