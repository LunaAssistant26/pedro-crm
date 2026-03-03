---
title: "High-Risk Merchant Onboarding Hub"
date: "2026-03-02"
stage: "submitted"
tags: ["payments", "high-risk", "kyc", "onboarding", "b2b-saas"]
estimatedMarket: "€10K-€100K/month"
effort: "Medium-High"
submittedBy: "Researcher"
---

## Problem

High-risk merchants (gambling, crypto, CBD, adult, FX/CFD) face a brutal onboarding experience:

1. **Application rejection rate: 70-80%** — Most acquirers won't touch high-risk verticals
2. **Months-long approval process** — Due diligence, document chasing, compliance reviews
3. **Documentation chaos** — Each PSP requires different documents in different formats
4. **No visibility into status** — Merchants are left in the dark, chasing processors for updates
5. **One rejection = start over** — No ability to apply to multiple acquirers in parallel

For a high-risk merchant, getting payment processing is existential—without it, they can't operate. Yet the process is stuck in 2010: email threads, PDF forms, manual reviews.

## Solution

**Onboardly** — A multi-acquirer onboarding hub that helps high-risk merchants get approved faster by streamlining documentation, connecting to vetted acquirers, and managing the entire process.

### Core Features

1. **Smart Application Builder**
   - Dynamic questionnaire based on vertical (gambling vs. crypto vs. adult)
   - Auto-generates compliant business descriptions and risk disclosures
   - Document checklist tailored to each acquirer's requirements

2. **Universal Document Vault**
   - Upload once, use for multiple applications
   - Auto-formatting for different PSP requirements
   - Version control and expiration alerts (licenses, financials)

3. **Multi-Acquirer Submission**
   - Submit to 3-5 pre-vetted acquirers simultaneously
   - Match merchants to acquirers based on geo, volume, and risk profile
   - Automated follow-ups and status tracking

4. **Onboarding Command Center**
   - Real-time status dashboard for all pending applications
   - Automated reminders for missing documents
   - Direct messaging with acquirer underwriters
   - Approval probability scores based on historical data

5. **Compliance Guardrails**
   - Built-in KYC/AML checklist
   - Risk assessment tools (chargeback forecasting, fraud indicators)
   - Regulatory requirement tracking by jurisdiction

### MVP Scope
- Web-based merchant portal
- 3-5 pre-integrated acquirer partners
- Document vault with basic auto-formatting
- Status tracking dashboard
- Manual submission process (API integrations later)

## Market Validation

### TAM/SAM/SOM

| Segment | Market Size |
|---------|-------------|
| **TAM** | Global high-risk merchant acquiring: ~$45B market (gambling, crypto, adult, CBD, FX) |
| **SAM** | EU/UK high-risk merchants seeking new acquirers: ~50,000 businesses |
| **SOM** | Crypto exchanges, gambling operators, adult platforms in Pedro's network: ~500 merchants year 1 |

### Existing Demand Signals

1. **Approvely, PaymentCloud, Soar Payments** — These companies *exist* and are profitable, proving demand for high-risk payment solutions
2. **High rejection rates create desperation** — Merchants pay 2-5x standard rates just to get processing
3. **Pedro's referral business** — He's already matching merchants to PSPs manually; this productizes that service
4. **Chargebacks911, Justt** — Chargeback management is a solved problem; onboarding is the new bottleneck

### Target Customer Profile

- **Crypto exchanges** — Need fiat on/off ramps, constantly seeking acquirers
- **Gambling operators** — New markets require new acquirers; high churn due to compliance
- **Adult content platforms** — High chargeback rates make them unbankable for most
- **FX/CFD brokers** — Regulatory complexity requires specialized acquirers
- **CBD brands** — Legal ambiguity creates onboarding challenges

## Competitive Landscape

| Competitor | What They Do | Gap/Onboardly Differentiation |
|------------|--------------|-------------------------------|
| **Approvely** | Full-stack high-risk PSP | They're the acquirer; Onboardly is agnostic, works with multiple |
| **PaymentCloud** | High-risk merchant account provider | Single provider; Onboardly is multi-acquirer |
| **Soar Payments** | High-risk processor | US-focused; Onboardly is EU/UK focused initially |
| **Akurateco** | Payment orchestration gateway | Tech solution; Onboardly adds human-assisted onboarding |
| **Manual brokers (like Pedro)** | Manual matching | Onboardly productizes this with scale and transparency |

**Key Differentiation:** Onboardly is the only platform that helps merchants apply to *multiple* acquirers in parallel while providing transparency into the process. Others are either single providers (conflict of interest) or pure tech (no hand-holding).

## Business Model

### Pricing

**Success-based + SaaS hybrid:**

1. **Application Fee**: €500 per acquirer application (covers underwriting review, document prep)
2. **Success Fee**: 0.25% of monthly processing volume for 6 months after approval
3. **SaaS Tier**: €199/month for enterprise merchants with multiple entities

Alternative model (if regulatory constraints):
- **Freemium**: Basic document vault and checklist
- **Pro**: €299/month — multi-acquirer submissions, priority support
- **Enterprise**: Custom — dedicated onboarding manager

### Revenue Potential

| Metric | Value |
|--------|-------|
| Average merchant processing volume | €5M/month |
| Success fee (0.25% for 6 months) | €7,500 per approval |
| Application fee (3 attempts avg) | €1,500 |
| **Average revenue per merchant** | **€9,000** |

| Scenario | Merchants | Revenue |
|----------|-----------|---------|
| Conservative (Year 1) | 20 approvals | €180K |
| Target (Year 1) | 50 approvals | €450K |
| Stretch (Year 2) | 200 approvals | €1.8M |

### Unit Economics

- **CAC**: €2,000 (industry events, paid search, broker referrals)
- **LTV**: €9,000+ per merchant
- **LTV/CAC**: 4.5x+
- **Payback period**: 2-3 months

## Go-to-Market

### First 10 Customers

1. **Pedro's current pipeline** — He's already talking to high-risk merchants; offer Onboardly as a service
2. **Crypto conferences** — BTC Prague, ETHGlobal, crypto meetups
3. **Gambling events** — ICE London, SiGMA (Pedro already attends)
4. **Broker partnerships** — Pay Pedro's referral fees to other payment brokers
5. **Content marketing** — "How to get a gambling merchant account in 2025"

### Growth Channels

1. **Acquirer partnerships** — Acquirers refer declined merchants to Onboardly for a fee
2. **Broker network** — Payment brokers use Onboardly as their submission tool
3. **Vertical communities** — Crypto forums, gambling operator groups, adult industry associations
4. **SEO/content** — High-intent keywords: "high risk merchant account," "crypto payment processor"

## Next Steps

### Validation (Weeks 1-6)

1. **Acquirer partnership conversations** — Identify 3-5 acquirers willing to receive automated submissions
   - Target: Approvely, PaymentCloud EU, EU-based crypto-friendly banks
2. **Merchant interviews** — 10 high-risk merchants about their onboarding pain points
3. **Regulatory review** — Consult with payments lawyer on PSD2, MSB licensing implications
4. **Competitor analysis** — Mystery shop Approvely, PaymentCloud to understand their process

### MVP Build (Months 2-5)

1. **Document vault MVP** — Secure file storage, basic formatting
2. **Application builder** — Dynamic forms for 2 verticals (crypto, gambling)
3. **Acquirer integration** — Manual API or portal automation for 3 acquirers
4. **Dashboard** — Status tracking, notification system

### First Revenue (Month 5-8)

1. **Pilot with 5 merchants** — Pedro's warm leads, manual-heavy process
2. **Iterate on underwriting criteria** — Learn what each acquirer actually wants
3. **First automated approvals** — Prove the model works
4. **Scale marketing** — Industry events, paid acquisition

## Risks

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| **Regulatory/licensing requirements** | High | Critical | Consult lawyer early; may need MSB license or partner with licensed entity |
| **Acquirers won't integrate** | Medium | High | Start with manual submissions; prove value before API negotiations |
| **Low approval rates persist** | Medium | Medium | Focus on pre-vetting; only submit to acquirers with high match probability |
| **Chargeback liability** | Low | High | Don't touch funds; pure software/intro play |
| **Approvely clones the model** | Medium | Medium | Move fast; build acquirer relationships as moat |
| **Merchant fraud** | Medium | High | Strict KYC; reserve fund or insurance for liability protection |

## Why This Fits Pedro

1. **Existing network** — Direct relationships with both merchants and acquirers
2. **Domain credibility** — 7+ years in payments (Worldpay, Rapyd), knows underwriting criteria
3. **Revenue synergy** — Complements his referral business; can upsell Onboardly to merchants
4. **Market timing** — Crypto gambling booming, but banks still hesitant; demand is spiking
5. **Defensible moat** — Acquirer relationships and underwriting data become proprietary assets

## Strategic Considerations

### Option A: Stay Software-Only (Recommended)
- Be the "TurboTax for high-risk onboarding"
- No liability, high margins, scalable
- Revenue: SaaS + application fees

### Option B: Become a PayFac/Referral Partner
- Take on more risk, higher rewards
- Need significant capital and licensing
- Revenue: % of processing volume ongoing

**Recommendation:** Start with Option A. Prove the model, then potentially layer on Option B for approved merchants.

## Summary

The High-Risk Merchant Onboarding Hub addresses a critical, expensive pain point in a growing market. While regulatory complexity adds risk, the reward potential is significant—merchants are desperate for solutions and willing to pay premium prices. Pedro's unique position at the intersection of high-risk merchants and acquirers makes him ideally suited to execute this.

**Recommendation:** Proceed to acquirer partnership conversations immediately—without acquirer buy-in, this doesn't work. Validate that at least 3 acquirers are willing to receive automated submissions before building.
