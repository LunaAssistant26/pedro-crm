# Walking Routes — Development Workflow

## Roles

| Role | Who |
|------|-----|
| **Product Owner** | Pedro |
| **Program Manager** | Luna (coordinates, decides scope, reports) |
| **Developer** | Claude Code subagent (implements, builds, commits) |
| **QA Engineer** | Claude Code subagent (code review, test checklist) |

---

## Standard Flow

```
Pedro → Luna (PM) → Dev Agent → QA Agent → Luna → Pedro
         ↑                                    |
         └────────────────────────────────────┘
                     (if QA finds issues)
```

### Step 1 — Pedro describes feature/bug
Pedro sends a message (can be rough — "the map doesn't work" is fine).

### Step 2 — Luna (PM) breaks it down
- Identify affected files
- Define the specific change needed
- Spawn Dev Agent with a precise task

### Step 3 — Developer Agent
- Implements the change
- Runs `xcodebuild` to confirm it compiles
- Commits and pushes to `LunaAssistant26/pedro-crm`
- Notifies Luna when done

### Step 4 — QA Agent
- Reads all changed files
- Reviews for: bugs, edge cases, crashes, race conditions, missing error handling
- Writes a manual test checklist (exact tap paths)
- Reports back to Luna

### Step 5 — Luna reports to Pedro
- Summary of what was built
- Any QA findings (critical / minor / suggestions)
- Test checklist: what to tap through on device
- Estimated test time

---

## QA Severity Levels

| Level | Meaning | Action |
|-------|---------|--------|
| 🔴 Critical | Crash / data loss / broken core flow | Block release, fix first |
| 🟡 Minor | Wrong behaviour, bad UX | Fix before TestFlight |
| 💡 Suggestion | Improvement idea | Log for later |

---

## Project Context (for agents)

- **Project:** `projects/walking-routes`
- **Build command:** `xcodebuild -scheme WalkingRoutes -destination 'id=9D3798DD-AA1A-4C03-9686-B3350A722CFF' build`
- **Repo:** `LunaAssistant26/pedro-crm` (main branch)
- **Language:** Swift / SwiftUI / MapKit
- **Target iOS:** 16.0+
- **Key constraints:** No MKDirections > 50 req/60s; no `locationManager.stopUpdating()` in NavView; Config.swift is gitignored (contains Google API key)
