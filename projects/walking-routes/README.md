# Walking Routes - iOS App

## App Concept
**Tagline:** "Discover the perfect walk, wherever you are"

**Problem:** When traveling, you have 1 hour free and want to explore on foot, but don't know where to go or what you'll see.

**Solution:** Input your available time, get curated walking routes with landmarks and points of interest.

## Core Features (MVP)

### 1. Time-Based Route Discovery
- User inputs available time (15min, 30min, 1hr, 2hr, custom)
- App shows multiple route options
- Each route shows: distance, estimated time, difficulty, highlights

### 2. Interactive Map
- Map with route overlay
- Markers for landmarks/POIs
- Current location
- Turn-by-turn walking directions

### 3. Landmark Information
- Points of interest along route
- Historical facts, photos, ratings
- Estimated time at each stop

### 4. Route Categories
- Quick city highlights (30min)
- Historic neighborhoods (1hr)
- Nature/parks (variable)
- Food & drink stops
- Photo opportunities

## Technical Stack
- **Framework:** SwiftUI
- **Maps:** MapKit (Apple Maps)
- **Location:** CoreLocation
- **Data:** Static JSON initially, API later
- **Storage:** UserDefaults for favorites

## Project Structure
```
WalkingRoutes/
├── WalkingRoutes/
│   ├── App/
│   │   └── WalkingRoutesApp.swift
│   ├── Views/
│   │   ├── ContentView.swift
│   │   ├── RouteListView.swift
│   │   ├── RouteDetailView.swift
│   │   ├── MapView.swift
│   │   └── TimeSelectorView.swift
│   ├── Models/
│   │   ├── Route.swift
│   │   ├── Landmark.swift
│   │   └── Location.swift
│   ├── ViewModels/
│   │   └── RouteViewModel.swift
│   └── Resources/
│       └── SampleRoutes.json
└── WalkingRoutes.xcodeproj
```

## Sample Routes (Amsterdam - for testing)
1. **Canal Ring Walk** (45 min)
   - Herengracht → Keizersgracht → Prinsengracht
   - Highlights: Anne Frank House, Westerkerk, Houseboat Museum

2. **Jordaan District** (1 hour)
   - Charming streets, cafes, boutiques
   - Highlights: Noordermarkt, Bloemgracht, Lindengracht

3. **Vondelpark Loop** (30 min)
   - Green escape in the city
   - Highlights: Vondelpark Pavilion, Open Air Theatre

## Build Automation
- Automated builds via script
- Screenshots captured after each milestone
- Videos recorded for demo walks

## Future Enhancements
- Integration with Foursquare/Google Places API
- User-generated routes
- Offline maps
- Audio guided tours
- Social sharing
- TripAdvisor integration
