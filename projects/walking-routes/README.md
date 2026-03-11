# Walking Routes - iOS App

## App Concept
**Tagline:** "Discover the perfect walk, wherever you are"

**Problem:** When traveling, you have 1 hour free and want to explore on foot, but don't know where to go or what you'll see.

**Solution:** Input your available time, get curated walking routes with landmarks and points of interest.

## Core Features

### 1. Time-Based Route Discovery
- User selects available time (15min, 30min, 1hr, 2hr, custom)
- App generates **2-3 loop options** dynamically
- Each route shows: distance, estimated time, difficulty, highlights
- Routes start and end at the same point (true loops)

### 2. Interactive Map
- Map with route overlay
- Numbered markers for landmarks/POIs
- Current location
- Turn-by-turn walking directions
- Map fits entire route with proper padding

### 3. Enhanced Landmark Information
- **Rich detail view** for each landmark:
  - Hero image with gradient overlay
  - Full description (200-500 chars)
  - Opening hours
  - Admission fees
  - Accessibility information
  - Category tags (museums, parks, dining, etc.)
  - Rating and estimated visit time
- **Direct booking links** for ticketed attractions
- **Website links** for more information
- **Phone numbers** for bookings
- **Get Directions** button opens in Maps
- **In-app Safari** for web browsing (no leaving the app)

### 4. Landmark Discovery
- **Category filtering**: Museums, Parks, Dining, History, Art, etc.
- **Search**: Find landmarks by name, description, or tags
- **Grouping**: Landmarks grouped by category in lists
- **Bookable badges**: Visual indicator for attractions with tickets
- **Estimated walk time**: Time to reach each landmark from start

### 5. Social Sharing 📸
- **Share routes** to Instagram, Snapchat, TikTok, WhatsApp, X, Telegram
- **Custom share images** with route map + stats
- **Instagram Stories format** (9:16 aspect ratio)
- **Deep links** so recipients can open routes in the app
- **Multiple templates**: Share card, Story format, Grid layouts
- **System share sheet** integration

### 6. Photo Capture During Walk 📷
- **Take photos** during your walk using camera
- **Photo library** access to choose existing photos
- **Location tagging** - photos remember where they were taken
- **Add notes/captions** to photos
- **View photo gallery** for each route
- **Delete photos** when no longer needed

### 7. Photo Collage Creation 🎨
- **Create collages** at the end of your route
- **Multiple templates**:
  - 2x2 Grid - Classic square layout
  - 3x3 Grid - More photos
  - Film Strip - Cinematic layout
  - Story Format - Instagram Stories ready (9:16)
  - Polaroid - Vintage style
- **Combine map + photos** in collages
- **Share collages** directly to social media
- **Save to photo library** for later use

### 8. Route Categories
- Quick city highlights (30min)
- Historic neighborhoods (1hr)
- Nature/parks (variable)
- Food & drink stops
- Photo opportunities

### 9. Smart Features
- **Debounced route generation**: Rapid slider changes don't spam the server
- **Cancellation support**: Cancel in-flight requests when user changes input
- **Caching**: 30-second cache for same location/time combinations
- **Offline fallback**: Shows last successful routes if Directions unavailable
- **Demo mode**: Amsterdam Centraal fallback when location unavailable

## Technical Stack
- **Framework:** SwiftUI
- **Maps:** MapKit (Apple Maps)
- **Location:** CoreLocation
- **Web:** SFSafariViewController (in-app browsing)
- **Analytics:** Console logging (ready for Firebase/Mixpanel)
- **Storage:** UserDefaults for favorites and feedback, Documents directory for photos
- **Sharing:** UIActivityViewController, UIGraphicsImageRenderer
- **Camera:** UIImagePickerController, AVFoundation

## Project Structure
```
WalkingRoutes/
├── WalkingRoutes/
│   ├── App/
│   │   └── WalkingRoutesApp.swift
│   ├── Views/
│   │   ├── ContentView.swift           # Main route discovery
│   │   ├── TimeSelectorView.swift      # Time selection slider
│   │   ├── FeedbackView.swift          # User feedback form
│   │   ├── CaptureViews.swift          # Screenshot automation
│   │   ├── Share/
│   │   │   └── ShareSheetView.swift    # Social sharing UI
│   │   ├── Camera/
│   │   │   └── PhotoCaptureView.swift  # Photo capture & gallery
│   │   ├── Collage/
│   │   │   └── CollageEditorView.swift # Collage creation
│   │   ├── LandmarkDetailView.swift    # Rich landmark details
│   │   ├── LandmarkCard.swift          # Landmark list cards
│   │   ├── LandmarkListView.swift      # Filterable landmark list
│   │   ├── RouteDetailView.swift       # Route with landmarks + actions
│   │   ├── RouteCard.swift             # Route list card
│   │   └── NavigationView.swift        # Turn-by-turn navigation
│   ├── Models/
│   │   ├── Route.swift                 # Route + Landmark models
│   │   ├── RoutePhoto.swift            # Photo model with location
│   │   ├── CollageTemplate.swift       # Collage layout templates
│   │   └── DemoRoute.swift             # Preview data
│   ├── ViewModels/
│   │   └── RouteViewModel.swift        # Route generation logic
│   ├── Services/
│   │   ├── PointsOfInterest.swift      # 20+ enriched Amsterdam landmarks
│   │   ├── RouteGenerationService.swift # MKDirections wrapper
│   │   ├── ShareService.swift          # Social sharing logic
│   │   ├── PhotoService.swift          # Photo storage management
│   │   └── CollageGenerator.swift      # Collage generation engine
│   └── Utilities/
│       └── RouteSnapshotGenerator.swift # Map snapshot generation
└── WalkingRoutes.xcodeproj
```

## Social Sharing Features

### Share Sheet
Access from any route detail view:
1. Tap **Share** button
2. Choose template (Story, Grid, etc.)
3. Preview your share image
4. Share to Instagram, Stories, or use system share sheet

### Instagram Stories
- Optimized 9:16 aspect ratio
- Route map visualization
- Distance, time, and rating stats
- Photo thumbnails from your walk
- Professional gradient backgrounds

### Deep Links
- Every shared route includes a deep link
- Recipients can tap to open the route directly in the app
- Falls back to App Store if app not installed

## Photo Features

### During Your Walk
1. Tap **Photos** button in route detail
2. Take photos with camera or choose from library
3. Add optional notes/captions
4. Photos are tagged with location

### Photo Gallery
- Grid view of all route photos
- Tap to view full size with metadata
- See when and where each photo was taken
- Delete photos you don't want to keep

### Creating Collages
1. Tap **Collage** button in route detail
2. Select template (Grid, Film Strip, Story, Polaroid)
3. Choose which photos to include
4. Tap **Generate Collage**
5. Share or save your creation

## Amsterdam Landmarks Database

The app includes **20+ fully enriched landmarks** with real data:

### Museums
| Landmark | Website | Booking | Price |
|----------|---------|---------|-------|
| Rijksmuseum | rijksmuseum.nl | ✅ | €22.50 |
| Van Gogh Museum | vangoghmuseum.nl | ✅ | €22 |
| Anne Frank House | annefrank.org | ✅ | €16 |
| Stedelijk Museum | stedelijk.nl | ✅ | €22.50 |
| Heineken Experience | heinekenexperience.com | ✅ | €23 |

### Historic Sites
- **Westerkerk** - Amsterdam's largest Protestant church (tower tours)
- **Royal Palace** - Former city hall on Dam Square
- **Begijnhof** - Hidden medieval courtyard

### Parks & Outdoor
- **Vondelpark** - Amsterdam's most famous park (free)
- **Hortus Botanicus** - Historic botanical garden

### Canal Cruises
- **Stromma** - Classic canal cruises (€16-18)
- **Lovers** - Popular operator with multiple routes

### Dining & Shopping
- **Foodhallen** - Indoor street food market
- **Albert Cuyp Market** - Famous street market
- **De Negen Straatjes** - Boutique shopping district

### Hidden Gems
- **NDSM Wharf** - Hip cultural hotspot (free ferry)

### Utrecht Landmarks
- **Dom Tower** - Tallest church tower in NL (€13)
- **Oudegracht** - Unique wharf-level canals (free)
- **Centraal Museum** - Art and design (€15)

All landmarks include:
- ✅ Verified working URLs
- ✅ Current opening hours
- ✅ Accurate admission fees (2024)
- ✅ Phone numbers
- ✅ Accessibility information
- ✅ Category tags

## Build Automation
- Automated builds via script (`build-and-capture.sh`)
- Screenshots captured after each milestone
- Videos recorded for demo walks

## Future Enhancements
- [x] Social sharing
- [x] Photo capture during walks
- [x] Photo collage creation
- [ ] Integration with Foursquare/Google Places API
- [ ] User-generated routes
- [ ] Offline maps
- [ ] Audio guided tours
- [ ] TripAdvisor integration
- [ ] Real-time crowd levels
- [ ] Weather-based recommendations
- [ ] Saved favorites
- [ ] Route history

## Requirements
- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+
- Camera access (for photo capture)
- Photo library access (for choosing photos)

## Permissions
The app requests the following permissions:
- **Location**: For route generation and tracking your walk
- **Camera**: For taking photos during walks
- **Photo Library**: For saving collages and choosing existing photos

## License
Private project - All rights reserved.
