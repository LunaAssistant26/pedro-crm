# Mission Control

Pedro's command center dashboard - a modern, sleek interface for managing CRM, team, memory, calendar, and research.

## Features

- **CRM**: Track deals, clients, and payment partners
- **Memory**: Searchable interface for Luna's memory files
- **Team**: View team members with AI model assignments
- **Calendar**: Weekly schedule for cron jobs and team activities
- **Ideas**: Business idea pipeline with Researcher integration

## Quick Start

```bash
# Install dependencies
npm install

# Build research index (after Researcher adds files)
npm run research:index

# Run development server
npm run dev
```

The app will open at `http://localhost:5173`

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
