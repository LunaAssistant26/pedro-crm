import { useState, useEffect } from 'react'
import { 
  Briefcase, 
  Brain, 
  Users, 
  Calendar, 
  Menu,
  X,
  Command,
  Activity,
  Lightbulb,
  TrendingUp,
  Smartphone,
  FileText,
  Target,
  Zap
} from 'lucide-react'
import CRM from './components/CRM'
import Memory from './components/Memory'
import Team from './components/Team'
import CalendarView from './components/Calendar'
import Usage from './components/Usage'
import Ideas from './components/Ideas'
import Financial from './components/Financial'
import Apps from './components/Apps'
import Docs from './components/Docs'

const tabs = [
  { id: 'crm', label: 'CRM', icon: Briefcase },
  { id: 'financial', label: 'Financial', icon: TrendingUp },
  { id: 'memory', label: 'Memory', icon: Brain },
  { id: 'docs', label: 'Documents', icon: FileText },
  { id: 'team', label: 'Team', icon: Users },
  { id: 'calendar', label: 'Calendar', icon: Calendar },
  { id: 'ideas', label: 'Ideas', icon: Lightbulb },
  { id: 'apps', label: 'Apps', icon: Smartphone },
  { id: 'usage', label: 'Usage', icon: Activity },
]

function App() {
  const [activeTab, setActiveTab] = useState('crm')
  const [sidebarOpen, setSidebarOpen] = useState(true)

  useEffect(() => {
    document.title = `Mission Control | ${tabs.find(t => t.id === activeTab)?.label}`
  }, [activeTab])

  const renderContent = () => {
    switch (activeTab) {
      case 'crm': return <CRM />
      case 'financial': return <Financial />
      case 'memory': return <Memory />
      case 'docs': return <Docs />
      case 'team': return <Team />
      case 'calendar': return <CalendarView />
      case 'ideas': return <Ideas />
      case 'apps': return <Apps />
      case 'usage': return <Usage />
      default: return <CRM />
    }
  }

  return (
    <div className="min-h-screen bg-slate-950 flex">
      {/* Sidebar */}
      <aside 
        className={`bg-slate-900 border-r border-slate-800 flex flex-col transition-all duration-300 ${
          sidebarOpen ? 'w-64' : 'w-16'
        }`}
      >
        {/* Logo Area */}
        <div className="p-4 border-b border-slate-800">
          <div className="flex items-center gap-3">
            <div className="bg-indigo-600 p-2 rounded-lg shrink-0">
              <Command className="w-5 h-5 text-white" />
            </div>
            {sidebarOpen && (
              <div className="overflow-hidden">
                <h1 className="text-lg font-semibold text-white truncate">Mission Control</h1>
                <p className="text-xs text-slate-400 truncate">Pedro's AI Organization</p>
              </div>
            )}
          </div>
        </div>

        {/* Mission Statement */}
        {sidebarOpen && (
          <div className="p-4 border-b border-slate-800 bg-slate-800/50">
            <div className="flex items-center gap-2 mb-2">
              <Target className="w-4 h-4 text-emerald-400" />
              <span className="text-xs font-medium text-emerald-400 uppercase tracking-wider">Our Mission</span>
            </div>
            <p className="text-xs text-slate-300 italic leading-relaxed">
              "A self-operating AI organization that turns my ideas into revenue — so I have less mental load and more time for what matters."
            </p>
          </div>
        )}

        {/* Navigation */}
        <nav className="flex-1 py-4 px-2 space-y-1 overflow-y-auto">
          {tabs.map((tab) => {
            const Icon = tab.icon
            const isActive = activeTab === tab.id
            return (
              <button
                key={tab.id}
                onClick={() => setActiveTab(tab.id)}
                className={`w-full flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium transition-all ${
                  isActive
                    ? 'bg-indigo-600 text-white'
                    : 'text-slate-400 hover:text-white hover:bg-slate-800'
                }`}
                title={!sidebarOpen ? tab.label : undefined}
              >
                <Icon className="w-5 h-5 shrink-0" />
                {sidebarOpen && <span className="truncate">{tab.label}</span>}
              </button>
            )
          })}
        </nav>

        {/* Status Footer */}
        <div className="p-4 border-t border-slate-800">
          <div className="flex items-center gap-2">
            <div className="w-2 h-2 bg-emerald-500 rounded-full animate-pulse"></div>
            {sidebarOpen && (
              <div className="text-xs">
                <span className="text-emerald-400 font-medium">AI Agents Active</span>
                <p className="text-slate-500">24/7 Operation</p>
              </div>
            )}
          </div>
          
          {/* Toggle Button */}
          <button
            onClick={() => setSidebarOpen(!sidebarOpen)}
            className="mt-3 w-full flex items-center justify-center gap-2 px-3 py-2 text-xs text-slate-500 hover:text-white hover:bg-slate-800 rounded-lg transition-colors"
          >
            {sidebarOpen ? (
              <><X className="w-4 h-4" /> Collapse</>
            ) : (
              <><Menu className="w-4 h-4" /></>
            )}
          </button>
        </div>
      </aside>

      {/* Main Content */}
      <main className="flex-1 overflow-auto">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
          {renderContent()}
        </div>
      </main>
    </div>
  )
}

export default App
