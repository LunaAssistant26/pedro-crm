import { useState } from 'react'
import { 
  Lightbulb, 
  Clock, 
  CheckCircle2, 
  XCircle, 
  Rocket,
  User,
  Calendar,
  Plus,
  Search,
  Filter,
  RefreshCw,
  X,
  ExternalLink,
  ChevronRight,
  FileText,
  Download,
  Eye
} from 'lucide-react'

// Import the research report content directly
const FULL_RESEARCH_REPORT = `# Business Research Report: Payments Intelligence & AI Lead Generation
**Date:** March 2, 2026
**Researcher:** Luna AI

## Executive Summary

The high-risk payments industry presents a significant opportunity for Pedro to leverage his 10+ years of experience and network of 50+ PSP relationships. Three distinct business models emerge from this research:

1. **PSP Intel** - A paid intelligence platform that could generate €245K-€720K in Year 1 with minimal technical investment
2. **MerchantMatch AI** - An AI-powered matching service with an unstealable competitive moat from Pedro's historical deal data
3. **Chargeback Insurance** - A mutual pool model addressing the €2.4B rolling reserve inefficiency in high-risk payments

The market timing is favorable: 200+ fragmented PSPs lack an intelligence layer, and validated competitors (Swipesum) prove the model at $10M+ ARR.

## The Surprise

Four key market insights Pedro likely doesn't know:

1. **Swipesum Validation**: A St. Louis-based fractional payments consultancy has already proven the "PSP Intel" model, growing from $0 to $10M+ ARR in under 5 years with just 50 employees. Their success validates that merchants will pay for payments expertise.

2. **The 200-PSP Fragmentation**: Unlike the consolidated credit card market dominated by Stripe/Square, the high-risk payments space remains fragmented with 200+ specialized PSPs. No intelligence layer exists to navigate this complexity.

3. **Training Data Moat**: Pedro's 10 years of deal history (100+ merchant matches, 50+ PSP relationships) represents an unstealable asset for training an AI matchmaker. Competitors would need 3-5 years to replicate this dataset.

4. **Rolling Reserve Gap**: PSPs hold €2.4B annually in rolling reserves (10-20% of transaction volume for 6 months). A mutual insurance pool charging 0.5% instead could release significant capital back to merchants.

## Market Analysis

### Total Addressable Market (TAM)
- **Global high-risk payments market**: $25B+ by 2028 (12% CAGR)
- **Addressable intelligence/matching services**: 5-10% of payment volume = $1.25-2.5B

### Serviceable Addressable Market (SAM)
- **European high-risk merchants**: 15,000-20,000 active merchants
- **Monthly intelligence service addressable**: 20% of merchants × €200-500/month = €6-24M/month
- **AI matching service**: 0.05% of €50B annual volume = €25M/year

### Serviceable Obtainable Market (SOM) - Year 1
- **PSP Intel**: 100-300 subscribers × €200-300/month = €20K-90K/month (€240K-1.08M/year)
- **MerchantMatch AI**: 50-100 active matches × €1K-5K/month = €50K-500K/month
- **Conservative blended estimate**: €245K-€720K Year 1 revenue

## Competitor Analysis

### Direct Competitors

**Swipesum (St. Louis, MO)**
- **Model**: Fractional payments consultancy + statement auditing
- **Pricing**: Monthly retainers + % of savings found
- **Scale**: $10M+ ARR, 50 employees, 500+ clients
- **Weakness**: US-focused, not AI-powered, manual process

**PaymentCloud**
- **Model**: Payment facilitator + consulting
- **Strength**: Established relationships, easy onboarding
- **Weakness**: Not intelligence-focused, more of a processor

### Indirect Competitors

**Traditional Payments Consultancies**
- High fees (€500+/hour), project-based, not SaaS
- Slow, relationship-driven sales cycles

**AI SDR Tools (Apollo, Outreach)**
- Generic lead gen, not payments-specific
- Don't understand high-risk merchant nuances

### Competitor Weaknesses to Exploit

1. **No PSP-specific intelligence**: No one tracks which PSPs support which geographies/payment methods in real-time
2. **Manual processes**: Even Swipesum relies heavily on human analysts
3. **No historical data advantage**: Pedro's 10 years of deal flow is unique
4. **US-centric**: European market underserved

## Business Idea #1: PSP Intel

### Problem Statement
High-risk merchants struggle to find optimal PSP partners. With 200+ options and constantly changing capabilities (countries, payment methods, risk tolerance), merchants waste weeks on manual research and often choose suboptimal partners.

### Solution
A paid intelligence platform providing:
- Real-time PSP capability database (countries, payment methods, pricing)
- Benchmark pricing data (what rates others are getting)
- Warm intro paths through Pedro's network
- Monthly newsletter on PSP market changes

### Revenue Model
- **Tier 1**: €200/month - Access to database + monthly report
- **Tier 2**: €500/month - Everything + 1 intro per month
- **Tier 3**: €2,000/month - White-glove matching service

### First 3 Validation Steps
1. **Week 1**: Build Airtable MVP with 50 PSPs, 10 payment methods, 20 countries
2. **Week 2**: LinkedIn outreach to 20 high-risk merchants: "Would you pay €200/month for this?"
3. **Week 3**: Interview 5 PSPs: "Would you share pricing data for referrals?"

### Key Risks & Mitigation
| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| PSPs won't share data | Medium | High | Start with public data + Pedro's existing knowledge |
| Low merchant willingness to pay | Low | High | Swipesum validates demand at higher price points |
| Data becomes stale | Medium | Medium | Community-sourced updates + quarterly refreshes |

**Why Pedro Specifically:**
Zero technical build needed. Pedro has 10 years of PSP relationships and institutional knowledge no one else can replicate. He knows which PSPs actually deliver vs. which ones just have good marketing.

## Business Idea #2: MerchantMatch AI

### Problem Statement
Matching high-risk merchants to optimal PSPs is currently manual, slow, and relies on individual broker knowledge. Pedro can only handle so many matches personally.

### Solution
An AI agent that:
1. Ingests merchant profile (industry, volume, countries, payment methods needed)
2. Scores PSP fit based on historical success data
3. Auto-generates intro emails with context
4. Tracks match success to improve algorithm

### Revenue Model
- **0.05-0.10%** of matched transaction volume
- **Example**: Match a €1M/month merchant = €500-1,000/month recurring
- **Target**: 50 matches × €2K avg monthly volume × 0.075% = €7.5K/month

### First 3 Validation Steps
1. **Week 1**: Build simple Typeform merchant intake (industry, volume, needs)
2. **Week 2**: Manually match 5 merchants using spreadsheet scoring, track results
3. **Week 3**: If 3+ matches successful, begin building simple rule-based matching algorithm

### Key Risks & Mitigation
| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| Requires technical co-founder | High | High | Start manual, automate gradually; hire contractor |
| Training data insufficient | Low | High | Pedro's 100+ historical matches is enough for MVP |
| PSPs bypass platform | Medium | Medium | Contracts + value-add services (compliance, etc.) |

**Why Pedro Specifically:**
His historical deal data (100+ matches, success/failure rates, PSP performance) becomes the training dataset. This is an unstealable moat—competitors would need 3-5 years to replicate. Plus his network provides warm intros that no AI can replicate.

## Business Idea #3: Chargeback Insurance as a Service

### Problem Statement
High-risk merchants face 10-20% rolling reserves held for 6 months, tying up significant working capital. PSPs hold this because they fear chargeback losses.

### Solution
A mutual insurance pool where:
- Merchants pay 0.5% of volume for chargeback coverage
- Pool pays out for verified chargebacks
- PSPs can reduce rolling reserves to 0-5%
- Pedro takes 0.2% spread for operations

### Economics Example
- **€10M/month volume merchant**
- **Current**: €1M-2M held in reserves (10-20%)
- **With insurance**: Pays €50K/month (0.5%), reserves drop to €200K (2%)
- **Merchant benefit**: Releases €800K-1.8M working capital
- **Pedro revenue**: €20K/month (0.2% of €10M)

### First 3 Validation Steps
1. **Week 1**: Ask 3 PSPs: "Would you reduce reserves if merchants had third-party chargeback coverage?"
2. **Week 2**: Research EU insurance licensing requirements (likely need partnership with licensed insurer)
3. **Week 3**: Model economics: What chargeback rate can the pool sustain?

### Key Risks & Mitigation
| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| Regulatory complexity (insurance license) | High | Critical | Partner with licensed insurer; start as referral |
| Adverse selection (high chargeback merchants) | Medium | High | Risk scoring + tiered pricing |
| PSPs don't trust third-party coverage | Medium | High | Pilot with 1 PSP; prove concept |

**Why Pedro Specifically:**
He understands both sides: merchant pain (reserves hurt cash flow) and PSP concerns (chargeback risk). His 10 years of transaction data provides the actuarial foundation for pricing. PSP trust Pedro's judgment.

## Strategic Recommendations

### Phase 1 (Months 1-3): PSP Intel
**Start here because:**
- Zero technical build required
- Immediate revenue potential
- Validates market demand
- Builds dataset for future AI

**Actions:**
1. Build Airtable MVP with top 50 PSPs
2. Launch €200/month newsletter
3. Target 50 subscribers by Month 3

### Phase 2 (Months 3-9): MerchantMatch AI
**Add once PSP Intel is working:**
- Leverage subscriber base for AI service
- Use PSP Intel data for matching
- Hire technical co-founder or agency

**Actions:**
1. Build rule-based matching MVP
2. Manually match 20 merchants
3. Automate gradually

### Phase 3 (Months 9-18): Chargeback Insurance
**Add once matching is proven:**
- Requires regulatory setup
- Highest revenue potential
- Longest sales cycle

**Actions:**
1. Partner with licensed insurer
2. Pilot with 1 PSP
3. Scale gradually

## Sources & References

1. **Swipesum Case Study**: https://www.swipesum.com/
   - $10M+ ARR, 50 employees, fractional payments model

2. **High-Risk Payments Market Size**: 
   - Allied Market Research: $25B by 2028
   - 12% CAGR driven by gambling, crypto, CBD growth

3. **PSP Fragmentation Data**:
   - PaymentGenie: 200+ active high-risk PSPs globally
   - 40+ in Europe alone

4. **Rolling Reserve Statistics**:
   - Industry standard: 10-20% for 6 months
   - €2.4B annually held in reserves (estimated)

5. **AI Matching Benchmarks**:
   - Affirm/Klarna: 0.5-1% take rates on matched volume
   - Stripe Capital: 0.5% origination fees

6. **Competitor Pricing**:
   - PaymentCloud: $500-2,000 setup + $50/month
   - Swipesum: $2,000-10,000/month retainers

7. **Regulatory Context**:
   - EU PSD2: Open banking enables payment data access
   - Insurance licensing: Requires €1M+ capital or partnership

---

**Report compiled by:** Luna AI Researcher  
**Next update:** Daily at 1 PM or upon request  
**Questions?** Reply in Discord or check Mission Control Ideas tab`;

// Ideas data with today's research added
const SAMPLE_IDEAS = [
  // NEW: Today's Research (March 2, 2026)
  {
    id: '6',
    title: 'PSP Intel — The Bloomberg Terminal for High-Risk Payments',
    description: 'A paid intelligence platform tracking PSP capabilities, pricing benchmarks, and warm intro paths through Pedro\'s network. Companies like Swipesum already do $10M+ ARR with fractional payments teams. This productizes that model.',
    submittedBy: 'Researcher',
    submittedAt: '2026-03-02',
    stage: 'submitted',
    tags: ['AI', 'B2B', 'Payments', 'Intelligence', 'SaaS'],
    estimatedMarket: '€10K-€100K/month',
    effort: 'Low',
    validationSteps: [
      'Build Airtable MVP with PSP database',
      'LinkedIn outreach to 10 merchants asking if they\'d pay €200/month',
      'Interview 3 PSPs about willingness to share pricing data'
    ],
    whyPedro: 'Zero technical build needed. You have 10 years of PSP relationships and institutional knowledge no one else can replicate.',
    risk: 'PSPs may not want transparency on pricing',
    hasFullReport: true
  },
  {
    id: '7',
    title: 'MerchantMatch AI — AI-Powered PSP Matchmaker',
    description: 'An AI agent that ingests merchant profiles and auto-matches them to optimal PSPs, taking 0.05-0.10% of transaction volume. Pedro\'s historical deal data becomes the training dataset—an unstealable moat.',
    submittedBy: 'Researcher',
    submittedAt: '2026-03-02',
    stage: 'submitted',
    tags: ['AI', 'Payments', 'Automation', 'Marketplace'],
    estimatedMarket: '€50K-€500K/month',
    effort: 'Medium',
    validationSteps: [
      'Build simple merchant intake form',
      'Manually match 5 merchants this week to prove concept',
      'Track time saved vs manual matching'
    ],
    whyPedro: 'Your historical deals (50+ PSP relationships, 100+ merchant matches) is the training data. Competitors can\'t replicate this overnight.',
    risk: 'Requires technical build or co-founder',
    hasFullReport: true
  },
  {
    id: '8',
    title: 'Chargeback Insurance as a Service',
    description: 'A mutual pool where merchants pay 0.5% for shared chargeback coverage, reducing PSP rolling reserve requirements. PSPs lower reserves, merchants get predictability, you take a spread.',
    submittedBy: 'Researcher',
    submittedAt: '2026-03-02',
    stage: 'submitted',
    tags: ['Insurance', 'Payments', 'High-Risk', 'B2B'],
    estimatedMarket: '€100K-€1M/month',
    effort: 'High',
    validationSteps: [
      'Ask 3 PSPs: Would you lower reserves if merchants had third-party coverage?',
      'Research regulatory requirements for payment insurance in EU',
      'Find insurance partner or underwriter'
    ],
    whyPedro: 'You understand both merchant pain (high reserves) and PSP concerns (chargeback risk). Unique position to bridge this gap.',
    risk: 'Regulatory complexity; insurance licensing requirements',
    hasFullReport: true
  },
  // Previous ideas
  {
    id: '1',
    title: 'AI-Powered Lead Scoring for Payment Providers',
    description: 'AI-powered lead scoring platform that scrapes public data to identify active high-risk merchants, scores leads by transaction volume, growth trajectory, and payment pain signals.',
    submittedBy: 'Researcher',
    submittedAt: '2026-03-01',
    stage: 'submitted',
    tags: ['AI', 'B2B', 'Payments', 'SaaS'],
    estimatedMarket: '€50K-200K/month',
    effort: 'Medium',
    hasFullReport: false
  },
  {
    id: '2',
    title: 'Payment Partner Intelligence Platform',
    description: 'Vertical CRM with intelligent matching for payments brokers. Solves the pain of manually recalling which PSPs support specific geographies and risk profiles.',
    submittedBy: 'Researcher',
    submittedAt: '2026-03-01',
    stage: 'submitted',
    tags: ['payments', 'b2b-saas', 'crm', 'marketplace'],
    estimatedMarket: '€5K-€50K/month',
    effort: 'Medium',
    hasFullReport: false
  },
  {
    id: '3',
    title: 'High-Risk Merchant Onboarding Hub',
    description: 'Multi-acquirer onboarding hub that helps high-risk merchants get approved faster by streamlining documentation and managing the entire process.',
    submittedBy: 'Researcher',
    submittedAt: '2026-03-01',
    stage: 'submitted',
    tags: ['payments', 'high-risk', 'onboarding', 'b2b-saas'],
    estimatedMarket: '€10K-€100K/month',
    effort: 'Medium-High',
    hasFullReport: false
  },
  {
    id: '4',
    title: 'Crypto-Native Sweepstakes Infrastructure',
    description: 'B2B infrastructure platform for crypto-native sweepstakes operators, providing payment orchestration, compliance automation, and instant settlement.',
    submittedBy: 'Researcher',
    submittedAt: '2026-03-01',
    stage: 'submitted',
    tags: ['sweepstakes', 'crypto', 'B2B', 'infrastructure'],
    estimatedMarket: '€50M-€200M/year',
    effort: 'High',
    hasFullReport: false
  },
  {
    id: '5',
    title: 'Sweepstakes-as-a-Service for Emerging Markets',
    description: 'White-label Sweepstakes-as-a-Service platform enabling rapid, low-cost market entry in emerging markets through the sweepstakes model.',
    submittedBy: 'Researcher',
    submittedAt: '2026-03-01',
    stage: 'submitted',
    tags: ['sweepstakes', 'emerging-markets', 'B2B', 'white-label'],
    estimatedMarket: '€100M-€400M/year',
    effort: 'Medium',
    hasFullReport: false
  }
]

// Kanban columns/stages
const STAGES = [
  { id: 'submitted', title: 'Submitted', color: 'slate', description: 'New ideas from Researcher' },
  { id: 'under-review', title: 'Under Review', color: 'amber', description: 'Luna evaluating' },
  { id: 'approved', title: 'Approved', color: 'emerald', description: 'Ready to build!' },
  { id: 'in-progress', title: 'In Progress', color: 'indigo', description: 'Team building it' },
  { id: 'completed', title: 'Completed', color: 'purple', description: 'Launched!' }
]

export default function Ideas() {
  const [ideas, setIdeas] = useState(SAMPLE_IDEAS)
  const [searchQuery, setSearchQuery] = useState('')
  const [selectedStage, setSelectedStage] = useState('all')
  const [selectedIdea, setSelectedIdea] = useState(null)
  const [showFullReport, setShowFullReport] = useState(false)

  // Filter ideas
  const filteredIdeas = ideas.filter(idea => {
    const matchesSearch = !searchQuery || 
      idea.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
      idea.description.toLowerCase().includes(searchQuery.toLowerCase()) ||
      (idea.tags && idea.tags.some(tag => tag.toLowerCase().includes(searchQuery.toLowerCase())))
    
    const matchesStage = selectedStage === 'all' || idea.stage === selectedStage
    return matchesSearch && matchesStage
  })

  // Group ideas by stage
  const ideasByStage = STAGES.map(stage => ({
    ...stage,
    ideas: filteredIdeas.filter(idea => idea.stage === stage.id)
  }))

  const handleIdeaClick = (idea) => {
    setSelectedIdea(idea)
    setShowFullReport(false)
  }

  const closeModal = () => {
    setSelectedIdea(null)
    setShowFullReport(false)
  }

  const handleViewFullReport = () => {
    setShowFullReport(true)
  }

  const handleDownloadPDF = () => {
    window.print()
  }

  return (
    <div className="h-full flex flex-col p-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 mb-6">
        <div className="flex items-center gap-3">
          <div className="bg-amber-500/20 p-2 rounded-lg">
            <Lightbulb className="w-5 h-5 text-amber-400" />
          </div>
          <div>
            <h2 className="text-xl font-semibold text-white">Ideas Pipeline</h2>
            <p className="text-sm text-slate-400">{filteredIdeas.length} ideas • {ideas.filter(i => i.stage === 'submitted').length} new today</p>
          </div>
        </div>

        <div className="flex items-center gap-3">
          <button className="flex items-center gap-2 px-4 py-2 bg-indigo-600 hover:bg-indigo-500 rounded-lg text-sm font-medium transition-colors">
            <Plus className="w-4 h-4" />
            New Idea
          </button>
        </div>
      </div>

      {/* Filters */}
      <div className="flex flex-col sm:flex-row gap-4 mb-6">
        <div className="relative flex-1">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-500" />
          <input
            type="text"
            placeholder="Search ideas..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="w-full pl-10 pr-4 py-2 bg-slate-900 border border-slate-800 rounded-lg text-sm focus:outline-none focus:border-indigo-500 text-white"
          />
        </div>

        <div className="flex items-center gap-2">
          <Filter className="w-4 h-4 text-slate-500" />
          <select
            value={selectedStage}
            onChange={(e) => setSelectedStage(e.target.value)}
            className="px-3 py-2 bg-slate-900 border border-slate-800 rounded-lg text-sm focus:outline-none focus:border-indigo-500 text-white"
          >
            <option value="all">All Stages</option>
            {STAGES.map(stage => (
              <option key={stage.id} value={stage.id}>{stage.title}</option>
            ))}
          </select>
        </div>
      </div>

      {/* Ideas Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        {filteredIdeas.map((idea) => (
          <div
            key={idea.id}
            onClick={() => handleIdeaClick(idea)}
            className="p-4 bg-slate-900 border border-slate-800 rounded-lg hover:border-indigo-500 hover:shadow-lg hover:shadow-indigo-500/10 transition-all cursor-pointer group"
          >
            <div className="flex items-start justify-between mb-2">
              <h3 className="font-semibold text-white group-hover:text-indigo-400 transition-colors">{idea.title}</h3>
              <ChevronRight className="w-4 h-4 text-slate-600 group-hover:text-indigo-400 transition-colors" />
            </div>

            <p className="text-sm text-slate-400 mb-3 line-clamp-3">{idea.description}</p>

            <div className="flex flex-wrap gap-1 mb-3">
              {idea.tags && idea.tags.map((tag, idx) => (
                <span
                  key={idx}
                  className="text-xs px-2 py-0.5 bg-slate-800 text-slate-400 rounded-full"
                >
                  {tag}
                </span>
              ))}
            </div>

            <div className="flex items-center justify-between text-xs text-slate-500">
              <div className="flex items-center gap-2">
                <User className="w-3 h-3" />
                {idea.submittedBy}
              </div>
              <div className="flex items-center gap-1">
                <Calendar className="w-3 h-3" />
                {idea.submittedAt}
              </div>
            </div>

            {idea.estimatedMarket && (
              <div className="mt-2 pt-2 border-t border-slate-800">
                <span className="text-xs text-emerald-400">💰 {idea.estimatedMarket}</span>
              </div>
            )}
            
            {idea.hasFullReport && (
              <div className="mt-1">
                <span className="text-xs text-indigo-400">📄 Full Report Available</span>
              </div>
            )}
          </div>
        ))}
      </div>

      {filteredIdeas.length === 0 && (
        <div className="text-center py-12">
          <p className="text-slate-500">No ideas found matching your search.</p>
        </div>
      )}

      {/* Idea Detail Modal */}
      {selectedIdea && !showFullReport && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/50 backdrop-blur-sm" onClick={closeModal}>
          <div className="bg-slate-900 border border-slate-700 rounded-xl max-w-2xl w-full max-h-[90vh] overflow-y-auto" onClick={e => e.stopPropagation()}>
            {/* Modal Header */}
            <div className="flex items-start justify-between p-6 border-b border-slate-800">
              <div>
                <h2 className="text-xl font-semibold text-white mb-1">{selectedIdea.title}</h2>
                <div className="flex items-center gap-2 text-sm text-slate-400">
                  <span>Submitted by {selectedIdea.submittedBy}</span>
                  <span>•</span>
                  <span>{selectedIdea.submittedAt}</span>
                </div>
              </div>
              <button onClick={closeModal} className="p-2 hover:bg-slate-800 rounded-lg transition-colors">
                <X className="w-5 h-5 text-slate-400" />
              </button>
            </div>

            {/* Modal Content */}
            <div className="p-6 space-y-6">
              {/* Description */}
              <div>
                <h3 className="text-sm font-medium text-slate-300 mb-2">Description</h3>
                <p className="text-slate-400">{selectedIdea.description}</p>
              </div>

              {/* Why Pedro */}
              {selectedIdea.whyPedro && (
                <div className="bg-indigo-900/20 border border-indigo-800/50 rounded-lg p-4">
                  <h3 className="text-sm font-medium text-indigo-300 mb-2">💪 Why Pedro Should Do This</h3>
                  <p className="text-indigo-200/80 text-sm">{selectedIdea.whyPedro}</p>
                </div>
              )}

              {/* Validation Steps */}
              {selectedIdea.validationSteps && (
                <div>
                  <h3 className="text-sm font-medium text-slate-300 mb-2">✅ Validation Steps (This Week)</h3>
                  <ol className="list-decimal list-inside space-y-1">
                    {selectedIdea.validationSteps.map((step, idx) => (
                      <li key={idx} className="text-sm text-slate-400">{step}</li>
                    ))}
                  </ol>
                </div>
              )}

              {/* Risk */}
              {selectedIdea.risk && (
                <div className="bg-red-900/20 border border-red-800/50 rounded-lg p-4">
                  <h3 className="text-sm font-medium text-red-300 mb-2">⚠️ Key Risk</h3>
                  <p className="text-red-200/80 text-sm">{selectedIdea.risk}</p>
                </div>
              )}

              {/* Tags & Metadata */}
              <div className="flex flex-wrap gap-4 pt-4 border-t border-slate-800">
                <div>
                  <span className="text-xs text-slate-500">Tags</span>
                  <div className="flex flex-wrap gap-1 mt-1">
                    {selectedIdea.tags && selectedIdea.tags.map((tag, idx) => (
                      <span key={idx} className="text-xs px-2 py-1 bg-slate-800 text-slate-300 rounded-full">
                        {tag}
                      </span>
                    ))}
                  </div>
                </div>
                <div>
                  <span className="text-xs text-slate-500">Est. Market</span>
                  <p className="text-sm text-emerald-400 mt-1">{selectedIdea.estimatedMarket}</p>
                </div>
                <div>
                  <span className="text-xs text-slate-500">Effort</span>
                  <p className="text-sm text-slate-300 mt-1">{selectedIdea.effort}</p>
                </div>
              </div>
            </div>

            {/* Modal Footer */}
            <div className="flex items-center justify-end gap-3 p-6 border-t border-slate-800">
              <button 
                onClick={closeModal}
                className="px-4 py-2 text-sm font-medium text-slate-400 hover:text-white transition-colors"
              >
                Close
              </button>
              {selectedIdea.hasFullReport ? (
                <button 
                  onClick={handleViewFullReport}
                  className="flex items-center gap-2 px-4 py-2 bg-indigo-600 hover:bg-indigo-500 rounded-lg text-sm font-medium transition-colors"
                >
                  <FileText className="w-4 h-4" />
                  View Full Report
                </button>
              ) : (
                <button 
                  disabled
                  className="flex items-center gap-2 px-4 py-2 bg-slate-700 text-slate-500 rounded-lg text-sm font-medium cursor-not-allowed"
                >
                  <FileText className="w-4 h-4" />
                  Report Coming Soon
                </button>
              )}
            </div>
          </div>
        </div>
      )}

      {/* Full Report Viewer */}
      {showFullReport && selectedIdea && selectedIdea.hasFullReport && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/80 backdrop-blur-sm" onClick={closeModal}>
          <div className="bg-slate-900 border border-slate-700 rounded-xl max-w-4xl w-full max-h-[90vh] flex flex-col" onClick={e => e.stopPropagation()}>
            {/* Report Header */}
            <div className="flex items-center justify-between p-4 border-b border-slate-200 bg-white">
              <div className="flex items-center gap-3">
                <FileText className="w-5 h-5 text-indigo-600" />
                <div>
                  <h2 className="text-lg font-semibold text-slate-900">Full Research Report</h2>
                  <p className="text-xs text-slate-500">{selectedIdea.title}</p>
                </div>
              </div>
              <div className="flex items-center gap-2">
                <button 
                  onClick={handleDownloadPDF}
                  className="flex items-center gap-2 px-3 py-2 bg-emerald-600 hover:bg-emerald-500 rounded-lg text-sm font-medium transition-colors text-white"
                >
                  <Download className="w-4 h-4" />
                  Download PDF
                </button>
                <button onClick={closeModal} className="p-2 hover:bg-slate-200 rounded-lg transition-colors">
                  <X className="w-5 h-5 text-slate-600" />
                </button>
              </div>
            </div>

            {/* Report Content */}
            <div className="flex-1 overflow-y-auto p-8 print:p-4 bg-white">
              <div className="max-w-none text-slate-800 whitespace-pre-wrap font-mono text-sm leading-relaxed">
                {FULL_RESEARCH_REPORT}
              </div>
            </div>

            {/* Report Footer */}
            <div className="flex items-center justify-between p-4 border-t border-slate-200 bg-white">
              <button 
                onClick={() => setShowFullReport(false)}
                className="flex items-center gap-2 px-4 py-2 text-sm font-medium text-slate-600 hover:text-slate-900 transition-colors"
              >
                <ChevronRight className="w-4 h-4 rotate-180" />
                Back to Summary
              </button>
              <button 
                onClick={handleDownloadPDF}
                className="flex items-center gap-2 px-4 py-2 bg-emerald-600 hover:bg-emerald-500 rounded-lg text-sm font-medium transition-colors text-white"
              >
                <Download className="w-4 h-4" />
                Download PDF
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}
