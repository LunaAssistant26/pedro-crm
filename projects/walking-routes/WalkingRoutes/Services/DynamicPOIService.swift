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

    // POI categories to look for along walking routes
    private static let categories: [MKPointOfInterestCategory] = {
        var cats: [MKPointOfInterestCategory] = [
            .museum, .park, .nationalPark,
            .theater, .library, .university,
            .restaurant, .cafe, .bakery,
            .beach, .zoo, .aquarium,
            .stadium,
        ]
        if #available(iOS 18.0, *) {
            cats += [.landmark, .castle]
        }
        return cats
    }()

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

        let request = MKLocalPointsOfInterestRequest(center: center, radius: radius)
        request.pointOfInterestFilter = MKPointOfInterestFilter(including: Self.categories)

        do {
            let search = MKLocalSearch(request: request)
            let response = try await search.start()
            let candidates = response.mapItems.compactMap { Landmark.from(mapItem: $0) }
            let nearby = filterAndSort(candidates, polyline: polyline, maxDist: maxDistanceMeters, limit: limit * 3)

            // Enrich with Google Places (rating, hours, photos). Filter restaurants/cafés < 4.4.
            var enriched: [Landmark] = []
            for landmark in nearby {
                let isFood = landmark.tags.contains(where: { ["dining", "food", "cafe"].contains($0) })
                let minRating: Double? = isFood ? 4.4 : nil
                let coord = CLLocationCoordinate2D(latitude: landmark.location.latitude,
                                                  longitude: landmark.location.longitude)
                if let gDetail = await GooglePlacesService.shared.detail(
                    name: landmark.name,
                    coordinate: coord,
                    minRating: minRating
                ) {
                    enriched.append(landmark.enriched(with: gDetail))
                } else if !isFood {
                    // Non-food POIs shown even without Google data
                    enriched.append(landmark)
                }
                // Food POIs without Google match (or below 4.4) are silently dropped
                if enriched.count >= limit { break }
            }

            // Fallback: if food filter left us with very few results, relax to 4.0
            if enriched.filter({ $0.tags.contains(where: { ["dining","food","cafe"].contains($0) }) }).isEmpty {
                for landmark in nearby where landmark.tags.contains(where: { ["dining","food","cafe"].contains($0) }) {
                    let coord = CLLocationCoordinate2D(latitude: landmark.location.latitude,
                                                      longitude: landmark.location.longitude)
                    if let gDetail = await GooglePlacesService.shared.detail(
                        name: landmark.name, coordinate: coord, minRating: 4.0
                    ) {
                        var fallback = landmark.enriched(with: gDetail)
                        enriched.append(fallback)
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
        guard let category else { return "Point of interest along your route." }
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
        default:
            if #available(iOS 18.0, *) {
                switch category {
                case .landmark: return "Notable landmark on your walk."
                case .castle:   return "Castle or historic fortification."
                default: break
                }
            }
            return "Point of interest along your route."
        }
    }

    private static func tags(for category: MKPointOfInterestCategory?) -> [String] {
        guard let category else { return ["point-of-interest"] }
        switch category {
        case .museum:       return ["museum", "culture"]
        case .park, .nationalPark: return ["park", "outdoor", "free"]
        // .landmark and .castle are iOS 18+ — handled in default below
        case .theater:      return ["theater", "culture"]
        case .library:      return ["library", "free"]
        case .university:   return ["university"]
        case .restaurant:   return ["dining", "food"]
        case .cafe, .bakery: return ["cafe", "food"]
        case .beach:        return ["outdoor", "beach"]
        case .zoo, .aquarium: return ["attraction", "family-friendly"]
        default:
            if #available(iOS 18.0, *) {
                switch category {
                case .landmark, .castle: return ["landmark", "history"]
                default: break
                }
            }
            return ["point-of-interest"]
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
