# Walking Routes iOS — Launch, Global City Expansion, and App Store Pricing Strategy

## Executive Decisions (TL;DR)

1. **Primary monetization:** **Freemium + Subscription**  
   - Free: limited routes/city + core navigation trial value  
   - Paid: unlimited routes + offline + smart filters + audio snippets + saved collections
2. **Fallback monetization:** **City Packs (one-time purchases)** for low-subscription markets and price-sensitive users.
3. **Map stack for scale:** **Hybrid approach now, migrate toward OpenMapTiles + MapLibre as coverage scales.**  
   - **Phase 1 (0–3 months):** Keep Apple Maps for velocity and iOS-native reliability.  
   - **Phase 2 (3–9 months):** Introduce OpenMapTiles + MapLibre in selected cities to reduce variable costs, enable cross-platform consistency, and gain map-style/control flexibility.  
   - **Long term:** Own base map pipeline + fallback providers for resilience.
4. **Go-to-market country rollout:** 3 waves (high-intent travel markets first, then high-volume tourism markets, then long-tail global).
5. **North-star objective (90 days):** Prove repeatable **City Expansion Engine** with quality and unit economics, then scale from 5–10 pilot cities to 50+ cities.

---

## Product + Business Goal for Next 90 Days

**Goal:** Build a repeatable operating system that can ship high-quality walking routes in new cities every week while maintaining user trust and positive contribution margin.

**Success by day 90:**
- 25–50 launch-ready cities in catalog (with tiered quality labels)
- Conversion + retention thresholds hit in pilot markets
- Expansion pipeline producing 5–10 new cities/week with QA pass rate >90%

---

## Prioritized 30/60/90-Day Plan

| Time window | Priority | Outcomes | Owner |
|---|---|---|---|
| **Days 0–30** | Validate economics + route quality in 5 pilot cities | Pricing and paywall tested; baseline metrics established; City Expansion Engine v1 documented | PM + iOS + Ops |
| **Days 31–60** | Operationalize city production | 15–20 additional cities produced with QA pipeline; localization starter kit; partner content workflow | PM + Content Ops |
| **Days 61–90** | Scale + optimize monetization and rollout | 25–50 cities total live; wave-based App Store rollout; map stack A/B in selected cities; CAC/LTV confidence improves | PM + Growth + Data |

### Days 0–30: Execution checklist
- Select **5 pilot cities** (e.g., Amsterdam, Lisbon, Barcelona, London, Rome) balancing demand + ease.
- Create **route archetypes** (60-min classic, 90-min hidden gems, 120-min deep dive).
- Implement paywall experiments:
  - A: Freemium + Subscription
  - B: Freemium + Subscription + optional city pack upsell
- Instrument analytics funnel:
  - App install → city selected → route started → route completed → paywall viewed → trial started → paid conversion
- Define minimum route quality bar and QA scorecard.
- Produce first **City Playbook** (data sourcing, editorial standards, safety review).

### Days 31–60: Execution checklist
- Expand to 20–25 total cities using standardized templates.
- Launch **content production pipeline** with agent automation + human editor gate.
- Add **offline maps + route bundle download** to strengthen subscription value.
- Localize key app store assets + paywall copy for Wave 1 countries.
- Create weekly city performance dashboard (activation, completion, conversion by city).

### Days 61–90: Execution checklist
- Expand to 25–50 cities with demand-based prioritization.
- Roll out App Store countries in waves (see section below).
- Run price sensitivity tests by region (weekly/annual, intro pricing, PPP tiers).
- Pilot OpenMapTiles + MapLibre in 5–10 cities; compare:
  - tile cost/user
  - map render performance
  - route reliability
- Decide scale gate: continue acceleration only if metrics thresholds are achieved.

---

## City Expansion Engine (Operating System)

## 1) Data Pipeline (fast, scalable)

| Stage | Inputs | Automated by agents | Human review |
|---|---|---|---|
| **City selection** | Tourism volume, iOS install potential, CPC, language fit, safety baseline | Rank cities by score; generate priority list weekly | Approve final batch |
| **POI harvesting** | OSM/Wikidata/Google Places/public tourism datasets | Pull candidate landmarks, opening hours, categories, tags | Validate relevance and quality |
| **Route generation** | POIs + walkability graph + duration constraints | Generate 30/60/90/120-min route candidates with distance/elevation constraints | Pick best route variants |
| **Narrative content** | Landmark metadata + templates | Draft short descriptions, intros, transitions | Edit for accuracy, tone, legal-safe phrasing |
| **Safety + feasibility** | Pedestrian accessibility, known unsafe zones, night suitability | Flag risk segments automatically | Final safety approval required |
| **Publishing** | CMS schema + app config | Build city package JSON, screenshots, metadata | Release sign-off |

### City scoring model (example)

`City Score = (Demand 35%) + (Monetization Potential 25%) + (Data Quality 20%) + (Operational Ease 10%) + (Safety/Legal Simplicity 10%)`

- **Demand:** inbound tourism + “things to do” search volume
- **Monetization:** iOS spend index + subscription acceptance by region
- **Data quality:** POI density + map completeness
- **Operational ease:** language complexity + timezone overlap for support
- **Safety/legal:** walkability and lower legal ambiguity

## 2) QA Checklist (must-pass before launch)

| QA Area | Criteria | Pass threshold |
|---|---|---|
| Route logic | Route duration within ±15% of promise | 100% |
| Navigation integrity | No broken steps; no impossible crossings | 100% |
| Landmark quality | Facts are correct, concise, useful | ≥ 90% spot-check accuracy |
| Safety | No flagged high-risk segments without alternatives/disclaimer | 100% |
| Map quality | POIs pin correctly, no severe tile/render glitches | ≥ 99% route render success |
| UX quality | Route start under 10s, no critical crashes | Crash-free sessions ≥ 99.5% |
| Legal/compliance | Proper attribution, disclaimer language present | 100% |

## 3) Content Templates (speed + consistency)

### Route template
- **Title:** “Historic Core in 90 Minutes”
- **Audience:** first-time visitor / repeat traveler
- **Duration:** 30/60/90/120
- **Walking distance:** X km
- **Start/end points:** transit-friendly
- **Pacing options:** relaxed / standard / fast

### Landmark card template
- **Why this stop matters (1 sentence)**
- **What to look for (visual cue)**
- **Quick story (max 60 words)**
- **Practical tip (best time/photo angle/crowd note)**
- **Nearby add-on (optional detour)**

### Safety/disclaimer template
- Route suitability (day/night, stroller/wheelchair where known)
- Local caution note (traffic/pickpocket hotspots/crowded zones)
- Dynamic reminder: “Use local judgment and obey local rules.”

---

## Mapping Stack Recommendation: OpenMapTiles + MapLibre vs Apple Maps

## Recommendation

**Use a staged hybrid strategy:**
- **Now (speed): Apple Maps first** in MVP scale-up stage (lowest engineering friction on iOS, reliable turn-by-turn ecosystem).
- **Scale phase: Introduce OpenMapTiles + MapLibre** to reduce dependency and improve economics/control at larger city count and cross-platform ambition.

| Factor | Apple Maps | OpenMapTiles + MapLibre |
|---|---|---|
| iOS integration speed | Excellent | Moderate |
| Custom styling/control | Limited | Excellent |
| Cross-platform parity (future Android/web) | Weak | Strong |
| Vendor dependency risk | High | Lower (self/managed tile infra options) |
| Unit cost predictability at scale | Medium uncertainty | Better control if self-hosted/optimized |
| Offline customization | Limited flexibility | Strong flexibility |
| Engineering complexity | Lower | Higher initially |

### Why this is best for Pedro now
- Need execution speed immediately → Apple Maps supports fast shipping.
- Need global scalability and unit-control later → MapLibre stack provides better strategic control and lower lock-in.
- Hybrid rollout avoids big-bang migration risk.

---

## Unit Economics (Assumptions + 3 Scenarios)

## Key assumptions
- Monthly new installs depend on country wave and ASA/organic mix.
- Paid model: subscription with optional annual discount.
- Variable costs include maps/tiles, AI content generation, support, payment fees.

### Core assumptions table

| Variable | Conservative | Base | Aggressive |
|---|---:|---:|---:|
| Monthly new installs | 8,000 | 20,000 | 60,000 |
| Activation (start first route) | 35% | 45% | 55% |
| Trial start rate (of activated) | 6% | 10% | 15% |
| Paid conversion (trial→paid) | 35% | 45% | 55% |
| Effective monthly ARPPU | €7.99 | €8.49 | €9.49 |
| Month-3 paid retention | 55% | 65% | 75% |
| Blended CAC (paid channels) | €5.50 | €4.00 | €2.80 |
| Variable cost / active user / month | €0.70 | €0.50 | €0.35 |

### Scenario outputs (illustrative month-level)

| Metric | Conservative | Base | Aggressive |
|---|---:|---:|---:|
| Activated users | 2,800 | 9,000 | 33,000 |
| New paid users (month) | 59 | 405 | 2,723 |
| New MRR added | €471 | €3,439 | €25,837 |
| Gross margin on new MRR (after variable costs est.) | ~88% | ~91% | ~94% |
| Simple CAC payback (months) | 6–9 | 3–5 | 1–3 |

**Scale gate recommendation:** only accelerate city expansion marketing if **base-case or better** is observed for 4 consecutive weeks.

---

## Pricing Strategy (App Store)

## Options considered

| Model | Pros | Cons | Fit |
|---|---|---|---|
| Free only | Fast growth | Hard to sustain content quality | Poor |
| Freemium | Strong top-of-funnel + conversion potential | Requires sharp paywall design | Strong |
| Subscription only (hard paywall) | Predictable revenue | Friction too high for first-time travelers | Medium |
| City packs only | Simple one-off value | Lower LTV, fragmented ownership | Medium |

## Decision

### **Primary:** Freemium + Subscription
- Free tier: 1–2 routes/city + limited saves
- Paid (monthly + annual):
  - Unlimited routes in all cities
  - Offline route packs
  - “Nearby now” smart route recommendations
  - Premium curation (themed routes)

### **Fallback:** City packs (one-time)
- Use in markets with lower subscription adoption.
- Offer “City Pass” as upgrade path inside freemium for non-subscribers.

### Price architecture (starting point)
- Monthly: **€8.99**
- Annual: **€44.99–€59.99** (anchor with 40–55% effective discount)
- City pack: **€3.99–€6.99** per city (or bundles 3 cities for €9.99)

### Paywall UX principles
- Trigger after first route value moment, not on first app open.
- Show concrete outcomes: “Unlimited routes + offline access for your next trip.”
- Use destination-specific copy based on selected city.

---

## App Store Country Rollout (Wave 1/2/3)

## Wave strategy goals
- Start with high iOS spend + frequent city-break travelers + manageable localization.
- Expand to high tourism volume + mixed monetization behavior.
- Then global long-tail with localization automation.

| Wave | Countries | Rationale | Timing |
|---|---|---|---|
| **Wave 1** | NL, UK, IE, US, CA, AU, DE, FR, ES, IT, PT | Strong travel demand + high App Store monetization + western city-break behavior | Days 0–45 |
| **Wave 2** | Nordics, CH, AT, BE, SG, JP, KR, UAE | High purchasing power, urban tourism density | Days 46–75 |
| **Wave 3** | LATAM majors, CEE, selected SEA markets | Volume expansion, PPP-adjusted pricing needed | Days 76–120 |

### Localization priorities by wave
- Wave 1: EN + ES + FR + DE + IT + PT
- Wave 2: JA + KO + Arabic (store listing first, in-app phased)
- Wave 3: PT-BR + ES-LATAM + selected CEE languages as demand warrants

---

## TestFlight Validation Plan + Go/No-Go Thresholds

## Pilot setup
- Cohort size target: **1,000–2,000 TestFlight users** across 5 pilot cities
- Run duration: **3–4 weeks**
- Sources: travel communities, city expat groups, creator partnerships, existing network

## Metrics to track

| Funnel Stage | Metric | Threshold to proceed |
|---|---|---|
| Activation | Install → first route start | **≥ 40%** |
| Engagement | Route completion rate | **≥ 55%** |
| Value perception | NPS after first completed route | **≥ +25** |
| Monetization intent | Paywall CTR after route completion | **≥ 12%** |
| Conversion | Trial start rate (activated users) | **≥ 8%** |
| Conversion quality | Trial→paid | **≥ 40%** |
| Retention | D7 retained users | **≥ 20%** |
| Reliability | Crash-free sessions | **≥ 99.5%** |

## Scale criteria
Proceed to aggressive city rollout only if all are true for 2+ consecutive weeks:
1. Activation and completion thresholds met
2. Trial→paid ≥ 40%
3. No critical safety/legal incidents
4. Contribution margin remains positive in pilot cohort

---

## Key Risks + Mitigations

| Risk | Impact | Mitigation |
|---|---|---|
| Content quality inconsistency | User trust loss, poor reviews | Human editorial gate for top 20% traffic cities; automated linting for all content |
| Route safety incidents | Reputation/legal risk | Safety flags, avoid risk zones by default, clear disclaimers, user reporting loop |
| Legal/IP issues around map/content | Store rejection or claims | Attribution automation, legal checklist at publish, counsel review for templates |
| Map data quality gaps in some cities | Broken experience | Multi-source POI checks, city-level quality labels, fallback route variants |
| Localization errors | Conversion drop | Native reviewer for top markets; glossary + QA for machine-translated copy |
| Subscription resistance in some regions | Lower conversion | Fallback city packs + PPP testing + annual anchor pricing |

---

## Team Setup: What Agents Automate vs Human Review

| Function | Agent-automatable | Human-required |
|---|---|---|
| City demand research | Yes (data pull, scoring, ranking) | Final priority decisions |
| POI collection + dedupe | Yes | Spot-check relevance |
| Route generation draft | Yes | Final route acceptance for safety/usability |
| Landmark copy draft | Yes | Fact-check + editorial tone |
| QA pre-checks | Yes (linting, broken links, duration checks) | Final QA sign-off |
| App Store metadata drafts | Yes | Brand/legal review |
| Pricing experiment analysis | Yes (dashboard + recommendations) | Final pricing decisions |
| Incident triage | Yes (classify/cluster reports) | Safety escalation and policy actions |

### Lean team for next 90 days
- **1 PM/GM (Pedro)** — priorities, pricing, launch decisions
- **1 iOS engineer** — app instrumentation, paywall, map layer strategy
- **1 content ops lead/editor** — route quality and templates
- **1 growth generalist** — App Store optimization + acquisition experiments
- **Part-time legal reviewer** — disclaimers/attribution policy sanity checks
- **AI agents** — city research, drafting, QA preflight, localization first pass

---

## Immediate Next 10 Actions (This Week)

1. Lock pricing experiment design (A/B with clear success criteria).
2. Choose first 5 pilot cities with scoring model.
3. Finalize route/landmark/safety templates.
4. Implement full analytics funnel events in app.
5. Build city package schema and publishing checklist.
6. Set up weekly growth + quality KPI dashboard.
7. Recruit TestFlight users by city.
8. Ship paywall v1 tied to post-first-route moment.
9. Run first QA pass with explicit pass/fail score.
10. Schedule wave rollout decision meeting at day 30.

---

## Discord-ready Summary

```markdown
## Walking Routes — Launch Strategy (Fast Expansion + Pricing)

**Main decisions**
- **Primary model:** Freemium + Subscription
- **Fallback model:** City Packs (one-time)
- **Map strategy:** Apple Maps now for speed, migrate to hybrid with OpenMapTiles + MapLibre for scale/cost/control

**30/60/90 priorities**
- **30d:** Validate in 5 pilot cities, instrument funnel, test paywalls
- **60d:** Build city production engine, reach 20–25 cities, add offline value
- **90d:** Reach 25–50 cities, roll out countries in waves, scale only if thresholds hit

**City Expansion Engine**
- Pipeline: city scoring → POI harvesting → route generation → narrative drafts → safety checks → publish
- QA must-pass: route integrity, safety, map reliability, crash-free sessions, legal attribution
- Standard templates for route cards, landmark stories, and safety notes

**Pricing starter**
- Monthly: ~€8.99
- Annual: €44.99–€59.99
- City packs: €3.99–€6.99 (fallback by region)

**Unit economics (base case)**
- 20k installs/mo, 45% activation, 10% trial start, 45% trial→paid
- New MRR added: ~€3.4k/mo from new cohort
- CAC payback: ~3–5 months

**Country rollout waves**
- **Wave 1:** NL/UK/US/CA/AU + DE/FR/ES/IT/PT
- **Wave 2:** Nordics/CH/AT/BE/SG/JP/KR/UAE
- **Wave 3:** LATAM + CEE + selected SEA with PPP pricing

**Scale gates (must hit)**
- Activation ≥40%
- Route completion ≥55%
- Trial start ≥8%
- Trial→paid ≥40%
- D7 retention ≥20%
- Crash-free ≥99.5%

If metrics hold for 2+ weeks, accelerate city expansion and paid acquisition.
```
