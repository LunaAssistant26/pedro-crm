// Auto-synced memory snapshots for Mission Control UI.
// IMPORTANT: Mission Control is a static Vite app; it cannot read arbitrary files from disk.
// When Luna writes daily memory logs, also update this file so the UI stays current.

export const longTermMemory = {
  id: 'memory-md',
  name: 'MEMORY.md',
  type: 'long-term',
  description: 'Long-term curated memory',
  date: 'rolling',
  content: `# MEMORY.md - Luna's Long-Term Memory

## About Pedro
- **Name:** Pedro
- **Location:** Amsterdam (GMT+1)
- **Business:** Independent payments referral + building Tara app
- **Communication style:** Short bullet points, casual tone

## Current Projects

### 1. Payments Referral Business
- Matchmaking high-risk merchants (gambling, crypto, CFD/FX, adult) with payment partners
- Revenue: €2K-€10K/month per deal
- Pain point: No CRM system - relies on memory
- 90-day goal: Close 2+ deals

### 2. Tara App
- Financial OS for recurring session-based solo professionals
- Target: Personal trainers, coaches, tutors
- Status: Pre-MVP, Figma prototype
- 90-day goal: Launch sign-up page, get test client by June

### 3. Financial Advisor Agent (NEW - March 1, 2026)
- Daily investment recommendations for €10,000 long-term portfolio
- Platform: Trade Republic
- Schedule: Monday-Friday, 9:00 AM CET
- Sample portfolio: 40% VUSA, 30% EUNA, 20% NVIDIA, 10% Bitcoin
- Reports: \`/research/financial-advisor/YYYY-MM-DD-report.md\`
- Mission Control: New "Financial" tab for portfolio overview

## Technical Setup

### OpenClaw Configuration
- **Channels:** Discord (working), Telegram (broken on macOS)
- **Model:** Kimi for Coding (k2p5) primary, Kimi K2.5 fallback
- **Memory:** Local embeddings enabled
- **Browser:** Chrome configured

### Known Issues

#### Telegram Bug (2026-02-27)
- **Error:** \`ENOENT: no such file or directory, mkdir '/home/node'\`
- **Cause:** Plugin hardcodes Linux path \`/home/node\` - incompatible with macOS
- **Status:** Bug report drafted, needs submission to GitHub
- **Workarounds tried:** Manual mkdir (failed), symlink (SIP blocked), env var override (failed)
- **Solution:** Wait for upstream fix or use Discord instead

## Preferences
- Uses Discord for OpenClaw (reliable)
- Wants proactive suggestions for reaching goals
- Needs help with: research, business thinking, follow-ups, deal tracking

## Recent Actions

### March 1, 2026
- Set up Financial Advisor Agent with daily cron job (Mon-Fri 9am)
- Configured sample €10,000 portfolio (ETFs + stocks + crypto)
- Created Mission Control "Financial" tab for portfolio tracking
- Generated first sample investment report

### February 27, 2026
- Set up Discord integration for mobile access
- Configured browser automation
- Enabled local memory embeddings
- Disabled Telegram due to macOS bug
- Drafted bug report for OpenClaw Telegram plugin
`
}

export const dailyLogs = [
  {
    id: 'daily-2026-03-03',
    name: '2026-03-03.md',
    type: 'daily',
    description: "Today's activities",
    date: '2026-03-03',
    content: `# March 3, 2026 — Daily Log

## 🚀 Major Process Implementation: Hybrid AI Workflow

### Implemented Today
1. **WORKFLOW_AUTO.md** - Formalized hybrid AI development process
   - Kimi K2.5 as primary (80% of tasks)
   - OpenAI GPT-5.2 for escalations (20% of tasks)
   - Clear escalation criteria and cost optimization rules
   - Project-specific guidelines for iOS/backend/web

2. **Walking Routes Sprint 3** - First sprint using new workflow
   - Sprint file: \`sprint-3-monetization.md\`
   - Goal: Paywall, offline maps, TestFlight prep
   - Budget: ~$3.30 (vs $12-15 OpenAI-only)
   - Timeline: March 3-17, 2026

3. **Mission Control Updates**
   - Apps tab now shows AI Workflow section
   - Walking Routes updated to Sprint 3 status
   - Progress tracking for hybrid model usage

### Research Completed

#### Sweepstakes Market Research
- **Verdict:** Crypto-only sweepstakes casino = HIGH RISK (3/10 viability)
- **Market:** $10.6B growing 60-70% annually
- **Problem:** Regulatory crackdown accelerating, crypto-only = red flag
- **Pedro fit:** 5/10 - payments expertise helps but gaps in tech/gaming

**Recommended alternatives:**
1. Safe Bet: Sweepstakes Infrastructure-as-a-Service (B2B)
2. Stick with current focus: Tara + payments referral

### Model Comparison Research

| Model | Input | Output | Best For |
|-------|-------|--------|----------|
| **Kimi K2.5** | $0.60/M | $2.50/M | Standard coding, UI, 80% of tasks |
| **OpenAI GPT-5.2** | $1.75/M | $14.00/M | Complex architecture, escalations |

**Savings:** ~80% by using Kimi as primary

### Financial Advisor Report
**€10K Portfolio Recommendation:**
- 60% IWDA (MSCI World ETF) - €6,000
- 25% NVIDIA - €2,500  
- 15% Bitcoin - €1,500

### Active Work

#### Walking Routes App
- Phase 3 polish: ✅ Complete (screenshots captured)
- Developer subagent finished visual assets
- Sprint 3 started with new hybrid workflow
- Next: Paywall implementation with Kimi

### Files Created/Updated
- \`/workspace/WORKFLOW_AUTO.md\` - New process document
- \`/workspace/projects/walking-routes/sprints/sprint-3-monetization.md\` - Sprint plan
- \`/workspace/mission-control/src/components/Apps.jsx\` - Updated with AI workflow section
- \`/workspace/research/business-ideas/2026-03-03-sweepstakes-crypto-research.md\` - Research report

### Cost Tracking
**Today's AI Usage:**
- Researcher (sweepstakes): ~$1.50 (Kimi)
- Developer (screenshots): ~$0.30 (Kimi)
- Model comparison research: ~$0.20 (Kimi)
- **Total:** ~$2.00

## 🎨 Mission Control Redesign

### Major UI Updates
1. **Left Sidebar Navigation** - Moved tabs from top header to collapsible left sidebar
2. **Mission Statement** - Updated to Pedro's preferred version:
   > "A self-operating AI organization that turns my ideas into revenue — so I have less mental load and more time for what matters."
3. **New Documents Tab** - Centralized document repository with:
   - Full-text search across all docs
   - Category filtering (Business Research, Financial, Process, etc.)
   - Tag-based filtering with #hashtags
   - Document status tracking (Complete, In Progress)
   - Direct file opening from browser

### Document Categories
- Business Research
- App Strategy
- App Development
- Financial
- Process
- Research
- Organization

### Files Created/Updated (Additional)
- \`/workspace/MISSION.md\` - Organization mission statement
- \`/workspace/mission-control/src/components/Docs.jsx\` - New documents component
- \`/workspace/mission-control/src/data/documents.js\` - Document database
- \`/workspace/mission-control/src/App.jsx\` - Complete UI redesign with sidebar

---

_Implementing systematic hybrid AI workflow for all future development. Mission Control now reflects our autonomous organization vision._
`
  }
]

export const memoryFiles = [
  longTermMemory,
  ...dailyLogs
]
