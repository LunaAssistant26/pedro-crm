import { useState, useEffect } from 'react'
import { Search, FileText, Calendar, Brain } from 'lucide-react'

// Initial memory data - in a real app, this would be loaded from files
const initialMemoryData = {
  overview: {
    title: "Luna's Long-Term Memory",
    lastUpdated: "2026-02-27",
    entries: [
      {
        category: "About Pedro",
        items: [
          "Name: Pedro",
          "Location: Amsterdam (GMT+1)",
          "Business: Independent payments referral + building Tara app",
          "Communication style: Short bullet points, casual tone"
        ]
      },
      {
        category: "Current Projects",
        items: [
          "1. Payments Referral Business - Matchmaking high-risk merchants (gambling, crypto, CFD/FX, adult)",
          "   Revenue: €2K-€10K/month per deal",
          "   Pain point: No CRM system - relies on memory",
          "   90-day goal: Close 2+ deals",
          "",
          "2. Tara App - Financial OS for recurring session-based solo professionals",
          "   Target: Personal trainers, coaches, tutors",
          "   Status: Pre-MVP, Figma prototype",
          "   90-day goal: Launch sign-up page, get test client by June"
        ]
      },
      {
        category: "Technical Setup",
        items: [
          "Channels: Discord (working), Telegram (broken on macOS)",
          "Model: Kimi for Coding (k2p5) primary, Kimi K2.5 fallback",
          "Memory: Local embeddings enabled",
          "Browser: Chrome configured"
        ]
      },
      {
        category: "Known Issues",
        items: [
          "Telegram Bug (2026-02-27): Plugin hardcodes Linux path - incompatible with macOS",
          "Workaround: Use Discord instead"
        ]
      },
      {
        category: "Preferences",
        items: [
          "Uses Discord for OpenClaw (reliable)",
          "Wants proactive suggestions for reaching goals",
          "Needs help with: research, business thinking, follow-ups, deal tracking"
        ]
      }
    ]
  },
  dailyFiles: [
    {
      date: "2026-02-27",
      title: "Friday - Setup Day",
      summary: "Set up Discord integration for mobile access, configured browser automation, enabled local memory embeddings, disabled Telegram due to macOS bug, drafted bug report for OpenClaw Telegram plugin.",
      tags: ["setup", "discord", "telegram-bug"]
    }
  ]
}

function Memory() {
  const [searchQuery, setSearchQuery] = useState('')
  const [activeView, setActiveView] = useState('overview')
  const [memoryData, setMemoryData] = useState(initialMemoryData)

  // Load from localStorage on mount
  useEffect(() => {
    const saved = localStorage.getItem('missionControl_memory')
    if (saved) {
      try {
        setMemoryData(JSON.parse(saved))
      } catch (e) {
        console.error('Failed to load memory:', e)
      }
    }
  }, [])

  // Filter function
  const filteredData = () => {
    if (!searchQuery) return memoryData

    const query = searchQuery.toLowerCase()
    
    // Filter overview entries
    const filteredOverview = {
      ...memoryData.overview,
      entries: memoryData.overview.entries.map(entry => ({
        ...entry,
        items: entry.items.filter(item => 
          item.toLowerCase().includes(query)
        )
      })).filter(entry => entry.items.length > 0)
    }

    // Filter daily files
    const filteredDaily = memoryData.dailyFiles.filter(file =>
      file.title.toLowerCase().includes(query) ||
      file.summary.toLowerCase().includes(query) ||
      file.tags.some(tag => tag.toLowerCase().includes(query))
    )

    return {
      overview: filteredOverview,
      dailyFiles: filteredDaily
    }
  }

  const data = filteredData()

  return (
    <div className="space-y-6">
      {/* Search Bar */}
      <div className="card p-4">
        <div className="relative">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-slate-400" />
          <input
            type="text"
            placeholder="Search memory..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="w-full bg-slate-900 border border-slate-700 rounded-lg pl-10 pr-4 py-3 text-white placeholder-slate-500 focus:outline-none focus:border-indigo-500"
          />
        </div>
      </div>

      {/* View Tabs */}
      <div className="flex gap-2 border-b border-slate-800 pb-4">
        <button
          onClick={() => setActiveView('overview')}
          className={`flex items-center gap-2 px-4 py-2 rounded-lg text-sm font-medium transition-all ${
            activeView === 'overview'
              ? 'bg-slate-800 text-white'
              : 'text-slate-400 hover:text-white'
          }`}
        >
          <Brain className="w-4 h-4" />
          Overview
        </button>
        <button
          onClick={() => setActiveView('daily')}
          className={`flex items-center gap-2 px-4 py-2 rounded-lg text-sm font-medium transition-all ${
            activeView === 'daily'
              ? 'bg-slate-800 text-white'
              : 'text-slate-400 hover:text-white'
          }`}
        >
          <Calendar className="w-4 h-4" />
          Daily Notes
        </button>
      </div>

      {/* Content */}
      <div className="space-y-4">
        {activeView === 'overview' && (
          <div className="space-y-4">
            <div className="flex items-center gap-2 text-slate-400 text-sm">
              <Brain className="w-4 h-4" />
              <span>Last updated: {data.overview.lastUpdated}</span>
            </div>

            {data.overview.entries.map((entry, idx) => (
              <div key={idx} className="card p-6">
                <h3 className="text-lg font-semibold text-white mb-4 flex items-center gap-2">
                  <FileText className="w-5 h-5 text-indigo-400" />
                  {entry.category}
                </h3>
                <div className="space-y-2">
                  {entry.items.map((item, itemIdx) => (
                    <div 
                      key={itemIdx} 
                      className={`text-sm ${item.startsWith(' ') ? 'pl-4 text-slate-400' : 'text-slate-300'}`}
                    >
                      {item}
                    </div>
                  ))}
                </div>
              </div>
            ))}
          </div>
        )}

        {activeView === 'daily' && (
          <div className="space-y-4">
            {data.dailyFiles.length === 0 ? (
              <div className="card p-8 text-center">
                <p className="text-slate-400">No daily notes found.</p>
              </div>
            ) : (
              data.dailyFiles.map((file, idx) => (
                <div key={idx} className="card p-6">
                  <div className="flex items-center justify-between mb-3">
                    <h3 className="text-lg font-semibold text-white">{file.title}</h3>
                    <span className="text-sm text-slate-500">{file.date}</span>
                  </div>
                  
                  <p className="text-slate-300 text-sm mb-4">{file.summary}</p>
                  
                  <div className="flex flex-wrap gap-2">
                    {file.tags.map((tag) => (
                      <span key={tag} className="badge badge-info">
                        #{tag}
                      </span>
                    ))}
                  </div>
                </div>
              ))
            )}
          </div>
        )}
      </div>
    </div>
  )
}

export default Memory
