# Walking Routes App - Sprint 3: Monetization & Launch Prep

**Sprint Dates:** March 3-17, 2026 (2 weeks)
**Goal:** Implement paywall, offline maps, prepare for TestFlight
**Workflow:** Hybrid (Kimi primary, OpenAI for escalations)

---

## 📋 Sprint Backlog

### **Week 1: Core Monetization (March 3-10)**

#### Task 1.1: Freemium Paywall UI [KIMI]
**Model:** Kimi K2.5
**Est. Cost:** $0.15
**Time:** 2-3 hours

**Requirements:**
- Create PaywallView with subscription tiers
- Monthly: €8.99 / Annual: €44.99 (40% discount)
- Free tier limits: 1-2 routes per city
- Premium benefits: unlimited routes, offline access, smart recommendations
- Trigger paywall after first route completion

**Success Criteria:**
- [ ] Paywall displays correctly on all route detail screens
- [ ] Pricing matches strategy doc
- [ ] Benefits clearly communicated
- [ ] Close/dismiss button works

---

#### Task 1.2: StoreKit Integration [KIMI]
**Model:** Kimi K2.5
**Est. Cost:** $0.25
**Time:** 3-4 hours

**Requirements:**
- Implement StoreKit 2 for subscriptions
- Configure products in App Store Connect
- Handle purchase flow (begin, complete, restore)
- Store subscription status in UserDefaults/Keychain

**Success Criteria:**
- [ ] Products load from App Store
- [ ] Purchase flow works end-to-end
- [ ] Subscription state persists across app launches
- [ ] Restore purchases works

---

#### Task 1.3: Offline Maps Architecture [ESCALATE → OPENAI]
**Model:** Start with Kimi, escalate if stuck
**Est. Cost:** Kimi $0.20 + OpenAI $0.75
**Time:** 4-6 hours

**Complexity:** High - requires architectural decision on:
- Map tile caching strategy
- Route data offline storage
- Memory management for large maps
- Sync when back online

**Approach:**
1. [KIMI] Attempt implementation with MKTileOverlay
2. [KIMI] Try alternative approach if first fails
3. [ESCALATE] If still stuck, OpenAI designs architecture
4. [KIMI] Implement OpenAI's solution

**Success Criteria:**
- [ ] Routes work without internet
- [ ] Map tiles cached efficiently
- [ ] No memory crashes
- [ ] Smooth offline/online transition

---

### **Week 2: Polish & TestFlight (March 10-17)**

#### Task 2.1: Route Completion Analytics [KIMI]
**Model:** Kimi K2.5
**Est. Cost:** $0.15
**Time:** 2-3 hours

**Requirements:**
- Track: route start, completion, paywall view, trial start, conversion
- Use lightweight analytics (Firebase or custom)
- Respect user privacy (GDPR compliant)

**Success Criteria:**
- [ ] Events fire correctly
- [ ] Funnel metrics visible
- [ ] No PII collected

---

#### Task 2.2: App Icons & Launch Screen [KIMI]
**Model:** Kimi K2.5
**Est. Cost:** $0.10
**Time:** 1-2 hours

**Requirements:**
- App icon for all iOS sizes
- Launch screen with logo
- Match orange accent color (#FF6B35)

---

#### Task 2.3: Pre-Launch Code Review [OPENAI]
**Model:** OpenAI GPT-5.2
**Est. Cost:** $1.50
**Time:** 1 hour (review) + fixes

**Scope:**
- Security review (StoreKit, user data)
- Performance check (memory leaks, efficiency)
- Architecture validation
- App Store compliance check

**Deliverable:**
- Review report with issues ranked by severity
- Kimi implements fixes

---

#### Task 2.4: TestFlight Build & Screenshots [KIMI]
**Model:** Kimi K2.5
**Est. Cost:** $0.20
**Time:** 2 hours

**Requirements:**
- Archive build for TestFlight
- Generate App Store screenshots (all sizes)
- Write App Store description
- Create privacy policy

---

## 🎯 Sprint Goals

### **Must Have (MVP for TestFlight)**
- [ ] Paywall with StoreKit integration
- [ ] Subscription state management
- [ ] Basic analytics
- [ ] App Store assets

### **Should Have (Nice to Have)**
- [ ] Offline maps working
- [ ] Route completion tracking
- [ ] App icon polish

### **Won't Have (Future Sprints)**
- City packs (fallback pricing model)
- Advanced analytics dashboard
- Social features

---

## 💰 Sprint Budget

| Task | Model | Est. Cost |
|------|-------|-----------|
| Paywall UI | Kimi | $0.15 |
| StoreKit | Kimi | $0.25 |
| Offline Maps | Kimi + OpenAI | $0.95 |
| Analytics | Kimi | $0.15 |
| App Icons | Kimi | $0.10 |
| Code Review | OpenAI | $1.50 |
| TestFlight | Kimi | $0.20 |
| **Total** | **Mixed** | **~$3.30** |

*vs. OpenAI-only: ~$12-15*

---

## 🚨 Escalation Plan

**If Kimi gets stuck on:**
1. StoreKit edge cases → Check Apple docs, try again
2. Offline maps → **ESCALATE to OpenAI** (architectural)
3. Paywall flow bugs → Debug with logs, try again
4. Analytics complexity → Simplify, use Firebase

**OpenAI escalation format:**
```
Context: [What we're building]
Problem: [What Kimi couldn't solve]
Attempts: [What we tried]
Goal: [What we need]
Constraints: [Budget, time, tech limits]
```

---

## 📊 Success Metrics

**By March 17:**
- [ ] TestFlight build submitted
- [ ] Paywall conversion rate baseline
- [ ] >95% crash-free sessions
- [ ] All 5 Amsterdam routes working offline

**Post-Launch (Week of March 17):**
- [ ] 10 beta testers invited
- [ ] >50% route completion rate
- [ ] >5% trial start rate

---

## 🔄 Model Usage Tracking

**Sprint 3 Goals:**
- Kimi tasks: 5-6 (80%)
- OpenAI tasks: 1 (20%)
- Cost savings target: 75% vs OpenAI-only

**Actuals (to be filled):**
| Task | Model Used | Actual Cost | Success? |
|------|------------|-------------|----------|
| | | | |

---

## 📝 Post-Sprint Review Template

**What worked well:**
- 

**What should be OpenAI vs Kimi:**
- 

**Cost breakdown:**
- Kimi: $____
- OpenAI: $____
- Total: $____

**Process improvements:**
- 

---

_Sprint planned: 2026-03-03_
_Next sprint planning: 2026-03-17_
