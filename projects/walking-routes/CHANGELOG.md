# Walking Routes - Changelog

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
