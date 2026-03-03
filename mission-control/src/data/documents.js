export const documents = [
  {
    id: 'sweepstakes-crypto-research',
    docFile: 'sweepstakes-crypto-research.md',
    title: 'Sweepstakes Casino Market Research: Crypto-Only Analysis',
    category: 'Business Research',
    tags: ['sweepstakes', 'gaming', 'crypto', 'market-research', 'business-idea'],
    date: '2026-03-03',
    author: 'Researcher',
    summary: 'Deep dive into $10.6B sweepstakes market. Verdict: Crypto-only approach is high risk (3/10 viability). Regulatory crackdown accelerating. Recommended alternatives: Infrastructure-as-a-Service play.',
    path: '/Users/pedro/.openclaw/workspace/research/business-ideas/2026-03-03-sweepstakes-crypto-research.md',
    status: 'Complete'
  },
  {
    id: 'walking-routes-launch-strategy',
    docFile: 'walking-routes-launch-strategy.md',
    title: 'Walking Routes — Launch, Global City Expansion, and App Store Pricing Strategy',
    category: 'App Strategy',
    tags: ['walking-routes', 'launch', 'pricing', 'expansion', 'ios'],
    date: '2026-03-02',
    author: 'Program Manager',
    summary: '30/60/90-day plan for Walking Routes app. Freemium + Subscription pricing (€8.99/mo). City expansion engine for scaling to 50+ cities. Unit economics and App Store rollout waves.',
    path: '/Users/pedro/.openclaw/workspace/projects/walking-routes/research/launch-expansion-pricing-strategy.md',
    status: 'Complete'
  },
  {
    id: 'investment-research-2026-03-03',
    docFile: 'investment-research-2026-03-03.md',
    title: 'Investment Research Summary - March 3, 2026',
    category: 'Financial',
    tags: ['investment', 'portfolio', 'nvda', 'btc', 'iwda', 'etf'],
    date: '2026-03-03',
    author: 'Financial Advisor',
    summary: '€10K portfolio recommendation: 60% IWDA, 25% NVDA, 15% BTC. Long-term investing thesis for 3-5+ year horizon.',
    path: '/Users/pedro/.openclaw/workspace/research/financial-advisor/2026-03-03-report.md',
    status: 'Complete'
  },
  {
    id: 'ai-workflow-process',
    docFile: 'ai-workflow-process.md',
    title: 'AI Development Workflow — Hybrid Model Process',
    category: 'Process',
    tags: ['workflow', 'ai', 'kimi', 'openai', 'development', 'process'],
    date: '2026-03-03',
    author: 'Luna',
    summary: 'Formalized hybrid AI development workflow. Kimi K2.5 for 80% of tasks, OpenAI GPT-5.2 for escalations. Cost optimization and escalation criteria.',
    path: '/Users/pedro/.openclaw/workspace/WORKFLOW_AUTO.md',
    status: 'Active'
  },
  {
    id: 'walking-routes-sprint-3',
    docFile: 'walking-routes-sprint-3.md',
    title: 'Walking Routes Sprint 3: Monetization & Launch Prep',
    category: 'App Development',
    tags: ['walking-routes', 'sprint', 'monetization', 'testflight', 'ios'],
    date: '2026-03-03',
    author: 'Luna',
    summary: 'Sprint 3 plan: Paywall implementation, offline maps, analytics, TestFlight submission. Hybrid AI workflow with ~$3.30 budget.',
    path: '/Users/pedro/.openclaw/workspace/projects/walking-routes/sprints/sprint-3-monetization.md',
    status: 'In Progress'
  },
  {
    id: 'model-comparison-kimi-openai',
    docFile: 'model-comparison-kimi-openai.md',
    title: 'Kimi vs OpenAI Codex — Cost Comparison & Analysis',
    category: 'Research',
    tags: ['ai', 'kimi', 'openai', 'pricing', 'comparison', 'models'],
    date: '2026-03-03',
    author: 'Luna',
    summary: 'Comprehensive cost and capability comparison. Kimi is 3-5x cheaper. Recommended workflow: Kimi primary (80%), OpenAI escalation (20%).',
    path: null,
    status: 'Complete'
  },
  {
    id: 'mission-statement',
    docFile: 'mission-statement.md',
    title: 'Luna AI Organization — Mission Statement',
    category: 'Organization',
    tags: ['mission', 'vision', 'organization', 'values'],
    date: '2026-03-03',
    author: 'Luna',
    summary: 'Core mission: A self-operating AI organization that turns Pedro\'s ideas into revenue — so he has less mental load and more time for what matters. Principles, success metrics, and future vision.',
    path: '/Users/pedro/.openclaw/workspace/MISSION.md',
    status: 'Active'
  }
]

export const categories = [
  'All',
  'Business Research',
  'App Strategy',
  'App Development',
  'Financial',
  'Process',
  'Research',
  'Organization'
]

export const allTags = [
  ...new Set(documents.flatMap(doc => doc.tags))
].sort()
