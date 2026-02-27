# Pedro's Payments CRM

Simple, fast, and designed for your referral business.

## Quick Start

### Add a Partner
Create a new file in `partners/` using the template below. Name it `partner-name.md`.

### Add a Deal
Create a new file in `deals/` using the deal template. Name it `client-name.md`.

### Daily Check
Run `crm/today.md` to see what needs follow-up.

---

## Directory Structure

```
crm/
├── README.md          # This file
├── partners/          # All your PSPs/Acquirers
│   ├── partner-a.md
│   └── partner-b.md
├── deals/            # Active and past deals
│   ├── client-x.md
│   └── client-y.md
└── today.md          # Daily dashboard (auto-generated)
```

## Partner Template

```markdown
# [Partner Name]

**Type:** PSP / Acquirer / Orchestrator  
**Status:** Active / On Hold / Dormant  
**Contact:** [Name, Telegram handle, email]  

## Capabilities

**Countries:**
- [List ISO codes or regions]

**Payment Methods:**
- [Cards, APMs, crypto, etc.]

**Industries Accepted:**
- [Gambling, crypto, FX, adult, etc.]

**Front Shop Policy:**
- [Accepts / Does not accept front shops]

**Settlement:**
- **Currencies:** [EUR, USD, USDT, etc.]
- **Timeframe:** [T+1, T+3, etc.]
- **Rolling Reserve:** [%, duration]

**Pricing:**
- **Buy Rate:** [%]
- **Revenue Share:** [%]

## Notes
- [Special conditions, limitations, strengths]

## History
- YYYY-MM-DD: [First contact / deal closed / issue]
```

## Deal Template

```markdown
# [Client/Deal Name]

**Industry:** [Gambling / Crypto / FX / Adult]  
**Status:** [Lead / In Discussion / Proposal Sent / Contracting / Live / Closed-Lost]  
**Monthly Volume:** €[X] (target)  
**Potential Monthly Revenue:** €[X]  
**Priority:** [High / Medium / Low]  

## Contacts
- **Client:** [Name, Telegram, email]
- **Partner(s):** [Links to partner files]

## Requirements
- **Countries:** [Target geos]
- **Payment Methods:** [Specific needs]
- **Settlement:** [Fiat/crypto preference]

## Timeline
- YYYY-MM-DD: [First contact]
- YYYY-MM-DD: [Next action needed]

## Notes
- [Blockers, opportunities, context]

## Next Action
- [ ] [Specific task with owner and date]
```

## Status Definitions

**Deal Status:**
- **Lead:** Initial contact, need discovery
- **In Discussion:** Active dialogue, qualifying
- **Proposal Sent:** Pricing shared, awaiting response
- **Contracting:** Legal/compliance phase
- **Live:** Processing live, revenue flowing
- **Closed-Lost:** Dead for now (note why)

**Partner Status:**
- **Active:** Currently sending deals
- **On Hold:** Temporary pause
- **Dormant:** Haven't worked with recently

## Tips

1. **Keep it lightweight** — Don't over-document. Capture what you need to remember.
2. **Update after every interaction** — 30 seconds now saves confusion later.
3. **Use `today.md`** — Check it every morning for follow-ups.
4. **Tag by urgency** — Use Priority flags to know where to focus.

---

*Created by Luna for Pedro*  
*Last updated: 2026-02-26*
