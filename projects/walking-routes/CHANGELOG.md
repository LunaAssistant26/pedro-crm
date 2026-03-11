# Walking Routes - Changelog

## Sprint 10 - Muter Video (Route Walk + Look Around + Photo) - 2026-03-10

- Added **Create Muter Video** post-walk action.
- New `MuterVideoGenerator`:
  - Generates a vertical **1080×1920** MP4 via **AVAssetWriter**.
  - Renders a route-wide **map snapshot** with route polyline + numbered stop markers.
  - Animates a small walking dot between stops.
  - Per stop: map zoom-in → **Look Around snapshot** (when available) → crossfade to user photo (Ken Burns) → zoom out.
  - Falls back to zoomed map when Look Around is unavailable.
  - Progress reporting.
  - Includes helper to **save MP4 to Photos**.
- New `MuterVideoPreviewView`:
  - Auto-generates and previews the video.
  - Save-to-Photos + Share actions.

### Files Created/Modified
- NEW: `Services/MuterVideoGenerator.swift`
- NEW: `Views/MuterVideoPreviewView.swift`
- MOD: `Views/FinishWalk/FinishWalkActionsSheetView.swift` (added button)
- MOD: `Views/NavigationView.swift` (present preview sheet)

---

## Sprint 9 - Collage Enhancements (Video + Look Around Transition) - 2026-03-05

### A) Video from Photos (Collage) ✅
- Added **Create Video** action to `CollageEditorView`.
- Implemented `RouteVideoGenerator` using `AVAssetWriter` to generate an MP4 slideshow from selected route photos:
  - ~2.5s per photo with a lightweight crossfade transition
  - Simple timestamp/coordinate text overlay
  - Progress reporting during generation
- Exports the resulting MP4 to the user’s **Photos** library for easy sharing.

### B) Map → Look Around → Photo transition (unique feature!) ✅
- Added **View Location** button to photo detail when the photo has coordinates.
- New `LookAroundTransitionView`:
  - Shows Map first
  - Loads and displays **MapKit Look Around** (`MKLookAroundSceneRequest` + `MKLookAroundViewController`) when available
  - Fades back to the user’s photo
  - Graceful fallback when Look Around is unavailable (map-only, with **satellite map** fallback)

### Files Created/Modified
- NEW: `Services/RouteVideoGenerator.swift`
- NEW: `Views/LookAround/LookAroundTransitionView.swift`
- MOD: `Views/Collage/CollageEditorView.swift`
- MOD: `Views/Camera/PhotoCaptureView.swift` (photo detail → View Location)

---

## Sprint 8 - Turn-by-Turn Navigation + In-Nav Photos + Wrong-Turn Detection - 2026-03-05

### Turn-by-turn navigation UI (MVP) ✅
- Upgraded `RouteNavigationView` to a Maps-like turn-by-turn experience:
  - Large, glanceable “Next instruction” card
  - Distance-to-next maneuver
  - Step progress indicator
  - Optional haptics on step change

- Added `NavigationStep` model (Codable) to persist/transport MapKit step data.
- Extended `Route` model with optional `navigationSteps`.
- Generated loop routes now persist steps during route generation (no extra Directions calls at nav time).
- Added `NavigationDirectionsService` actor:
  - On-demand step computation for demo/static routes
  - In-memory cache keyed by `route.id` with TTL to reduce MKDirections calls
  - Simplifies waypoints to bound directions legs (rate-limit friendly)

### In-navigation photo capture (geo-tagged) ✅
- Added camera button overlay in `RouteNavigationView`.
- Captured photos are stored via existing `PhotoService` with:
  - routeId + timestamp
  - coordinate from live GPS when available
  - fallback snapping to nearest polyline point / maneuver coordinate

### Wrong-turn detection + re-route (simple MVP) ✅
- Added simple off-route detection in navigation:
  - Computes distance-to-route polyline periodically from live location
  - If > ~60m for ~6 seconds, shows “You’re off route” banner
- Added “Re-route” button:
  - Creates a mini walking route from current location → next maneuver coordinate
  - Prepends those steps, then continues the remaining route
  - Cooldown to avoid spamming Directions calls

### Demo Navigation mode (no GPS required) ✅
- Navigation now defaults to a **demo mode** (no location permission prompt required).
- Real GPS navigation is still available behind a toggle: `UserDefaults` key `useRealGPSNavigation`.
- If real GPS nav is enabled but **permission isn’t granted** or **no fix arrives within 2 seconds**, the UI automatically falls back to demo mode.
- In demo mode, steps advance automatically every ~5–8 seconds, and there’s also a manual **Next** button.

### Finish Walk flow (post-walk actions: collage + share) ✅
- Added a **Finish Walk** affordance inside turn-by-turn navigation:
  - Prominent button when you reach the final step (Arrive at destination)
  - Also available as a smaller button mid-walk (manual finish)
- On finish, a modal sheet shows:
  - Route stats (estimated duration + distance)
  - Photo count
  - Primary CTA: **Create Collage** (enabled only when photos exist)
  - Secondary CTA: **Share Route**
- Persisted completion state locally (`UserDefaults`) so routes can be re-opened and show a **Completed** badge.

### Fix: Exit/Camera buttons not tappable ✅
- Reworked the navigation layout to ensure top controls are always layered above the underlying `MKMapView`.

### Files Created/Modified
- NEW: `Models/NavigationStep.swift`
- NEW: `Models/NavigationStep+MapKit.swift`
- NEW: `Services/NavigationDirectionsService.swift`
- NEW: `Utilities/PolylineMath.swift`
- NEW: `Utilities/RouteCompletionStore.swift`
- NEW: `Views/FinishWalk/FinishWalkActionsSheetView.swift`
- MOD: `App/WalkingRoutesApp.swift` (added `AppFlags` UserDefaults feature toggle)
- NEW: `ViewModels/RouteNavigationViewModel.swift`
- MOD: `ViewModels/RouteNavigationViewModel.swift` (finish detection helper)
- MOD: `Views/NavigationView.swift` (Finish Walk UI + post-walk actions)
- MOD: `Views/RouteDetailView.swift` (Completed badge)
- MOD: `Models/Route.swift` (added `navigationSteps`)
- MOD: `Services/RouteGenerationService.swift` (persist steps for generated loops)
- MOD: `ViewModels/RouteViewModel.swift` (propagate `navigationSteps`)

---

## Sprint 7 - Social Sharing + Photo Collage Features (Task 1) - 2026-03-04

### Social Sharing ✅
- Created `ShareService.swift` - handles all sharing logic:
  - Generate shareable images with route map + stats
  - Support for Instagram Stories format (9:16 aspect ratio)
  - Deep link generation for route sharing
  - Multiple template options (share card, story format)
  - Custom image rendering with UIGraphicsImageRenderer

- Created `ShareSheetView.swift` - UI for sharing options:
  - Live preview of share image
  - Template selector (Story, Grid, etc.)
  - Direct share to Instagram, Stories
  - System share sheet integration
  - Copy image to clipboard for Instagram

- Created `RouteSnapshotGenerator.swift` - map snapshot generation:
  - Generate high-quality map snapshots for sharing
  - Draw route path with custom styling
  - Add start/end markers and landmark pins
  - Configurable snapshot size

### Photo Capture During Walk ✅
- Created `PhotoCaptureView.swift` - camera integration:
  - UIImagePickerController for photo capture
  - Photo library access for choosing existing photos
  - Grid view of captured photos
  - Note editor for adding captions
  - Photo detail view with metadata
  - Delete photo functionality

- Created `PhotoService.swift` - photo storage management:
  - Save photos to app's documents directory
  - Associate photos with specific routes
  - Store location metadata with photos
  - Load and cache photos efficiently
  - Delete individual or all route photos

- Extended `Route.swift` model:
  - Added `photos` computed property via extension
  - Photos retrieved from PhotoService by route ID

- Created `RoutePhoto.swift` model:
  - UUID, routeId, timestamp, location
  - Filename for storage reference
  - Optional note/caption
  - File URL helper method

### Photo Collage Generation ✅
- Created `CollageGenerator.swift` - collage generation engine:
  - Multiple template layouts: 2x2 Grid, 3x3 Grid, Film Strip, Story Format, Polaroid
  - UIGraphicsImageRenderer for high-quality output
  - Combine route map with captured photos
  - Custom styling for each template
  - Route info overlay on collages

- Created `CollageTemplate.swift` - template definitions:
  - 5 different layout templates
  - Aspect ratio configuration (square, landscape, portrait)
  - Max photos per template
  - Icon names for UI
  - Template selection logic

- Created `CollageEditorView.swift` - collage creation UI:
  - Live preview of collage
  - Template selector with availability indicators
  - Photo selector with multi-select
  - Generate and share buttons
  - Save to photo library option

### Route Detail View Updates ✅
- Added action buttons row with:
  - Share button (opens ShareSheetView)
  - Photos button (opens PhotoCaptureView)
  - Collage button (opens CollageEditorView)
- Visual design with color-coded buttons
- Sheet presentations for each feature

### Technical Requirements Met ✅
- SwiftUI for all UI components
- iOS 17+ APIs used where beneficial
- Photos stored in app's documents directory
- Core Data/SwiftData compatible photo references
- Photo library permissions handled appropriately
- Memory-efficient image handling
- @MainActor for UI updates

### Files Created/Modified
| File | Changes |
|------|---------|
| `Services/ShareService.swift` | NEW - Social sharing logic |
| `Services/PhotoService.swift` | NEW - Photo storage management |
| `Services/CollageGenerator.swift` | NEW - Collage generation engine |
| `Views/Share/ShareSheetView.swift` | NEW - Share UI with templates |
| `Views/Camera/PhotoCaptureView.swift` | NEW - Camera and photo management |
| `Views/Collage/CollageEditorView.swift` | NEW - Collage creation UI |
| `Models/RoutePhoto.swift` | NEW - Photo model |
| `Models/CollageTemplate.swift` | NEW - Template definitions |
| `Utilities/RouteSnapshotGenerator.swift` | NEW - Map snapshot generation |
| `Views/RouteDetailView.swift` | Added share/photos/collage buttons |

---

## Sprint 6 - Enhanced Landmark Details + Booking Links (Task 2) - 2026-03-04

### Enhanced Landmark Model ✅
- Extended `Landmark` model with rich details:
  - `detailedDescription` - Longer text (200-500 chars) for full descriptions
  - `websiteURL` - Official landmark website
  - `bookingURL` - Direct booking/tickets link
  - `infoURL` - Wikipedia, tourism site, etc.
  - `openingHours` - Human-readable hours (e.g., "Mon-Sun: 9:00-18:00")
  - `admissionFee` - Pricing info (e.g., "€22.50 adults, free under 18")
  - `phoneNumber` - For phone bookings
  - `accessibilityInfo` - Accessibility notes
  - `tags` - Array of category tags for filtering
  - `isBookable` - Computed property indicating if bookingURL exists
  - `primaryTag` - Convenience for grouping
- Added custom Codable implementation for proper URL encoding/decoding
- Added comprehensive initializer for creating enriched landmarks

### Landmark Detail View (New) ✅
- Created `LandmarkDetailView.swift` with rich presentation:
  - Hero image with gradient overlay
  - Bookable badge indicator on image
  - Title, rating, and estimated visit time
  - Flow layout for tags/chips
  - Full description (detailedDescription or fallback to description)
  - Practical information section with:
    - Opening hours with clock icon
    - Admission fees with euro icon
    - Phone number with phone icon
    - Accessibility info with accessibility icon
  - Action buttons:
    - "Book Tickets" (primary CTA if bookingURL exists)
    - "Visit Website" (secondary)
    - "More Info" (tertiary)
    - "Call" (if phoneNumber exists)
    - "Get Directions" (opens in Maps)
- Integrated `SFSafariViewController` via `SafariView` wrapper
- Full dark mode support
- Accessibility labels for all interactive elements

### Analytics Service (New) ✅
- Created `AnalyticsService` for tracking user interactions:
  - `landmarkViewed` - When detail view is opened
  - `bookingLinkTapped` - When user taps book tickets
  - `websiteVisited` - When user visits official website
  - `directionsRequested` - When user requests directions
  - `phoneCallInitiated` - When user taps call button
- Console logging for development (ready for Firebase/Mixpanel integration)

### Landmark Card (New) ✅
- Created `LandmarkCard.swift` with enhanced design:
  - Image with index badge (numbered stop)
  - Bookable ticket badge overlay
  - Title and estimated time badge
  - Description with 2-line limit
  - Rating stars and primary tag
  - Estimated walk time from route start
  - Full accessibility support
- Created `CompactLandmarkCard` for list views
- Both cards are tappable and open detail view

### Landmark List View (New) ✅
- Created `LandmarkListView.swift` with filtering:
  - Search bar for filtering by name/description/tags
  - Horizontal scrollable category filter chips
  - Grouping by category (museums, parks, dining, etc.)
  - Results count and clear filters option
  - Empty state when no results
- `LandmarkCategory` enum with:
  - 11 categories: museum, art, history, park, outdoor, dining, cafe, shopping, architecture, entertainment, other
  - Display names, icons, and colors
  - Tag parsing from strings

### Data Enrichment ✅
- Completely rewrote `PointsOfInterest.swift` with 20+ Amsterdam landmarks:
  **Museums:**
  - Rijksmuseum (rijksmuseum.nl, €22.50, booking link)
  - Van Gogh Museum (vangoghmuseum.nl, €22, booking link)
  - Anne Frank House (annefrank.org, €16, booking link)
  - Stedelijk Museum (stedelijk.nl, €22.50, booking link)
  - Heineken Experience (heinekenexperience.com, €23, booking link)
  
  **Historic Sites:**
  - Westerkerk (westerkerk.nl, free/tower €12)
  - Royal Palace (paleisamsterdam.nl, €12.50, booking link)
  - Begijnhof (free, Wikipedia info)
  
  **Parks:**
  - Vondelpark (free, 24/7)
  - Hortus Botanicus (€12.50, booking link)
  
  **Canal Cruises:**
  - Stromma Canal Cruises (stromma.com, €16-18, booking link)
  - Lovers Canal Cruises (lovers.nl, €16.50, booking link)
  
  **Dining & Cafés:**
  - Café de Jaren (cafedejaren.nl)
  - Foodhallen (foodhallen.nl)
  - De Bakkerswinkel (bakkerswinkel.nl)
  
  **Markets & Shopping:**
  - Albert Cuyp Market (free)
  - De Negen Straatjes (shopping district)
  
  **Hidden Gems:**
  - NDSM Wharf (free, ferry accessible)
  
  **Utrecht:**
  - Dom Tower (domtoren.nl, €13, booking link)
  - Oudegracht (free)
  - Centraal Museum (€15, booking link)
  - Griftpark (free)

- All landmarks include:
  - Real URLs (verified working)
  - Accurate opening hours
  - Current admission fees (2024)
  - Phone numbers
  - Accessibility information
  - Relevant tags for categorization

### Route Detail View Updates ✅
- Redesigned landmark section:
  - Route stats row with duration, distance, stops count, rating
  - Grouped display by category
  - Full LandmarkCard for first 2 landmarks
  - "See All" button for full list view
  - "+N more landmarks" preview button
  - Bookable attractions count indicator
  - Empty state when no landmarks
- Estimated walk time calculation to each landmark
- Better spacing and visual hierarchy

### Technical Improvements ✅
- All UI built with SwiftUI
- SafariView for in-app web browsing with SFSafariViewController
- Graceful URL opening with fallback handling
- Full dark mode support throughout
- Comprehensive accessibility labels
- FlowLayout custom layout for tag wrapping
- os.Logger integration for debugging

### Files Created/Modified
| File | Changes |
|------|---------|
| `Models/Route.swift` | Extended Landmark model with new fields, custom Codable |
| `Views/Landmarks/LandmarkDetailView.swift` | NEW - Rich detail view with booking links |
| `Views/Landmarks/LandmarkCard.swift` | NEW - Enhanced landmark cards |
| `Views/Landmarks/LandmarkListView.swift` | NEW - List with filtering and categories |
| `Views/Routes/RouteDetailView.swift` | Redesigned landmark section, stats row |
| `Services/PointsOfInterest.swift` | Complete rewrite with 20+ enriched landmarks |

---

## Sprint 5 - Dynamic Loop Generation (V1) - 2026-03-03

### Core UX (Sample routes → generated loops) ✅
- Replaced the pre-defined `SampleData` route UX with dynamic loop generation.
- User selects a time budget (5–180 min) and the app generates **2–3 loop options**.
- Loops start and end at the same coordinate.

### Location permission handling ✅
- App now shows a clear location status card:
  - **Allow Location** when status is `.notDetermined`
  - **Open Settings** when `.denied/.restricted`
- If location isn't available/authorized, the app **falls back to Amsterdam Centraal** (demo-only) and shows a banner explaining it.

### Route generation algorithm (throttle-safe) ✅
- Assumes **4.8 km/h** walking speed to estimate distance budget.
- Builds *true loops* using **2 waypoints** (3 walking legs):
  - start→wp1→wp2→start
- Uses a **deterministic** set of bearing pairs (no randomized candidate expansion).
- Hard-bounds work per generation to **<= 12 MKDirections requests**:
  - 4 candidates × 3 legs each
- Radius is kept conservative (≈ **32%** of distance budget, clamped for short walks) to reduce "no pedestrian path" failures.
- If Directions are unavailable, the UI keeps the **last successful** routes and shows an error message (no fake circle routes).

### Async, cancellation, caching ✅
- Generation runs asynchronously with a loading state.
- Adds **debounce (~500ms idle)** so rapid slider changes don't spam Directions.
- Cancels in-flight generation when the user changes time and calls **`MKDirections.cancel()`** for active requests.
- Caches results keyed by **(rounded coordinate, time)** with a **30s TTL**, and skips regeneration when the same inputs were just computed.

### Optional highlights (POIs) ✅
- Keeps a small static POI list (Amsterdam/Utrecht).
- Selects POIs near the generated polyline corridor (≈150m) and shows them as optional highlights.
- If a route includes POIs, the route card label is updated to include a highlight, e.g. `Loop Option 1 • Highlights: Anne Frank House`.
- If none match, description shows "Nice walk" and highlights stay empty.

### Code changes summary
- `ContentView.swift`: new loop-only UX + permission prompt + loading state
- `RouteViewModel.swift`: route generation orchestration + cancellation + caching + POI attachment
- `NavigationView.swift`: `LocationManager` now publishes `authorizationStatus` and supports requesting auth

---

## Sprint 4 Fixes - 2026-03-03

### 1. Fixed AsyncImage Gray Boxes ✅
- **Root cause**: URLs were being constructed even when empty or invalid, causing AsyncImage to fail silently
- **Fix**: Added proper URL validation in `RouteCard`, `HeroSection`, and `LandmarkCard`
  - Only create URL when string is non-empty and valid
  - Added debug logging for image load failures using `os.Logger`
  - Shows placeholder with `photo` icon when image fails or is unavailable
  - Shows `ProgressView` while loading

### 2. RouteDetail Map Now Fits Entire Route ✅
- **Problem**: Map was too zoomed in, not showing all landmarks
- **Fix**: Updated `RouteMapViewRepresentable` with new `fitToRoute` parameter
  - Calculates bounding map rect that includes all landmarks and route polylines
  - Uses `MKMapRect.union()` to combine all bounding rects
  - Applies `UIEdgeInsets(top: 60, left: 40, bottom: 60, right: 40)` padding
  - Ensures minimum map size to avoid over-zooming on single points
  - Falls back to straight-line polylines if MKDirections fails

### 3. City Selector Added ✅
- **New**: Segmented control with options: "Near me", "Amsterdam", "Utrecht"
- **Behavior**:
  - "Near me": Uses location to detect closest city (Amsterdam or Utrecht), falls back to Amsterdam if no location
  - "Amsterdam"/"Utrecht": Filters routes to show only that city's routes
- **Header text**: Dynamically updates based on selection ("Discover Amsterdam", "Discover Utrecht", "Discover Nearby")
- Added `CityOption` enum and `CitySelectorView` component

### 4. V1 Behavior Clarification ✅
- Added explanatory label under header: "Curated sample routes for now — loops from any location coming later"
- Uses caption style with secondary text color for subtle appearance

### Code Changes Summary
| File | Changes |
|------|---------|
| `ContentView.swift` | City selector, V1 label, header title logic, improved AsyncImage |
| `RouteDetailView.swift` | Fixed AsyncImage in HeroSection and LandmarkCard with logging |
| `NavigationView.swift` | Added `fitToRoute` parameter, improved map fitting logic |
| `RouteViewModel.swift` | City filtering, `detectAndSetClosestCity()` method |

---

## Sprint 3 Fixes - 2026-03-03

### 1. Landmark Cards Tappable ✅
- Landmark cards on RouteDetailView are now tappable
- Opens a sheet with LandmarkDetailView showing full description, photo, rating, etc.
- Added print logging for debugging tap events

### 2. Navigation Exit Button Fixed ✅
- Changed from NavigationLink to fullScreenCover for navigation view
- Added `.navigationBarHidden(true)` to RouteNavigationView
- Added comprehensive logging using os.Logger for debugging navigation issues
- Exit button now properly dismisses using `@Environment(\.dismiss)`
- Added `onDisappear` cleanup to stop location updates

### 3. Improved Time-Based Recommendations ✅
- Updated `filterRoutes(by:)` algorithm to show:
  - 2-3 routes close to target time (within ±15 min)
  - Plus 1 shorter route if available
  - Plus 1 longer route if available
- Results sorted by duration for consistent display
- Added logging to track filter results

### 4. Added Utrecht Sample Routes ✅
- Added 3 Utrecht routes:
  - "Dom Tower & City Center" (45 min)
  - "Griftpark Loop" (30 min)
  - "Oudegracht Canal Walk" (60 min)
- Each route includes 3-5 landmarks with realistic Utrecht locations
- Added new route colors: domTower, griftPark, oudegracht

### 5. Added Feedback Entry Point ✅
- Added "Send Feedback" button at bottom of ContentView
- Created FeedbackView with form for text + optional email
- Feedback saved to UserDefaults with timestamp
- Created FeedbackStorage class for persistence
- Shows confirmation alert after submission

### 6. Defensive Coding & Crash Prevention ✅
- Added comprehensive os.Logger logging throughout:
  - NavigationView lifecycle events
  - LocationManager authorization and updates
  - Map rendering and directions calculation
  - Route filtering operations
- Added guards for empty coordinate arrays
- Added error handling for MKDirections failures
- LocationManager now properly checks authorization status before starting updates
- Added `stopUpdating()` method for proper cleanup
- Wrapped LocationManager initialization in try-catch

### Additional Routes Added
- "Museum Quarter Stroll" (90 min, Amsterdam)
- "De Pijp Food & Market Walk" (120 min, Amsterdam)
- "Plantage Garden Walk" (20 min, Amsterdam)

Total routes: 9 (6 Amsterdam, 3 Utrecht)
