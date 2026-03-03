# MEMORY.md - Luna's Long-Term Memory

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
- Reports: `/research/financial-advisor/YYYY-MM-DD-report.md`
- Mission Control: New "Financial" tab for portfolio overview

## Technical Setup

### OpenClaw Configuration
- **Channels:** Discord (working), Telegram (broken on macOS)
- **Model:** Kimi for Coding (k2p5) primary, Kimi K2.5 fallback
- **Memory:** Local embeddings enabled
- **Browser:** Chrome configured

### Known Issues

#### Telegram Bug (2026-02-27)
- **Error:** `ENOENT: no such file or directory, mkdir '/home/node'`
- **Cause:** Plugin hardcodes Linux path `/home/node` - incompatible with macOS
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
