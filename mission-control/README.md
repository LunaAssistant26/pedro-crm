# Mission Control

Pedro's command center dashboard - a modern, sleek interface for managing CRM, team, memory, calendar, and research.

## Features

- **CRM**: Track deals, clients, and payment partners
- **Financial**: Live portfolio tracking with AI-powered investment recommendations
- **Memory**: Searchable interface for Luna's memory files
- **Team**: View team members with AI model assignments
- **Calendar**: Weekly schedule for cron jobs and team activities
- **Ideas**: Business idea pipeline with Researcher integration

## Quick Start

```bash
# Install dependencies
npm install

# Setup Financial Advisor APIs (optional but recommended)
./setup-financial-apis.sh

# Build research index (after Researcher adds files)
npm run research:index

# Run development server
npm run dev
```

The app will open at `http://localhost:5173`

## Financial Advisor Setup

The Financial tab provides live stock, ETF, and crypto prices with portfolio tracking.

### API Setup (Free tiers available)

```bash
# Run the interactive setup script
./setup-financial-apis.sh
```

Or manually create `.env.financial`:

```bash
VITE_ALPHA_VANTAGE_KEY=your_key_here    # https://www.alphavantage.co/support/#api-key
VITE_NEWS_API_KEY=your_key_here          # https://newsapi.org/register
VITE_COINGECKO_KEY=your_key_here         # Optional
```

### Financial Data Sources

| API | Data | Free Tier |
|-----|------|-----------|
| Alpha Vantage | Stocks, ETFs | 5/min, 500/day |
| CoinGecko | Crypto prices | Generous limits |
| NewsAPI | Financial news | 100/day |

### Portfolio Configuration

Edit `src/components/Financial.jsx` to customize:
- Portfolio allocation
- Assets to track
- Refresh intervals

## Research Workflow

The Researcher agent writes business ideas to `../../research/business-ideas/`:

```markdown
---
title: "Business Idea Name"
date: "2026-03-02"
stage: "submitted"
tags: ["SaaS", "AI", "B2B"]
estimatedMarket: "€50K-200K/month"
effort: "Medium"
submittedBy: "Researcher"
---

## Problem
...

## Solution
...
```

To update Mission Control with new research:
```bash
npm run research:index
```

This scans the research folder and regenerates `src/data/researchIndex.json`.

## Build for Production

```bash
npm run build  # Automatically runs research:index before vite build
```

## Data

- **CRM data**: `src/data/crmData.js`
- **Research**: `../../research/` (markdown files)
- **Research index**: `src/data/researchIndex.json` (auto-generated)
- **Calendar**: Component state (will sync to files)
- **Memory**: Linked to `../../memory/` folder

## Tech Stack

- React + Vite
- Tailwind CSS
- Lucide Icons
- date-fns

---

Built for Pedro by Luna 🌙
