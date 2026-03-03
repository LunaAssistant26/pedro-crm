import Foundation
import CoreLocation
import os.log

class RouteViewModel: ObservableObject {
    @Published var routes: [Route] = []
    @Published var filteredRoutes: [Route] = []
    @Published var nearbyRoutes: [Route] = []

    private var routeDistances: [UUID: CLLocationDistance] = [:]
    private let logger = Logger(subsystem: "com.walkingroutes", category: "RouteViewModel")

    init() {
        loadSampleRoutes()
    }

    func loadSampleRoutes() {
        routes = SampleData.routes
        filteredRoutes = routes
        logger.log("Loaded \(routes.count) sample routes")
    }

    /// Filters routes by time with smart recommendations:
    /// - 2-3 routes close to target time (within ±15 min)
    /// - Plus 1 shorter and 1 longer if available
    func filterRoutes(by time: Int, tolerance: Int = 15) {
        logger.log("Filtering routes for time: \(time) min")

        // Sort all routes by how close they are to target time
        let sortedByProximity = routes.sorted {
            abs($0.duration - time) < abs($1.duration - time)
        }

        // Get routes within tolerance (2-3 closest)
        var selectedRoutes: [Route] = []
        let closeRoutes = sortedByProximity.filter { abs($0.duration - time) <= tolerance }
        selectedRoutes.append(contentsOf: closeRoutes.prefix(3))

        // Add 1 shorter route if available (closest shorter route)
        let shorterRoutes = routes
            .filter { $0.duration < time }
            .sorted { abs($0.duration - time) < abs($1.duration - time) }
        if let shorter = shorterRoutes.first, !selectedRoutes.contains(where: { $0.id == shorter.id }) {
            selectedRoutes.append(shorter)
        }

        // Add 1 longer route if available (closest longer route)
        let longerRoutes = routes
            .filter { $0.duration > time }
            .sorted { abs($0.duration - time) < abs($1.duration - time) }
        if let longer = longerRoutes.first, !selectedRoutes.contains(where: { $0.id == longer.id }) {
            selectedRoutes.append(longer)
        }

        // Sort final result by duration for consistent display
        filteredRoutes = selectedRoutes.sorted { $0.duration < $1.duration }

        logger.log("Filtered to \(filteredRoutes.count) routes: \(filteredRoutes.map { "\($0.duration)m" }.joined(separator: ", "))")
    }

    func sortRoutesByDistance(from userLocation: CLLocation) {
        logger.log("Sorting routes by distance from user location")

        let sorted = routes.sorted { lhs, rhs in
            distance(to: lhs, from: userLocation) < distance(to: rhs, from: userLocation)
        }

        routeDistances.removeAll()
        for route in sorted {
            routeDistances[route.id] = distance(to: route, from: userLocation)
        }

        nearbyRoutes = Array(sorted.prefix(3))
        logger.log("Found \(nearbyRoutes.count) nearby routes")
    }

    func distanceText(for route: Route) -> String {
        guard let meters = routeDistances[route.id] else { return "Distance unavailable" }
        if meters < 1000 {
            return "\(Int(meters))m away"
        }
        return String(format: "%.1fkm away", meters / 1000)
    }

    private func distance(to route: Route, from userLocation: CLLocation) -> CLLocationDistance {
        guard let start = route.landmarks.first?.location else { return .greatestFiniteMagnitude }
        let startLocation = CLLocation(latitude: start.latitude, longitude: start.longitude)
        return userLocation.distance(from: startLocation)
    }
}

struct SampleData {
    static let routes: [Route] = [
        // Amsterdam Routes
        Route(
            id: UUID(),
            name: "Canal Ring Classic",
            description: "Historic center walk through Amsterdam's iconic canals and heritage landmarks.",
            duration: 45,
            distance: 3.2,
            difficulty: .easy,
            category: .highlights,
            landmarks: [
                Landmark(
                    id: UUID(),
                    name: "Anne Frank House",
                    description: "The hiding place where Anne Frank wrote her famous diary during WWII. The museum tells the story of her family and the 8 people who hid here for 2 years.",
                    location: Location(latitude: 52.3752, longitude: 4.8839),
                    estimatedTime: 20,
                    imageURL: "https://upload.wikimedia.org/wikipedia/commons/thumb/c/cb/Anne_Frank_House_Amsterdam.jpg/800px-Anne_Frank_House_Amsterdam.jpg",
                    rating: 4.6
                ),
                Landmark(
                    id: UUID(),
                    name: "Westerkerk",
                    description: "Amsterdam's largest Protestant church, built in 1631. The 85-meter tower offers panoramic city views and houses the grave of Rembrandt.",
                    location: Location(latitude: 52.3745, longitude: 4.8837),
                    estimatedTime: 10,
                    imageURL: "https://upload.wikimedia.org/wikipedia/commons/thumb/5/5b/Westerkerk_Amsterdam.jpg/800px-Westerkerk_Amsterdam.jpg",
                    rating: 4.5
                ),
                Landmark(
                    id: UUID(),
                    name: "Herengracht Canal",
                    description: "The most prestigious of Amsterdam's three main canals, lined with beautiful merchant houses from the Golden Age.",
                    location: Location(latitude: 52.3676, longitude: 4.8897),
                    estimatedTime: 5,
                    imageURL: "https://upload.wikimedia.org/wikipedia/commons/thumb/7/7f/Amsterdam_Herengracht.jpg/800px-Amsterdam_Herengracht.jpg",
                    rating: 4.8
                ),
                Landmark(
                    id: UUID(),
                    name: "Keizersgracht Canal",
                    description: "The widest canal, named after Emperor Maximilian I. Features stunning 17th-century architecture and houseboats.",
                    location: Location(latitude: 52.3665, longitude: 4.8860),
                    estimatedTime: 5,
                    imageURL: "https://upload.wikimedia.org/wikipedia/commons/thumb/2/24/Amsterdam_Keizersgracht.jpg/800px-Amsterdam_Keizersgracht.jpg",
                    rating: 4.7
                )
            ],
            coordinates: [],
            imageURL: "https://upload.wikimedia.org/wikipedia/commons/thumb/0/0f/Amsterdam_Canal_Ring.jpg/1200px-Amsterdam_Canal_Ring.jpg",
            city: "Amsterdam"
        ),

        Route(
            id: UUID(),
            name: "Jordaan District Discovery",
            description: "Charming neighborhood walk with markets, canals, and classic Amsterdam cafés.",
            duration: 60,
            distance: 4.5,
            difficulty: .easy,
            category: .historic,
            landmarks: [
                Landmark(
                    id: UUID(),
                    name: "Noordermarkt",
                    description: "Historic square with a Saturday organic market and Monday antique market. Center of the Jordaan neighborhood.",
                    location: Location(latitude: 52.3795, longitude: 4.8864),
                    estimatedTime: 15,
                    imageURL: "https://upload.wikimedia.org/wikipedia/commons/thumb/a/a5/Noordermarkt_Amsterdam.jpg/800px-Noordermarkt_Amsterdam.jpg",
                    rating: 4.4
                ),
                Landmark(
                    id: UUID(),
                    name: "Bloemgracht",
                    description: "The 'Flower Canal' - one of the most photographed spots in the Jordaan, lined with colorful houses and houseboats.",
                    location: Location(latitude: 52.3770, longitude: 4.8840),
                    estimatedTime: 10,
                    imageURL: "https://upload.wikimedia.org/wikipedia/commons/thumb/9/9c/Bloemgracht_Amsterdam.jpg/800px-Bloemgracht_Amsterdam.jpg",
                    rating: 4.8
                ),
                Landmark(
                    id: UUID(),
                    name: "Houseboat Museum",
                    description: "Step inside a real houseboat and learn about life on Amsterdam's canals. See how families have lived on the water for generations.",
                    location: Location(latitude: 52.3758, longitude: 4.8835),
                    estimatedTime: 20,
                    imageURL: "https://upload.wikimedia.org/wikipedia/commons/thumb/3/3f/Houseboat_Museum_Amsterdam.jpg/800px-Houseboat_Museum_Amsterdam.jpg",
                    rating: 4.2
                ),
                Landmark(
                    id: UUID(),
                    name: "Café 't Smalle",
                    description: "Historic brown café dating back to 1786. Famous for its jenever (Dutch gin) and canal-side terrace.",
                    location: Location(latitude: 52.3759, longitude: 4.8795),
                    estimatedTime: 15,
                    imageURL: "https://upload.wikimedia.org/wikipedia/commons/thumb/1/15/Cafe_t_Smalle_Amsterdam.jpg/800px-Cafe_t_Smalle_Amsterdam.jpg",
                    rating: 4.5
                )
            ],
            coordinates: [],
            imageURL: "https://upload.wikimedia.org/wikipedia/commons/thumb/8/8a/Jordaan_Amsterdam.jpg/1200px-Jordaan_Amsterdam.jpg",
            city: "Amsterdam"
        ),

        Route(
            id: UUID(),
            name: "Vondelpark Green Escape",
            description: "A relaxed nature route through the city's most beloved park and cultural highlights.",
            duration: 30,
            distance: 2.8,
            difficulty: .easy,
            category: .nature,
            landmarks: [
                Landmark(
                    id: UUID(),
                    name: "Vondelpark Pavilion",
                    description: "Beautiful building housing a café and theater, surrounded by water. The heart of Vondelpark.",
                    location: Location(latitude: 52.3584, longitude: 4.8699),
                    estimatedTime: 10,
                    imageURL: "https://upload.wikimedia.org/wikipedia/commons/thumb/6/6e/Vondelpark_Pavilion.jpg/800px-Vondelpark_Pavilion.jpg",
                    rating: 4.6
                ),
                Landmark(
                    id: UUID(),
                    name: "Open Air Theatre",
                    description: "Free performances during summer months in a natural amphitheater setting. Music, dance, and children's theater.",
                    location: Location(latitude: 52.3590, longitude: 4.8705),
                    estimatedTime: 5,
                    imageURL: "https://upload.wikimedia.org/wikipedia/commons/thumb/4/4c/Openluchttheater_Vondelpark.jpg/800px-Openluchttheater_Vondelpark.jpg",
                    rating: 4.7
                ),
                Landmark(
                    id: UUID(),
                    name: "Statue of Joost van den Vondel",
                    description: "Monument to the poet after whom the park is named. Joost van den Vondel was the most prominent Dutch poet of the 17th century.",
                    location: Location(latitude: 52.3600, longitude: 4.8710),
                    estimatedTime: 5,
                    imageURL: "https://upload.wikimedia.org/wikipedia/commons/thumb/d/d2/Vondel_statue_Amsterdam.jpg/800px-Vondel_statue_Amsterdam.jpg",
                    rating: 4.0
                ),
                Landmark(
                    id: UUID(),
                    name: "Groot Melkhuis",
                    description: "Popular family café with a playground, perfect for a break. Originally a dairy farm in the 19th century.",
                    location: Location(latitude: 52.3565, longitude: 4.8690),
                    estimatedTime: 10,
                    imageURL: "https://upload.wikimedia.org/wikipedia/commons/thumb/b/b3/Groot_Melkhuis_Vondelpark.jpg/800px-Groot_Melkhuis_Vondelpark.jpg",
                    rating: 4.3
                )
            ],
            coordinates: [],
            imageURL: "https://upload.wikimedia.org/wikipedia/commons/thumb/e/e1/Vondelpark_Amsterdam.jpg/1200px-Vondelpark_Amsterdam.jpg",
            city: "Amsterdam"
        ),

        // Additional Amsterdam routes for better time-based recommendations
        Route(
            id: UUID(),
            name: "Museum Quarter Stroll",
            description: "A cultural walk past world-class museums and the iconic I Amsterdam sign.",
            duration: 90,
            distance: 5.5,
            difficulty: .moderate,
            category: .highlights,
            landmarks: [
                Landmark(
                    id: UUID(),
                    name: "Rijksmuseum",
                    description: "Dutch national museum dedicated to arts and history. Houses masterpieces by Rembrandt, Vermeer, and Van Gogh.",
                    location: Location(latitude: 52.3600, longitude: 4.8852),
                    estimatedTime: 45,
                    imageURL: "https://upload.wikimedia.org/wikipedia/commons/thumb/6/6e/Rijksmuseum_Amsterdam.jpg/800px-Rijksmuseum_Amsterdam.jpg",
                    rating: 4.8
                ),
                Landmark(
                    id: UUID(),
                    name: "Van Gogh Museum",
                    description: "Home to the world's largest collection of Van Gogh paintings and drawings.",
                    location: Location(latitude: 52.3584, longitude: 4.8811),
                    estimatedTime: 30,
                    imageURL: "https://upload.wikimedia.org/wikipedia/commons/thumb/3/3f/Van_Gogh_Museum_Amsterdam.jpg/800px-Van_Gogh_Museum_Amsterdam.jpg",
                    rating: 4.7
                ),
                Landmark(
                    id: UUID(),
                    name: "Museumplein",
                    description: "The Museum Square - a large urban square surrounded by major museums and the Concertgebouw.",
                    location: Location(latitude: 52.3578, longitude: 4.8822),
                    estimatedTime: 15,
                    imageURL: "https://upload.wikimedia.org/wikipedia/commons/thumb/a/a5/Museumplein_Amsterdam.jpg/800px-Museumplein_Amsterdam.jpg",
                    rating: 4.5
                )
            ],
            coordinates: [],
            imageURL: "https://upload.wikimedia.org/wikipedia/commons/thumb/6/6e/Museum_Quarter_Amsterdam.jpg/1200px-Museum_Quarter_Amsterdam.jpg",
            city: "Amsterdam"
        ),

        Route(
            id: UUID(),
            name: "De Pijp Food & Market Walk",
            description: "Explore Amsterdam's most diverse neighborhood with its famous street market and international cuisine.",
            duration: 120,
            distance: 6.0,
            difficulty: .easy,
            category: .food,
            landmarks: [
                Landmark(
                    id: UUID(),
                    name: "Albert Cuyp Market",
                    description: "The largest street market in the Netherlands, famous for stroopwafels, fresh produce, and multicultural foods.",
                    location: Location(latitude: 52.3558, longitude: 4.8902),
                    estimatedTime: 45,
                    imageURL: "https://upload.wikimedia.org/wikipedia/commons/thumb/4/4c/Albert_Cuyp_Market.jpg/800px-Albert_Cuyp_Market.jpg",
                    rating: 4.6
                ),
                Landmark(
                    id: UUID(),
                    name: "Sarphatipark",
                    description: "A peaceful neighborhood park named after Samuel Sarphati, featuring ponds, playgrounds, and picnic spots.",
                    location: Location(latitude: 52.3542, longitude: 4.8915),
                    estimatedTime: 20,
                    imageURL: "https://upload.wikimedia.org/wikipedia/commons/thumb/5/5b/Sarphatipark_Amsterdam.jpg/800px-Sarphatipark_Amsterdam.jpg",
                    rating: 4.4
                ),
                Landmark(
                    id: UUID(),
                    name: "Heineken Experience",
                    description: "Interactive museum in the former Heineken brewery. Learn about the famous Dutch beer's history.",
                    location: Location(latitude: 52.3579, longitude: 4.8919),
                    estimatedTime: 90,
                    imageURL: "https://upload.wikimedia.org/wikipedia/commons/thumb/3/3f/Heineken_Experience.jpg/800px-Heineken_Experience.jpg",
                    rating: 4.3
                )
            ],
            coordinates: [],
            imageURL: "https://upload.wikimedia.org/wikipedia/commons/thumb/7/7f/De_Pijp_Amsterdam.jpg/1200px-De_Pijp_Amsterdam.jpg",
            city: "Amsterdam"
        ),

        Route(
            id: UUID(),
            name: "Plantage Garden Walk",
            description: "A short peaceful walk through Amsterdam's garden district with botanical gardens and Artis Zoo.",
            duration: 20,
            distance: 1.8,
            difficulty: .easy,
            category: .nature,
            landmarks: [
                Landmark(
                    id: UUID(),
                    name: "Hortus Botanicus",
                    description: "One of the oldest botanical gardens in the world, founded in 1638. Features a stunning palm house.",
                    location: Location(latitude: 52.3667, longitude: 4.9078),
                    estimatedTime: 45,
                    imageURL: "https://upload.wikimedia.org/wikipedia/commons/thumb/6/6e/Hortus_Botanicus_Amsterdam.jpg/800px-Hortus_Botanicus_Amsterdam.jpg",
                    rating: 4.7
                ),
                Landmark(
                    id: UUID(),
                    name: "Artis Zoo Entrance",
                    description: "The oldest zoo in the Netherlands, founded in 1838. Even without entering, the historic entrance is worth seeing.",
                    location: Location(latitude: 52.3660, longitude: 4.9164),
                    estimatedTime: 10,
                    imageURL: "https://upload.wikimedia.org/wikipedia/commons/thumb/4/4c/Artis_Zoo_Entrance.jpg/800px-Artis_Zoo_Entrance.jpg",
                    rating: 4.5
                )
            ],
            coordinates: [],
            imageURL: "https://upload.wikimedia.org/wikipedia/commons/thumb/a/a5/Plantage_Amsterdam.jpg/1200px-Plantage_Amsterdam.jpg",
            city: "Amsterdam"
        ),

        // Utrecht Routes
        Route(
            id: UUID(),
            name: "Dom Tower & City Center",
            description: "Explore Utrecht's iconic Dom Tower and the charming city center streets.",
            duration: 45,
            distance: 3.0,
            difficulty: .easy,
            category: .highlights,
            landmarks: [
                Landmark(
                    id: UUID(),
                    name: "Dom Tower",
                    description: "At 112 meters, the tallest church tower in the Netherlands. Climb 465 steps for panoramic views of Utrecht.",
                    location: Location(latitude: 52.0908, longitude: 5.1214),
                    estimatedTime: 30,
                    imageURL: "https://upload.wikimedia.org/wikipedia/commons/thumb/6/6e/Dom_Tower_Utrecht.jpg/800px-Dom_Tower_Utrecht.jpg",
                    rating: 4.8
                ),
                Landmark(
                    id: UUID(),
                    name: "Dom Church",
                    description: "Gothic cathedral that was never fully completed after a tornado destroyed the nave in 1674.",
                    location: Location(latitude: 52.0905, longitude: 5.1210),
                    estimatedTime: 20,
                    imageURL: "https://upload.wikimedia.org/wikipedia/commons/thumb/4/4c/Dom_Church_Utrecht.jpg/800px-Dom_Church_Utrecht.jpg",
                    rating: 4.6
                ),
                Landmark(
                    id: UUID(),
                    name: "Pandhof Garden",
                    description: "Peaceful cloister garden behind the Dom Church, a hidden oasis in the city center.",
                    location: Location(latitude: 52.0902, longitude: 5.1205),
                    estimatedTime: 15,
                    imageURL: "https://upload.wikimedia.org/wikipedia/commons/thumb/5/5b/Pandhof_Utrecht.jpg/800px-Pandhof_Utrecht.jpg",
                    rating: 4.7
                ),
                Landmark(
                    id: UUID(),
                    name: "Oudegracht Canal",
                    description: "Utrecht's famous canal with unique wharf cellars at water level, now housing cafes and shops.",
                    location: Location(latitude: 52.0920, longitude: 5.1190),
                    estimatedTime: 10,
                    imageURL: "https://upload.wikimedia.org/wikipedia/commons/thumb/7/7f/Oudegracht_Utrecht.jpg/800px-Oudegracht_Utrecht.jpg",
                    rating: 4.9
                )
            ],
            coordinates: [],
            imageURL: "https://upload.wikimedia.org/wikipedia/commons/thumb/0/0f/Dom_Tower_Utrecht_Skyline.jpg/1200px-Dom_Tower_Utrecht_Skyline.jpg",
            city: "Utrecht"
        ),

        Route(
            id: UUID(),
            name: "Griftpark Loop",
            description: "A relaxing park walk perfect for families, with a playground, skate park, and petting zoo.",
            duration: 30,
            distance: 2.2,
            difficulty: .easy,
            category: .nature,
            landmarks: [
                Landmark(
                    id: UUID(),
                    name: "Griftpark Main Lawn",
                    description: "Large grassy area perfect for picnics and relaxation. Popular with locals on sunny days.",
                    location: Location(latitude: 52.0950, longitude: 5.1300),
                    estimatedTime: 15,
                    imageURL: "https://upload.wikimedia.org/wikipedia/commons/thumb/6/6e/Griftpark_Utrecht.jpg/800px-Griftpark_Utrecht.jpg",
                    rating: 4.5
                ),
                Landmark(
                    id: UUID(),
                    name: "Griftpark Petting Zoo",
                    description: "Free petting zoo with goats, sheep, and chickens. A favorite spot for families with young children.",
                    location: Location(latitude: 52.0955, longitude: 5.1310),
                    estimatedTime: 20,
                    imageURL: "https://upload.wikimedia.org/wikipedia/commons/thumb/3/3f/Griftpark_Petting_Zoo.jpg/800px-Griftpark_Petting_Zoo.jpg",
                    rating: 4.6
                ),
                Landmark(
                    id: UUID(),
                    name: "Park Café",
                    description: "Charming café in the park serving drinks, snacks, and ice cream with outdoor seating.",
                    location: Location(latitude: 52.0945, longitude: 5.1295),
                    estimatedTime: 15,
                    imageURL: "https://upload.wikimedia.org/wikipedia/commons/thumb/a/a5/Griftpark_Cafe.jpg/800px-Griftpark_Cafe.jpg",
                    rating: 4.3
                )
            ],
            coordinates: [],
            imageURL: "https://upload.wikimedia.org/wikipedia/commons/thumb/8/8a/Griftpark_Utrecht_Aerial.jpg/1200px-Griftpark_Utrecht_Aerial.jpg",
            city: "Utrecht"
        ),

        Route(
            id: UUID(),
            name: "Oudegracht Canal Walk",
            description: "Walk along Utrecht's most famous canal with its unique two-level wharves and historic buildings.",
            duration: 60,
            distance: 4.0,
            difficulty: .easy,
            category: .historic,
            landmarks: [
                Landmark(
                    id: UUID(),
                    name: "Winkel van Sinkel",
                    description: "Former department store from 1839 with cast iron facades, now a grand café and club.",
                    location: Location(latitude: 52.0925, longitude: 5.1180),
                    estimatedTime: 15,
                    imageURL: "https://upload.wikimedia.org/wikipedia/commons/thumb/1/15/Winkel_van_Sinkel_Utrecht.jpg/800px-Winkel_van_Sinkel_Utrecht.jpg",
                    rating: 4.4
                ),
                Landmark(
                    id: UUID(),
                    name: "Stadskasteel Oudaen",
                    description: "Medieval city castle now housing a brewery and restaurant. One of Utrecht's best-preserved historic buildings.",
                    location: Location(latitude: 52.0930, longitude: 5.1195),
                    estimatedTime: 20,
                    imageURL: "https://upload.wikimedia.org/wikipedia/commons/thumb/9/9c/Oudaen_Utrecht.jpg/800px-Oudaen_Utrecht.jpg",
                    rating: 4.5
                ),
                Landmark(
                    id: UUID(),
                    name: "Gaardbrug",
                    description: "Picturesque bridge over the Oudegracht with beautiful views of the canal and wharf cellars.",
                    location: Location(latitude: 52.0915, longitude: 5.1205),
                    estimatedTime: 10,
                    imageURL: "https://upload.wikimedia.org/wikipedia/commons/thumb/2/24/Gaardbrug_Utrecht.jpg/800px-Gaardbrug_Utrecht.jpg",
                    rating: 4.7
                ),
                Landmark(
                    id: UUID(),
                    name: "Hamburgerbrug",
                    description: "Another scenic canal bridge, perfect for photos of the characteristic Utrecht canal houses.",
                    location: Location(latitude: 52.0900, longitude: 5.1220),
                    estimatedTime: 10,
                    imageURL: "https://upload.wikimedia.org/wikipedia/commons/thumb/7/7f/Hamburgerbrug_Utrecht.jpg/800px-Hamburgerbrug_Utrecht.jpg",
                    rating: 4.6
                ),
                Landmark(
                    id: UUID(),
                    name: "Neude Square",
                    description: "One of Utrecht's main squares, surrounded by historic buildings and bustling with cafés.",
                    location: Location(latitude: 52.0935, longitude: 5.1185),
                    estimatedTime: 15,
                    imageURL: "https://upload.wikimedia.org/wikipedia/commons/thumb/0/0f/Neude_Utrecht.jpg/800px-Neude_Utrecht.jpg",
                    rating: 4.3
                )
            ],
            coordinates: [],
            imageURL: "https://upload.wikimedia.org/wikipedia/commons/thumb/e/e1/Oudegracht_Utrecht_Canal.jpg/1200px-Oudegracht_Utrecht_Canal.jpg",
            city: "Utrecht"
        )
    ]
}
