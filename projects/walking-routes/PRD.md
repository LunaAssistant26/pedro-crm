# Walking Routes - Product Requirements Document (PRD)
**Version:** 1.0
**Date:** March 2, 2026
**Status:** Draft - Pending Approval
**Product Manager:** Luna AI

---

## 🎯 **Executive Summary**

**Product Name:** Walking Routes  
**Tagline:** "Discover the perfect walk, wherever you are"  
**Platform:** iOS (iPhone)  
**Target Audience:** Travelers, tourists, urban explorers

**Core Value Proposition:**  
When travelers have 30-120 minutes of free time in an unfamiliar city, they want to explore on foot but don't know where to go or what they'll see. Walking Routes solves this by providing curated, time-based walking routes with interesting landmarks and points of interest.

---

## 📱 **Product Goals**

### Primary Goals
1. **Route Discovery:** Help users find walks matching their available time
2. **Local Exploration:** Surface interesting landmarks they wouldn't find otherwise
3. **Easy Navigation:** Simple turn-by-turn walking directions
4. **Trust & Quality:** Curated routes with reliable information

### Success Metrics
- User selects a route within 30 seconds of opening app
- 70%+ route completion rate
- 4.5+ star App Store rating
- Users discover 3+ new landmarks per walk

---

## 🗺️ **Technical Architecture**

### Map Solution: OpenMapTiles
**Why OpenMapTiles:**
- ✅ Open source, no API costs
- ✅ Customizable map styles
- ✅ Works offline (downloadable regions)
- ✅ Vector tiles = fast rendering
- ✅ Self-hostable for complete control

**Implementation:**
- Use MapLibre GL Native (iOS SDK) for rendering
- OpenMapTiles for base map data
- Custom POI layer for landmarks
- Offline map packs for popular cities

### Data Sources
| Data Type | Source | Notes |
|-----------|--------|-------|
| Base Maps | OpenMapTiles | Vector tiles, customizable |
| Routes | Self-generated | Walking paths using OSRM |
| POIs/Landmarks | OpenStreetMap + Foursquare | Mixed for quality |
| Photos | Wikimedia Commons | Free, attribution required |
| Descriptions | AI-generated + curated | Mixed approach |

---

## 🎨 **User Experience & Design**

### App Flow
```
Launch → Location Permission → Time Selection → Route List → Route Detail → Navigation → Complete
```

### Key Screens

#### 1. **Home Screen (Time Selection)**
**Purpose:** Quick route discovery

**Design:**
- Clean, minimal interface
- Large, tappable time buttons (15min, 30min, 45min, 1hr, 2hr)
- Current location display
- "Discover walks near you" header

**Interaction:**
- Tap time → See matching routes
- Swipe between time options
- Pull down to refresh location

#### 2. **Route List**
**Purpose:** Browse and select routes

**Design:**
- Card-based layout
- Each card shows: photo, name, duration, distance, difficulty
- Category tags (Highlights, Historic, Nature, Food)
- Sort by: relevance, duration, rating

**Card Elements:**
- Hero image (route preview)
- Route name (bold)
- One-line description
- Duration badge
- Distance
- Difficulty indicator (color-coded)
- Rating stars

#### 3. **Route Detail**
**Purpose:** Deep dive before committing

**Design:**
- Full-width hero image
- Map preview with route overlay
- Landmark timeline (scrollable)
- Start button (prominent, sticky bottom)

**Sections:**
- Overview stats (time, distance, difficulty, landmarks count)
- Interactive map (zoom, pan)
- Landmark list (with estimated time at each)
- Photos from route
- Reviews/ratings

#### 4. **Navigation Mode**
**Purpose:** Guide user during walk

**Design:**
- Full-screen map
- Current location (blue dot)
- Next landmark preview card (bottom)
- Distance to next stop
- Progress indicator (X of Y landmarks)
- Voice guidance option

**Navigation Features:**
- Turn-by-turn directions
- Audio cues for upcoming landmarks
- "You've arrived" notifications
- Option to skip landmark
- Emergency "end walk early" button

#### 5. **Walk Complete**
**Purpose:** Celebration and feedback

**Design:**
- Congratulations animation
- Stats: distance walked, time taken, landmarks visited
- Photos taken during walk (if camera used)
- Rate this route
- Share option (Instagram, etc.)
- "Find another walk" button

---

## 🎨 **Visual Design System**

### Color Palette
| Purpose | Color | Hex |
|---------|-------|-----|
| Primary | Deep Blue | #2563EB |
| Secondary | Teal | #14B8A6 |
| Success | Green | #22C55E |
| Warning | Orange | #F97316 |
| Danger | Red | #EF4444 |
| Background | Off-White | #F8FAFC |
| Card | White | #FFFFFF |
| Text Primary | Dark Gray | #1E293B |
| Text Secondary | Medium Gray | #64748B |

### Typography
- **Headlines:** SF Pro Display, Bold
- **Body:** SF Pro Text, Regular
- **Captions:** SF Pro Text, Medium, 85% opacity

### Icons
- SF Symbols (Apple's system icons)
- Custom: route path, landmark pin, walking person

### Map Style
- Light theme (day walks)
- Route line: Primary blue, 4pt width
- Landmark pins: Teal circles with white icons
- User location: Pulsing blue dot
- Completed path: Grayed out

---

## ⚙️ **Core Features (MVP)**

### Must-Have (v1.0)
1. ✅ Time-based route discovery
2. ✅ 10 curated routes per launch city
3. ✅ Route detail with landmarks
4. ✅ Interactive map with route overlay
5. ✅ Basic navigation mode
6. ✅ Offline support (downloaded maps)
7. ✅ Walk completion tracking

### Nice-to-Have (v1.1)
- [ ] User accounts & favorites
- [ ] Rate & review routes
- [ ] Share routes (deep links)
- [ ] Dark mode
- [ ] Voice guidance
- [ ] Photo spots highlighting

### Future (v2.0)
- [ ] User-generated routes
- [ ] Social features (walk with friends)
- [ ] Audio tours (guided walks)
- [ ] Integration with booking platforms
- [ ] Wearable support (Apple Watch)

---

## 🌍 **Launch Cities (MVP)**

**Phase 1:** Amsterdam (test market)  
**Phase 2:** Barcelona, Paris, London, Berlin  
**Phase 3:** Major tourist cities worldwide

**Criteria for city selection:**
- High tourist volume
- Walkable city center
- Rich landmarks/POIs
- Good OpenStreetMap coverage

---

## 🔐 **Permissions & Privacy**

### Required Permissions
| Permission | Purpose | When Asked |
|------------|---------|------------|
| Location (Always) | Track walk progress, find nearby routes | First launch |
| Notifications | Landmark arrival alerts | First navigation |
| Camera | Optional: photos during walk | When user taps camera |

### Privacy Considerations
- Location data never leaves device (except for map tiles)
- No user tracking or analytics without consent
- Route data cached locally
- Option to use app without account

---

## 📊 **Monetization Strategy**

### Free Tier
- 3 free routes per city
- Basic navigation
- Ads (optional)

### Premium ($4.99/month or $29.99/year)
- Unlimited routes
- Offline maps (all cities)
- Premium routes (curated by locals)
- No ads
- Priority support

### One-Time Purchases
- City packs ($2.99 each)
- Premium route bundles

---

## 🚀 **Development Phases**

### Phase 1: MVP (4-6 weeks)
- [ ] Project setup & OpenMapTiles integration
- [ ] Time selector UI
- [ ] Route list & detail screens
- [ ] 10 Amsterdam routes with real data
- [ ] Basic navigation mode
- [ ] Screenshot automation

### Phase 2: Polish (2-3 weeks)
- [ ] Offline map support
- [ ] Performance optimization
- [ ] UI animations
- [ ] Beta testing via TestFlight
- [ ] App Store assets

### Phase 3: Launch (1 week)
- [ ] App Store submission
- [ ] Marketing website
- [ ] Social media launch

---

## ✅ **Approval Checklist**

**For Pedro to review:**
- [ ] Core concept aligns with vision
- [ ] Feature set appropriate for MVP
- [ ] OpenMapTiles approach approved
- [ ] Design direction looks good
- [ ] Launch city (Amsterdam) approved
- [ ] Monetization strategy acceptable
- [ ] Timeline realistic

**Once approved, hand off to Developer for implementation.**

---

## 📝 **Notes for Developer**

**Key Technical Decisions:**
1. Use **MapLibre GL Native** for iOS (not Mapbox - licensing)
2. OpenMapTiles for vector tile source
3. SwiftUI for UI (modern, fast development)
4. CoreData or UserDefaults for offline cache
5. Background location updates for navigation

**Sample Data Provided:**
- 3 Amsterdam routes with landmarks
- Route structure and models
- UI mockups in code

**Open Questions:**
- Server needed for route data? (Start with bundled JSON)
- User accounts required? (Defer to v1.1)
- How to generate walking routes? (OSRM API or pre-calculate)

---

**Ready for Pedro's review! 🎯**
