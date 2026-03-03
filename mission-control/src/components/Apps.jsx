import { useState } from 'react'
import { 
  Smartphone, 
  Code, 
  Camera, 
  FileText, 
  CheckCircle2, 
  Clock,
  ChevronRight,
  ExternalLink,
  GitBranch,
  Cpu
} from 'lucide-react'

// Apps data - this can be updated as we build more apps
const apps = [
  {
    id: 'walking-routes',
    name: 'Walking Routes',
    tagline: 'Discover the perfect walk, wherever you are',
    status: 'In Development',
    version: '0.2.0',
    platform: 'iOS',
    lastUpdated: '2026-03-02',
    progress: 65,
    description: 'Time-based walking route discovery app for travelers. Features curated routes with landmarks, photos, and turn-by-turn navigation.',
    features: [
      'Time-based route discovery (slider)',
      '3 Amsterdam routes with real photos',
      'GPS location integration',
      'Real walking routes (follows streets)',
      'Navigation mode with progress tracking',
      'Modern travel app UI design'
    ],
    screenshots: [
      { name: 'Home Screen', file: '01-home-slider.png', description: 'Time selector with slider' },
      { name: 'Route Detail - Canal Ring', file: '02-detail-canalring.png', description: 'Blue route on map' },
      { name: 'Route Detail - Jordaan', file: '03-detail-jordaan.png', description: 'Green route on map' },
      { name: 'Route Detail - Vondelpark', file: '04-detail-vondelpark.png', description: 'Orange route on map' },
      { name: 'Navigation Mode', file: '05-navigation.png', description: 'Full-screen navigation' }
    ],
    reports: [
      { 
        version: '0.3.0-sprint3', 
        date: '2026-03-03', 
        summary: 'Sprint 3 started: Paywall, offline maps, TestFlight prep (Hybrid AI workflow)',
        status: 'In Progress'
      },
      { 
        version: '0.2.0', 
        date: '2026-03-02', 
        summary: 'Phase 2 complete: Real photos, GPS, real routes, modern UI',
        status: 'Complete'
      },
      { 
        version: '0.1.0', 
        date: '2026-03-02', 
        summary: 'MVP: Basic UI, 3 Amsterdam routes, time selector',
        status: 'Complete'
      }
    ],
    nextSteps: [
      'Sprint 3: Freemium paywall with StoreKit',
      'Sprint 3: Offline maps for Amsterdam routes',
      'Sprint 3: Analytics and conversion tracking',
      'Sprint 3: TestFlight beta submission',
      'Sprint 4: Expand to 5 pilot cities (Lisbon, Barcelona, London, Rome)',
      'Future: Subscription revenue optimization'
    ],
    aiWorkflow: {
      primary: 'Kimi K2.5 (80%)',
      escalation: 'OpenAI GPT-5.2 (20%)',
      currentSprint: 'sprint-3-monetization.md'
    },
    path: '/Users/pedro/.openclaw/workspace/projects/walking-routes',
    techStack: ['SwiftUI', 'MapKit', 'CoreLocation', 'iOS 16+']
  }
]

export default function Apps() {
  const [selectedApp, setSelectedApp] = useState(null)
  const [activeTab, setActiveTab] = useState('overview')

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-3">
          <div className="bg-indigo-500/20 p-2 rounded-lg">
            <Smartphone className="w-5 h-5 text-indigo-400" />
          </div>
          <div>
            <h2 className="text-xl font-semibold text-white">Apps</h2>
            <p className="text-sm text-slate-400">{apps.length} app{apps.length !== 1 ? 's' : ''} in development</p>
          </div>
        </div>
      </div>

      {/* Apps Grid */}
      {!selectedApp ? (
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          {apps.map((app) => (
            <div
              key={app.id}
              onClick={() => setSelectedApp(app)}
              className="card p-5 cursor-pointer hover:border-indigo-500 transition-all group"
            >
              <div className="flex items-start justify-between mb-4">
                <div className="flex items-center gap-3">
                  <div className="bg-slate-800 p-3 rounded-xl">
                    <Code className="w-6 h-6 text-indigo-400" />
                  </div>
                  <div>
                    <h3 className="font-semibold text-white group-hover:text-indigo-400 transition-colors">
                      {app.name}
                    </h3>
                    <p className="text-sm text-slate-400">{app.platform}</p>
                  </div>
                </div>
                <span className={`px-2 py-1 rounded-full text-xs font-medium ${
                  app.status === 'In Development' ? 'bg-amber-500/20 text-amber-400' :
                  app.status === 'In Beta' ? 'bg-blue-500/20 text-blue-400' :
                  'bg-emerald-500/20 text-emerald-400'
                }`}>
                  {app.status}
                </span>
              </div>

              <p className="text-slate-300 text-sm mb-4 line-clamp-2">
                {app.tagline}
              </p>

              {/* Progress Bar */}
              <div className="mb-4">
                <div className="flex items-center justify-between text-xs mb-1">
                  <span className="text-slate-400">Progress</span>
                  <span className="text-white font-medium">{app.progress}%</span>
                </div>
                <div className="h-2 bg-slate-800 rounded-full overflow-hidden">
                  <div 
                    className="h-full bg-gradient-to-r from-indigo-500 to-purple-500 rounded-full transition-all"
                    style={{ width: `${app.progress}%` }}
                  />
                </div>
              </div>

              <div className="flex items-center justify-between text-xs text-slate-400">
                <span>v{app.version}</span>
                <span>Updated {app.lastUpdated}</span>
              </div>
            </div>
          ))}
        </div>
      ) : (
        /* App Detail View */
        <div className="space-y-6">
          {/* Back Button & Header */}
          <div className="flex items-center gap-4">
            <button
              onClick={() => setSelectedApp(null)}
              className="flex items-center gap-2 text-slate-400 hover:text-white transition-colors"
            >
              <ChevronRight className="w-4 h-4 rotate-180" />
              Back to Apps
            </button>
          </div>

          {/* App Header */}
          <div className="card p-6">
            <div className="flex items-start justify-between mb-4">
              <div className="flex items-center gap-4">
                <div className="bg-indigo-500/20 p-4 rounded-2xl">
                  <Smartphone className="w-8 h-8 text-indigo-400" />
                </div>
                <div>
                  <h2 className="text-2xl font-bold text-white">{selectedApp.name}</h2>
                  <p className="text-slate-400">{selectedApp.tagline}</p>
                </div>
              </div>
              <div className="flex items-center gap-3">
                <span className="text-sm text-slate-400">v{selectedApp.version}</span>
                <span className={`px-3 py-1 rounded-full text-xs font-medium ${
                  selectedApp.status === 'In Development' ? 'bg-amber-500/20 text-amber-400' :
                  selectedApp.status === 'In Beta' ? 'bg-blue-500/20 text-blue-400' :
                  'bg-emerald-500/20 text-emerald-400'
                }`}>
                  {selectedApp.status}
                </span>
              </div>
            </div>

            {/* Progress */}
            <div className="mb-4">
              <div className="flex items-center justify-between text-sm mb-2">
                <span className="text-slate-400">Development Progress</span>
                <span className="text-white font-medium">{selectedApp.progress}%</span>
              </div>
              <div className="h-3 bg-slate-800 rounded-full overflow-hidden">
                <div 
                  className="h-full bg-gradient-to-r from-indigo-500 to-purple-500 rounded-full"
                  style={{ width: `${selectedApp.progress}%` }}
                />
              </div>
            </div>

            <p className="text-slate-300">{selectedApp.description}</p>
          </div>

          {/* Tabs */}
          <div className="flex gap-2 border-b border-slate-800 pb-4">
            {['overview', 'screenshots', 'reports'].map((tab) => (
              <button
                key={tab}
                onClick={() => setActiveTab(tab)}
                className={`px-4 py-2 rounded-lg text-sm font-medium capitalize transition-all ${
                  activeTab === tab
                    ? 'bg-slate-800 text-white'
                    : 'text-slate-400 hover:text-white'
                }`}
              >
                {tab}
              </button>
            ))}
          </div>

          {/* Tab Content */}
          {activeTab === 'overview' && (
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              {/* Features */}
              <div className="card p-5">
                <div className="flex items-center gap-2 mb-4">
                  <CheckCircle2 className="w-5 h-5 text-emerald-400" />
                  <h3 className="font-semibold text-white">Features Implemented</h3>
                </div>
                <ul className="space-y-2">
                  {selectedApp.features.map((feature, idx) => (
                    <li key={idx} className="flex items-start gap-2 text-sm text-slate-300">
                      <span className="text-emerald-400 mt-0.5">✓</span>
                      {feature}
                    </li>
                  ))}
                </ul>
              </div>

              {/* Next Steps */}
              <div className="card p-5">
                <div className="flex items-center gap-2 mb-4">
                  <Clock className="w-5 h-5 text-amber-400" />
                  <h3 className="font-semibold text-white">Next Steps</h3>
                </div>
                <ul className="space-y-2">
                  {selectedApp.nextSteps.map((step, idx) => (
                    <li key={idx} className="flex items-start gap-2 text-sm text-slate-300">
                      <span className="text-amber-400 mt-0.5">→</span>
                      {step}
                    </li>
                  ))}
                </ul>
              </div>

              {/* Tech Stack */}
              <div className="card p-5">
                <div className="flex items-center gap-2 mb-4">
                  <GitBranch className="w-5 h-5 text-blue-400" />
                  <h3 className="font-semibold text-white">Tech Stack</h3>
                </div>
                <div className="flex flex-wrap gap-2">
                  {selectedApp.techStack.map((tech, idx) => (
                    <span key={idx} className="px-3 py-1 bg-slate-800 rounded-full text-xs text-slate-300">
                      {tech}
                    </span>
                  ))}
                </div>
              </div>

              {/* AI Workflow */}
              <div className="card p-5">
                <div className="flex items-center gap-2 mb-4">
                  <Cpu className="w-5 h-5 text-emerald-400" />
                  <h3 className="font-semibold text-white">AI Development Workflow</h3>
                </div>
                <div className="space-y-3">
                  <div className="flex justify-between text-sm">
                    <span className="text-slate-400">Primary Model</span>
                    <span className="text-emerald-400 font-medium">{selectedApp.aiWorkflow?.primary}</span>
                  </div>
                  <div className="flex justify-between text-sm">
                    <span className="text-slate-400">Escalation Model</span>
                    <span className="text-amber-400 font-medium">{selectedApp.aiWorkflow?.escalation}</span>
                  </div>
                  <div className="flex justify-between text-sm">
                    <span className="text-slate-400">Current Sprint</span>
                    <span className="text-blue-400 font-medium">{selectedApp.aiWorkflow?.currentSprint}</span>
                  </div>
                </div>
              </div>

              {/* Project Path */}
              <div className="card p-5">
                <div className="flex items-center gap-2 mb-4">
                  <FileText className="w-5 h-5 text-purple-400" />
                  <h3 className="font-semibold text-white">Project Location</h3>
                </div>
                <code className="text-xs text-slate-400 bg-slate-900 p-2 rounded block break-all">
                  {selectedApp.path}
                </code>
              </div>
            </div>
          )}

          {activeTab === 'screenshots' && (
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              {selectedApp.screenshots.map((screenshot, idx) => (
                <div key={idx} className="card p-4">
                  <div className="aspect-[9/19] bg-slate-800 rounded-lg mb-3 flex items-center justify-center">
                    <Camera className="w-8 h-8 text-slate-600" />
                    <span className="ml-2 text-sm text-slate-500">{screenshot.file}</span>
                  </div>
                  <h4 className="font-medium text-white text-sm">{screenshot.name}</h4>
                  <p className="text-xs text-slate-400">{screenshot.description}</p>
                </div>
              ))}
            </div>
          )}

          {activeTab === 'reports' && (
            <div className="space-y-4">
              {selectedApp.reports.map((report, idx) => (
                <div key={idx} className="card p-5">
                  <div className="flex items-center justify-between mb-2">
                    <div className="flex items-center gap-2">
                      <span className="text-lg font-bold text-white">v{report.version}</span>
                      <span className={`px-2 py-0.5 rounded text-xs ${
                        report.status === 'Complete' ? 'bg-emerald-500/20 text-emerald-400' :
                        'bg-amber-500/20 text-amber-400'
                      }`}>
                        {report.status}
                      </span>
                    </div>
                    <span className="text-sm text-slate-400">{report.date}</span>
                  </div>
                  <p className="text-slate-300">{report.summary}</p>
                </div>
              ))}
            </div>
          )}
        </div>
      )}
    </div>
  )
}
