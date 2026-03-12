import Foundation
import CoreLocation
import MapKit

// MARK: - Amsterdam Landmarks with Real Data

/// Static POI set with enriched data including booking links, hours, and fees.
/// V2: Includes real URLs for Amsterdam landmarks.
enum PointsOfInterest {
    static let all: [Landmark] = amsterdamLandmarks + utrechtLandmarks

    // MARK: - Amsterdam Landmarks

    static let amsterdamLandmarks: [Landmark] = [
        // Museums
        Landmark(
            id: UUID(),
            name: "Rijksmuseum",
            description: "Dutch national museum dedicated to arts and history.",
            location: Location(latitude: 52.3600, longitude: 4.8852),
            estimatedTime: 90,
            imageURL: "https://upload.wikimedia.org/wikipedia/commons/thumb/6/6e/Rijksmuseum_Amsterdam.jpg/800px-Rijksmuseum_Amsterdam.jpg",
            rating: 4.8,
            detailedDescription: "The Rijksmuseum is the national museum of the Netherlands dedicated to Dutch arts and history. Located at the Museum Square in Amsterdam, the museum is home to masterpieces by Rembrandt, Vermeer, and Van Gogh. The building itself is a stunning example of Gothic and Renaissance Revival architecture designed by Pierre Cuypers.",
            websiteURL: URL(string: "https://www.rijksmuseum.nl"),
            bookingURL: URL(string: "https://www.rijksmuseum.nl/en/tickets"),
            infoURL: URL(string: "https://en.wikipedia.org/wiki/Rijksmuseum"),
            openingHours: "Daily: 9:00 - 17:00",
            admissionFee: "€22.50 adults, free under 18",
            phoneNumber: "+31 20 6747 000",
            accessibilityInfo: "Wheelchair accessible, elevators available, wheelchairs available for loan",
            tags: ["museum", "art", "history", "must-see"]
        ),

        Landmark(
            id: UUID(),
            name: "Van Gogh Museum",
            description: "Museum housing the world's largest collection of Van Gogh paintings.",
            location: Location(latitude: 52.3584, longitude: 4.8811),
            estimatedTime: 75,
            imageURL: "https://upload.wikimedia.org/wikipedia/commons/thumb/3/32/Van_Gogh_Museum_Amsterdam.jpg/800px-Van_Gogh_Museum_Amsterdam.jpg",
            rating: 4.7,
            detailedDescription: "The Van Gogh Museum houses the largest collection of artworks by Vincent van Gogh in the world. The permanent collection includes over 200 paintings, 500 drawings, and 750 letters. Located on Museumplein, the modern building was designed by Gerrit Rietveld and Kisho Kurokawa.",
            websiteURL: URL(string: "https://www.vangoghmuseum.nl"),
            bookingURL: URL(string: "https://www.vangoghmuseum.nl/en/visit/tickets"),
            infoURL: URL(string: "https://en.wikipedia.org/wiki/Van_Gogh_Museum"),
            openingHours: "Daily: 9:00 - 18:00 (Fri until 21:00)",
            admissionFee: "€22 adults, free under 18",
            phoneNumber: "+31 20 5705 200",
            accessibilityInfo: "Fully wheelchair accessible, audio tours available",
            tags: ["museum", "art", "must-see"]
        ),

        Landmark(
            id: UUID(),
            name: "Anne Frank House",
            description: "The hiding place where Anne Frank wrote her famous diary during WWII.",
            location: Location(latitude: 52.3752, longitude: 4.8839),
            estimatedTime: 60,
            imageURL: "https://upload.wikimedia.org/wikipedia/commons/thumb/c/cb/Anne_Frank_House_Amsterdam.jpg/800px-Anne_Frank_House_Amsterdam.jpg",
            rating: 4.6,
            detailedDescription: "The Anne Frank House is a museum dedicated to Jewish wartime diarist Anne Frank. The building is located on Prinsengracht, close to the Westerkerk. Anne Frank and her family hid here for more than two years during World War II. The museum preserves the hiding place and has a permanent exhibition on Anne Frank's life.",
            websiteURL: URL(string: "https://www.annefrank.org"),
            bookingURL: URL(string: "https://www.annefrank.org/en/museum/tickets/"),
            infoURL: URL(string: "https://en.wikipedia.org/wiki/Anne_Frank_House"),
            openingHours: "Daily: 9:00 - 22:00 (varies by season)",
            admissionFee: "€16 adults, €1 youth 10-17, free under 10",
            phoneNumber: "+31 20 5567 105",
            accessibilityInfo: "Partially accessible - steep stairs to hiding place",
            tags: ["museum", "history", "wwii", "must-see"]
        ),

        Landmark(
            id: UUID(),
            name: "Stedelijk Museum",
            description: "Museum for modern and contemporary art and design.",
            location: Location(latitude: 52.3580, longitude: 4.8798),
            estimatedTime: 60,
            imageURL: "https://upload.wikimedia.org/wikipedia/commons/thumb/8/8a/Stedelijk_Museum_Amsterdam.jpg/800px-Stedelijk_Museum_Amsterdam.jpg",
            rating: 4.5,
            detailedDescription: "The Stedelijk Museum Amsterdam is an international museum dedicated to modern and contemporary art and design. The collection contains works by artists including Mondrian, Kandinsky, Chagall, and Warhol. The distinctive bathtub-shaped building extension was designed by Benthem Crouwel Architects.",
            websiteURL: URL(string: "https://www.stedelijk.nl"),
            bookingURL: URL(string: "https://www.stedelijk.nl/en/tickets"),
            infoURL: URL(string: "https://en.wikipedia.org/wiki/Stedelijk_Museum_Amsterdam"),
            openingHours: "Daily: 10:00 - 18:00 (Thu until 22:00)",
            admissionFee: "€22.50 adults, €10 students, free under 18",
            phoneNumber: "+31 20 5732 911",
            accessibilityInfo: "Fully wheelchair accessible",
            tags: ["museum", "art", "modern"]
        ),

        Landmark(
            id: UUID(),
            name: "Heineken Experience",
            description: "Interactive brewery tour at the former Heineken brewery.",
            location: Location(latitude: 52.3579, longitude: 4.8919),
            estimatedTime: 90,
            imageURL: "https://upload.wikimedia.org/wikipedia/commons/thumb/4/4a/Heineken_Experience_Amsterdam.jpg/800px-Heineken_Experience_Amsterdam.jpg",
            rating: 4.4,
            detailedDescription: "The Heineken Experience is a visitor centre located in the former Heineken brewery. This interactive tour takes you through the history of Heineken, the brewing process, and includes tastings. The building was Heineken's first brewery, established in 1867.",
            websiteURL: URL(string: "https://www.heinekenexperience.com"),
            bookingURL: URL(string: "https://tickets.heinekenexperience.com/en/tickets/regular"),
            infoURL: URL(string: "https://en.wikipedia.org/wiki/Heineken_Experience"),
            openingHours: "Mon-Thu: 10:30 - 19:30, Fri-Sun: 10:30 - 21:00",
            admissionFee: "€23 adults (includes 2 beers)",
            phoneNumber: "+31 20 5239 235",
            accessibilityInfo: "Partially accessible - some areas have stairs",
            tags: ["entertainment", "history", "food-drink"]
        ),

        // Historic Sites
        Landmark(
            id: UUID(),
            name: "Westerkerk",
            description: "Amsterdam's largest Protestant church, built in 1631.",
            location: Location(latitude: 52.3745, longitude: 4.8837),
            estimatedTime: 20,
            imageURL: "https://upload.wikimedia.org/wikipedia/commons/thumb/5/5b/Westerkerk_Amsterdam.jpg/800px-Westerkerk_Amsterdam.jpg",
            rating: 4.5,
            detailedDescription: "The Westerkerk (Western Church) is a Reformed church within Dutch Protestant Calvinism in central Amsterdam. Built between 1620 and 1631 in Renaissance style, it is the largest church in the Netherlands dedicated to Protestant worship. The tower offers panoramic views of the city.",
            websiteURL: URL(string: "https://www.westerkerk.nl"),
            bookingURL: nil,
            infoURL: URL(string: "https://en.wikipedia.org/wiki/Westerkerk"),
            openingHours: "Mon-Fri: 11:00 - 15:00 (tower: Apr-Oct)",
            admissionFee: "Church: free, Tower: €12",
            phoneNumber: "+31 20 6247 766",
            accessibilityInfo: "Church accessible, tower has steep stairs only",
            tags: ["history", "architecture", "church"]
        ),

        Landmark(
            id: UUID(),
            name: "Royal Palace Amsterdam",
            description: "One of three palaces in the Netherlands, built as city hall in 1655.",
            location: Location(latitude: 52.3732, longitude: 4.8913),
            estimatedTime: 45,
            imageURL: "https://upload.wikimedia.org/wikipedia/commons/thumb/7/7a/Royal_Palace_Amsterdam.jpg/800px-Royal_Palace_Amsterdam.jpg",
            rating: 4.5,
            detailedDescription: "The Royal Palace in Amsterdam is one of three palaces in the Netherlands which are at the disposal of the monarch by Act of Parliament. Built as the Town Hall of Amsterdam, it opened in 1655. The architecture and interior design reflect the wealth and power of Amsterdam during the Dutch Golden Age.",
            websiteURL: URL(string: "https://www.paleisamsterdam.nl"),
            bookingURL: URL(string: "https://tickets.paleisamsterdam.nl/en-US/tickets"),
            infoURL: URL(string: "https://en.wikipedia.org/wiki/Royal_Palace_of_Amsterdam"),
            openingHours: "Daily: 10:00 - 17:00 (closed during royal events)",
            admissionFee: "€12.50 adults, €9 students, free under 18",
            phoneNumber: "+31 20 5226 161",
            accessibilityInfo: "Wheelchair accessible, lift available",
            tags: ["history", "architecture", "royal"]
        ),

        Landmark(
            id: UUID(),
            name: "Begijnhof",
            description: "One of the oldest inner courts in Amsterdam, founded in 1346.",
            location: Location(latitude: 52.3692, longitude: 4.8897),
            estimatedTime: 15,
            imageURL: "https://upload.wikimedia.org/wikipedia/commons/thumb/3/3a/Begijnhof_Amsterdam.jpg/800px-Begijnhof_Amsterdam.jpg",
            rating: 4.6,
            detailedDescription: "The Begijnhof is one of the oldest inner courts in the city of Amsterdam. A group of historic buildings, mostly private dwellings, centre on it. As the name suggests, it was originally a Béguinage. Today it is also the site of two churches, the Catholic Houten Huys and the English Reformed Church.",
            websiteURL: nil,
            bookingURL: nil,
            infoURL: URL(string: "https://en.wikipedia.org/wiki/Begijnhof,_Amsterdam"),
            openingHours: "Daily: 8:00 - 17:00 (church: 9:00 - 17:00)",
            admissionFee: "Free",
            phoneNumber: nil,
            accessibilityInfo: "Quiet residential area - please respect residents' privacy",
            tags: ["history", "architecture", "hidden-gem"]
        ),

        // Parks
        Landmark(
            id: UUID(),
            name: "Vondelpark",
            description: "Amsterdam's most famous park, perfect for a leisurely stroll.",
            location: Location(latitude: 52.3584, longitude: 4.8699),
            estimatedTime: 30,
            imageURL: "https://upload.wikimedia.org/wikipedia/commons/thumb/e/e1/Vondelpark_Amsterdam.jpg/1200px-Vondelpark_Amsterdam.jpg",
            rating: 4.6,
            detailedDescription: "Vondelpark is a public urban park of 47 hectares in Amsterdam. It is Amsterdam's most popular park, attracting thousands of visitors every day. The park opened in 1865 and is named after the 17th-century playwright Joost van den Vondel. It features an open-air theatre, playgrounds, and several cafés.",
            websiteURL: URL(string: "https://www.iamsterdam.com/en/see-and-do/things-to-do/parks-and-outdoor/vondelpark"),
            bookingURL: nil,
            infoURL: URL(string: "https://en.wikipedia.org/wiki/Vondelpark"),
            openingHours: "Open 24 hours",
            admissionFee: "Free",
            phoneNumber: nil,
            accessibilityInfo: "Wheelchair accessible paths throughout",
            tags: ["park", "outdoor", "free"]
        ),

        // Canal Cruises
        Landmark(
            id: UUID(),
            name: "Canal Cruise - Stromma",
            description: "Classic Amsterdam canal cruise through the UNESCO World Heritage canals.",
            location: Location(latitude: 52.3718, longitude: 4.8936),
            estimatedTime: 60,
            imageURL: "https://upload.wikimedia.org/wikipedia/commons/thumb/3/3a/Amsterdam_Canal_Cruise.jpg/800px-Amsterdam_Canal_Cruise.jpg",
            rating: 4.3,
            detailedDescription: "Experience Amsterdam's famous canals on a relaxing cruise. Stromma offers classic canal cruises with audio commentary in multiple languages. See the historic canal houses, bridges, and houseboats while learning about Amsterdam's Golden Age history.",
            websiteURL: URL(string: "https://www.stromma.com"),
            bookingURL: URL(string: "https://www.stromma.com/en-nl/amsterdam/sightseeing/canal-tours/"),
            infoURL: nil,
            openingHours: "Daily: 9:00 - 22:00 (varies by season)",
            admissionFee: "€16-18 adults (online discount available)",
            phoneNumber: "+31 20 2170 500",
            accessibilityInfo: "Most boats wheelchair accessible, check when booking",
            tags: ["cruise", "outdoor", "canals"]
        ),

        Landmark(
            id: UUID(),
            name: "Lovers Canal Cruises",
            description: "Popular canal cruise operator with multiple departure points.",
            location: Location(latitude: 52.3726, longitude: 4.8933),
            estimatedTime: 60,
            imageURL: "https://upload.wikimedia.org/wikipedia/commons/thumb/2/2a/Amsterdam_Canal_Boats.jpg/800px-Amsterdam_Canal_Boats.jpg",
            rating: 4.4,
            detailedDescription: "Lovers Canal Cruises offers a variety of canal cruises through Amsterdam's UNESCO World Heritage canals. Choose from classic cruises, hop-on-hop-off services, or evening cruises. Departure points at multiple locations including Central Station and Leidseplein.",
            websiteURL: URL(string: "https://www.lovers.nl"),
            bookingURL: URL(string: "https://www.lovers.nl/"),
            infoURL: nil,
            openingHours: "Daily: 9:00 - 22:00",
            admissionFee: "€16.50 adults (online from €13.50)",
            phoneNumber: "+31 20 2170 200",
            accessibilityInfo: "Wheelchair accessible boats available",
            tags: ["cruise", "outdoor", "canals"]
        ),

        // Dining & Cafes
        Landmark(
            id: UUID(),
            name: "Café de Jaren",
            description: "Grand café with one of the best terraces overlooking the Amstel river.",
            location: Location(latitude: 52.3669, longitude: 4.8950),
            estimatedTime: 45,
            imageURL: "https://upload.wikimedia.org/wikipedia/commons/thumb/4/4a/Cafe_de_Jaren_Amsterdam.jpg/800px-Cafe_de_Jaren_Amsterdam.jpg",
            rating: 4.3,
            detailedDescription: "Café de Jaren is a spacious grand café located in a historic building overlooking the Amstel river. Known for its high ceilings, marble floors, and especially its large waterside terrace. Perfect for coffee, lunch, or drinks with a view.",
            websiteURL: URL(string: "https://www.cafedejaren.nl"),
            bookingURL: nil,
            infoURL: nil,
            openingHours: "Daily: 10:00 - 01:00 (Fri-Sat until 02:00)",
            admissionFee: "Free entry, menu prices vary",
            phoneNumber: "+31 20 6255 771",
            accessibilityInfo: "Ground floor accessible, terrace accessible",
            tags: ["cafe", "dining", "terrace"]
        ),

        Landmark(
            id: UUID(),
            name: "Foodhallen",
            description: "Indoor food market in a former tram depot with international street food.",
            location: Location(latitude: 52.3667, longitude: 4.8672),
            estimatedTime: 60,
            imageURL: "https://upload.wikimedia.org/wikipedia/commons/thumb/5/5a/Foodhallen_Amsterdam.jpg/800px-Foodhallen_Amsterdam.jpg",
            rating: 4.5,
            detailedDescription: "Foodhallen is Amsterdam's first indoor food market, located in a beautifully restored former tram depot in the Oud-West neighborhood. It features over 20 food stalls offering everything from Dutch bitterballen to Vietnamese street food, plus craft beer and cocktails.",
            websiteURL: URL(string: "https://www.foodhallen.nl"),
            bookingURL: nil,
            infoURL: URL(string: "https://en.wikipedia.org/wiki/Foodhallen"),
            openingHours: "Sun-Thu: 11:00 - 23:00, Fri-Sat: 11:00 - 00:00",
            admissionFee: "Free entry, pay per vendor",
            phoneNumber: "+31 20 7520 800",
            accessibilityInfo: "Wheelchair accessible",
            tags: ["dining", "food-hall", "indoor"]
        ),

        Landmark(
            id: UUID(),
            name: "De Bakkerswinkel",
            description: "Cozy café famous for fresh bread, pastries, and hearty breakfasts.",
            location: Location(latitude: 52.3738, longitude: 4.8866),
            estimatedTime: 30,
            imageURL: "https://upload.wikimedia.org/wikipedia/commons/thumb/3/3a/Bakkerswinkel_Amsterdam.jpg/800px-Bakkerswinkel_Amsterdam.jpg",
            rating: 4.4,
            detailedDescription: "De Bakkerswinkel is a beloved Amsterdam café chain known for its artisanal bread, fresh pastries, and cozy atmosphere. The Westergas location is particularly charming. Perfect for breakfast, brunch, or afternoon coffee with homemade cake.",
            websiteURL: URL(string: "https://www.bakkerswinkel.nl"),
            bookingURL: nil,
            infoURL: nil,
            openingHours: "Mon-Fri: 7:00 - 18:00, Sat-Sun: 8:00 - 18:00",
            admissionFee: "Menu: €5-15",
            phoneNumber: "+31 20 6810 388",
            accessibilityInfo: "Ground floor accessible",
            tags: ["cafe", "breakfast", "bakery"]
        ),

        // Markets
        Landmark(
            id: UUID(),
            name: "Albert Cuyp Market",
            description: "Amsterdam's most famous street market with over 260 stalls.",
            location: Location(latitude: 52.3559, longitude: 4.8948),
            estimatedTime: 45,
            imageURL: "https://upload.wikimedia.org/wikipedia/commons/thumb/4/4a/Albert_Cuyp_Market.jpg/800px-Albert_Cuyp_Market.jpg",
            rating: 4.4,
            detailedDescription: "The Albert Cuyp Market is a street market in Amsterdam, on the Albert Cuypstraat in De Pijp area. It's the busiest market in the Netherlands, with over 260 stalls selling everything from fresh produce and cheese to clothing and souvenirs. Try the famous stroopwafels here!",
            websiteURL: URL(string: "https://www.albertcuyp-markt.amsterdam"),
            bookingURL: nil,
            infoURL: URL(string: "https://en.wikipedia.org/wiki/Albert_Cuyp_Market"),
            openingHours: "Mon-Sat: 9:00 - 17:00 (closed Sundays)",
            admissionFee: "Free",
            phoneNumber: "+31 20 5523 570",
            accessibilityInfo: "Flat market street, accessible",
            tags: ["market", "shopping", "food"]
        ),

        // Shopping
        Landmark(
            id: UUID(),
            name: "De Negen Straatjes (The Nine Streets)",
            description: "Charming shopping area with vintage stores, boutiques, and cafés.",
            location: Location(latitude: 52.3695, longitude: 4.8842),
            estimatedTime: 60,
            imageURL: "https://upload.wikimedia.org/wikipedia/commons/thumb/3/3a/De_Negen_Straatjes.jpg/800px-De_Negen_Straatjes.jpg",
            rating: 4.6,
            detailedDescription: "De Negen Straatjes (The Nine Streets) is a neighborhood of Amsterdam, consisting of nine side streets off the Prinsengracht, Keizersgracht, Herengracht and Singel in central Amsterdam. It's famous for its boutique shops, vintage stores, art galleries, and cozy cafés.",
            websiteURL: URL(string: "https://www.de9straatjes.nl"),
            bookingURL: nil,
            infoURL: URL(string: "https://en.wikipedia.org/wiki/De_Negen_Straatjes"),
            openingHours: "Shops: Mon 12:00-18:00, Tue-Sat 10:00-18:00, Sun 12:00-17:00",
            admissionFee: "Free",
            phoneNumber: nil,
            accessibilityInfo: "Cobblestone streets, some areas may be challenging",
            tags: ["shopping", "boutique", "historic"]
        ),

        // Hidden Gems
        Landmark(
            id: UUID(),
            name: "Hortus Botanicus",
            description: "One of the oldest botanical gardens in the world, founded in 1638.",
            location: Location(latitude: 52.3667, longitude: 4.9076),
            estimatedTime: 60,
            imageURL: "https://upload.wikimedia.org/wikipedia/commons/thumb/4/4a/Hortus_Botanicus_Amsterdam.jpg/800px-Hortus_Botanicus_Amsterdam.jpg",
            rating: 4.6,
            detailedDescription: "The Hortus Botanicus Amsterdam is one of the oldest botanic gardens in the world, established in 1638. It began as a medicinal herb garden and now houses over 6,000 tropical and indigenous trees and plants. The highlight is the beautiful 19th-century Palm House and the modern Three-Climate Greenhouse.",
            websiteURL: URL(string: "https://www.hortus-botanicus.nl"),
            bookingURL: URL(string: "https://www.dehortus.nl/en/plan-your-visit/"),
            infoURL: URL(string: "https://en.wikipedia.org/wiki/Hortus_Botanicus_Amsterdam"),
            openingHours: "Daily: 10:00 - 17:00 (Fri until 20:00)",
            admissionFee: "€12.50 adults, €6 students, free under 18",
            phoneNumber: "+31 20 6258 216",
            accessibilityInfo: "Wheelchair accessible, some narrow paths in greenhouses",
            tags: ["garden", "nature", "hidden-gem"]
        ),

        Landmark(
            id: UUID(),
            name: "NDSM Wharf",
            description: "Hip cultural hotspot in a former shipyard across the IJ river.",
            location: Location(latitude: 52.4005, longitude: 4.8926),
            estimatedTime: 90,
            imageURL: "https://upload.wikimedia.org/wikipedia/commons/thumb/5/5a/NDSM_Warf_Amsterdam.jpg/800px-NDSM_Warf_Amsterdam.jpg",
            rating: 4.5,
            detailedDescription: "NDSM is a former shipyard on the banks of the River IJ in Amsterdam. Transformed into a vibrant cultural hotspot, it now features street art, artist studios, cafés, restaurants, and a hotel. Take the free ferry from Central Station for a unique Amsterdam experience.",
            websiteURL: URL(string: "https://www.ndsm.nl"),
            bookingURL: nil,
            infoURL: URL(string: "https://en.wikipedia.org/wiki/NDSM"),
            openingHours: "Public area: 24/7, venues vary",
            admissionFee: "Free (ferry is free)",
            phoneNumber: nil,
            accessibilityInfo: "Ferry and main areas accessible",
            tags: ["culture", "street-art", "hip", "free"]
        ),
    ]

    // MARK: - Utrecht Landmarks

    static let utrechtLandmarks: [Landmark] = [
        Landmark(
            id: UUID(),
            name: "Dom Tower",
            description: "Tallest church tower in the Netherlands at 112 meters.",
            location: Location(latitude: 52.0908, longitude: 5.1214),
            estimatedTime: 60,
            imageURL: "https://upload.wikimedia.org/wikipedia/commons/thumb/6/6e/Dom_Tower_Utrecht.jpg/800px-Dom_Tower_Utrecht.jpg",
            rating: 4.8,
            detailedDescription: "The Dom Tower of Utrecht is the tallest church tower in the Netherlands, at 112.5 metres in height. It's the symbol of the city and offers spectacular views after climbing 465 steps. The tower was part of St. Martin's Cathedral before the nave collapsed in 1674.",
            websiteURL: URL(string: "https://www.domtoren.nl"),
            bookingURL: URL(string: "https://www.domtoren.nl/en/tickets/"),
            infoURL: URL(string: "https://en.wikipedia.org/wiki/Dom_Tower_of_Utrecht"),
            openingHours: "Tue-Sun: 10:00 - 17:00 (guided tours only)",
            admissionFee: "€13 adults, €8.50 youth 4-12, free under 4",
            phoneNumber: "+31 30 2360 010",
            accessibilityInfo: "Tower climb requires good mobility - 465 steps, no elevator",
            tags: ["history", "architecture", "must-see"]
        ),

        Landmark(
            id: UUID(),
            name: "Oudegracht",
            description: "Utrecht's famous canal with unique wharf cellars at water level.",
            location: Location(latitude: 52.0920, longitude: 5.1190),
            estimatedTime: 30,
            imageURL: "https://upload.wikimedia.org/wikipedia/commons/thumb/7/7f/Oudegracht_Utrecht.jpg/800px-Oudegracht_Utrecht.jpg",
            rating: 4.9,
            detailedDescription: "The Oudegracht (Old Canal) runs through the center of Utrecht. What makes it unique are the wharf cellars - spaces at water level that were originally used for storage and trade, now converted into restaurants, cafés, and galleries. A boat tour here is highly recommended.",
            websiteURL: nil,
            bookingURL: nil,
            infoURL: URL(string: "https://en.wikipedia.org/wiki/Oudegracht"),
            openingHours: "Public space: 24/7",
            admissionFee: "Free",
            phoneNumber: nil,
            accessibilityInfo: "Accessible paths along canal, wharf levels have stairs",
            tags: ["canals", "outdoor", "free", "must-see"]
        ),

        Landmark(
            id: UUID(),
            name: "Centraal Museum",
            description: "Municipal museum with art, design, and local history.",
            location: Location(latitude: 52.0833, longitude: 5.1242),
            estimatedTime: 90,
            imageURL: "https://upload.wikimedia.org/wikipedia/commons/thumb/4/4a/Centraal_Museum_Utrecht.jpg/800px-Centraal_Museum_Utrecht.jpg",
            rating: 4.4,
            detailedDescription: "The Centraal Museum is the main museum in Utrecht. It has a large art collection with works by the Utrecht Caravaggisti, including Hendrick ter Brugghen and Gerard van Honthorst. It also houses the world's largest collection of works by designer Gerrit Rietveld.",
            websiteURL: URL(string: "https://www.centraalmuseum.nl"),
            bookingURL: URL(string: "https://www.centraalmuseum.nl/en/visit"),
            infoURL: URL(string: "https://en.wikipedia.org/wiki/Centraal_Museum"),
            openingHours: "Tue-Sun: 11:00 - 17:00",
            admissionFee: "€15 adults, €8 students, free under 18",
            phoneNumber: "+31 30 2362 362",
            accessibilityInfo: "Fully wheelchair accessible",
            tags: ["museum", "art", "design"]
        ),

        Landmark(
            id: UUID(),
            name: "Griftpark",
            description: "Popular city park with playground, skate park, and petting zoo.",
            location: Location(latitude: 52.0978, longitude: 5.1295),
            estimatedTime: 30,
            imageURL: "https://upload.wikimedia.org/wikipedia/commons/thumb/5/5a/Griftpark_Utrecht.jpg/800px-Griftpark_Utrecht.jpg",
            rating: 4.5,
            detailedDescription: "Griftpark is a beautiful park just outside the old city center of Utrecht. It features a large playground, skate park, petting zoo, and several cafés. It's a favorite spot for locals to relax, exercise, and enjoy picnics on sunny days.",
            websiteURL: nil,
            bookingURL: nil,
            infoURL: URL(string: "https://en.wikipedia.org/wiki/Griftpark"),
            openingHours: "Open 24 hours",
            admissionFee: "Free",
            phoneNumber: nil,
            accessibilityInfo: "Wheelchair accessible paths",
            tags: ["park", "outdoor", "free", "family-friendly"]
        ),
    ]

    // MARK: - Helper Methods

    static func landmarks(near polylineCoordinates: [CLLocationCoordinate2D], maxDistanceMeters: CLLocationDistance = 150, limit: Int = 4) -> [Landmark] {
        guard !polylineCoordinates.isEmpty else { return [] }

        // Cheap approximation: take min distance to any polyline vertex.
        // For V1 this is "good enough" and avoids heavier geometry.
        let polylineLocations = polylineCoordinates.map { CLLocation(latitude: $0.latitude, longitude: $0.longitude) }

        let scored: [(Landmark, CLLocationDistance)] = all.map { poi in
            let poiLoc = CLLocation(latitude: poi.location.latitude, longitude: poi.location.longitude)
            let minDist = polylineLocations.reduce(CLLocationDistance.greatestFiniteMagnitude) { currentMin, vertex in
                min(currentMin, vertex.distance(from: poiLoc))
            }
            return (poi, minDist)
        }

        return scored
            .filter { $0.1 <= maxDistanceMeters }
            .sorted { $0.1 < $1.1 }
            .prefix(limit)
            .map { $0.0 }
    }

    /// Get landmarks by category
    static func landmarks(inCategory category: LandmarkCategory) -> [Landmark] {
        all.filter { landmark in
            landmark.tags.contains(category.rawValue) ||
            landmark.tags.contains(where: { $0.lowercased() == category.rawValue.lowercased() })
        }
    }

    /// Get bookable landmarks
    static var bookableLandmarks: [Landmark] {
        all.filter { $0.isBookable }
    }

    /// Get free landmarks
    static var freeLandmarks: [Landmark] {
        all.filter { landmark in
            guard let fee = landmark.admissionFee else { return true }
            return fee.lowercased().contains("free")
        }
    }
}
