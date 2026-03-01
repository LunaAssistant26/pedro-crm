import { useState } from 'react'
import { 
  Crown, 
  UserPlus, 
  Palette, 
  Code, 
  FolderKanban,
  Cpu,
  Mail,
  MessageSquare,
  Bot,
  Search
} from 'lucide-react'

// OPTIMIZED MODEL ASSIGNMENTS - Updated 2026-02-28
const teamMembers = [
  {
    id: 'luna',
    name: 'Luna',
    role: 'Chief of Staff',
    status: 'Active',
    model: 'Kimi for Coding / k2p5',
    modelProvider: 'kimi-coding',
    avatar: '👑',
    description: 'Your primary AI assistant. Handles research, business thinking, follow-ups, and deal tracking.',
    responsibilities: [
      'Research and market intelligence',
      'Business strategy discussions',
      'Deal follow-up reminders',
      'CRM management',
      'Partner intelligence tracking'
    ],
    contact: 'Available via Discord, Webchat',
    icon: Crown,
    color: 'indigo'
  },
  {
    id: 'researcher',
    name: 'Researcher',
    role: 'Business Opportunity Research',
    status: 'Active',
    model: 'Kimi for Coding / k2p5',
    modelProvider: 'kimi-coding',
    avatar: '🔍',
    description: 'Discovers new business opportunities daily. Uses K2.5 for deep market analysis and connecting dots across data points.',
    responsibilities: [
      'Research 2 new business opportunities daily',
      'Market analysis and validation',
      'Competitor research',
      'Trend identification',
      'Opportunity briefs for Luna & PM'
    ],
    contact: 'Daily reports to Luna & Program Manager',
    icon: Search,
    color: 'cyan'
  },
  {
    id: 'sdr',
    name: 'SDR (Sales Dev Rep)',
    role: 'Lead Generation',
    status: 'Hiring',
    model: 'Kimi K2.5',
    modelProvider: 'moonshot',
    avatar: '🎯',
    description: 'Handles prospecting and finding high-risk merchant contact details. Uses K2.5 for natural language and creative outreach.',
    responsibilities: [
      'Find gambling operator contacts',
      'Research CFD/FX trading platforms',
      'Identify adult industry prospects',
      'Build prospect lists',
      'Personalized outreach messages'
    ],
    contact: 'TBD',
    icon: UserPlus,
    color: 'emerald'
  },
  {
    id: 'designer',
    name: 'Designer',
    role: 'UI/UX Design',
    status: 'Hiring',
    model: 'Kimi K2.5 + GPT-4o (optional)',
    modelProvider: 'moonshot + openai',
    avatar: '🎨',
    description: 'Handles visual design, branding, and user experience. K2.5 for concepts; GPT-4o recommended for visual feedback.',
    responsibilities: [
      'Tara app UI/UX design',
      'Brand identity development',
      'Marketing materials',
      'Design system creation'
    ],
    contact: 'TBD',
    icon: Palette,
    color: 'purple'
  },
  {
    id: 'developer',
    name: 'Web/App Developer',
    role: 'Full Stack Development',
    status: 'Hiring',
    model: 'Kimi for Coding / k2p5',
    modelProvider: 'kimi-coding',
    avatar: '💻',
    description: 'Builds Tara app and other technical projects. Best coding model for SwiftUI, backend, and architecture.',
    responsibilities: [
      'Tara app development (SwiftUI)',
      'Backend architecture',
      'Payment infrastructure',
      'API integrations'
    ],
    contact: 'TBD',
    icon: Code,
    color: 'blue'
  },
  {
    id: 'pm',
    name: 'Program Manager',
    role: 'Project Coordination',
    status: 'Hiring',
    model: 'Kimi for Coding / k2p5',
    modelProvider: 'kimi-coding',
    avatar: '📋',
    description: 'Coordinates projects, tracks milestones, and ensures delivery. Uses K2.5 for complex planning and resource allocation.',
    responsibilities: [
      'Project timeline management',
      'Milestone tracking',
      'Team coordination',
      'Process optimization'
    ],
    contact: 'TBD',
    icon: FolderKanban,
    color: 'amber'
  }
]

const colorClasses = {
  indigo: 'bg-indigo-500/20 text-indigo-400 border-indigo-500/30',
  emerald: 'bg-emerald-500/20 text-emerald-400 border-emerald-500/30',
  purple: 'bg-purple-500/20 text-purple-400 border-purple-500/30',
  blue: 'bg-blue-500/20 text-blue-400 border-blue-500/30',
  amber: 'bg-amber-500/20 text-amber-400 border-amber-500/30',
  cyan: 'bg-cyan-500/20 text-cyan-400 border-cyan-500/30'
}

function Team() {
  const [selectedMember, setSelectedMember] = useState(null)

  return (
    <div className="space-y-6">
      {/* Optimization Notice */}
      <div className="card p-4 border-l-4 border-emerald-500">
        <div className="flex items-start gap-3">
          <div className="bg-emerald-500/20 p-2 rounded-lg">
            <Cpu className="w-5 h-5 text-emerald-400" />
          </div>
          <div>
            <h3 className="font-semibold text-white">Models Optimized for Performance</h3>
            <p className="text-sm text-slate-400 mt-1">
              Team model assignments updated for maximum efficiency. 
              All cloud-based, ready to deploy.
            </p>
          </div>
        </div>
      </div>

      {/* Team Overview */}
      <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-6 gap-4">
        {teamMembers.map((member) => {
          const Icon = member.icon
          return (
            <button
              key={member.id}
              onClick={() => setSelectedMember(member)}
              className={`card p-4 text-left transition-all hover:scale-105 ${
                selectedMember?.id === member.id ? 'ring-2 ring-indigo-500' : ''
              }`}
            >
              <div className="flex items-center justify-between mb-3">
                <span className="text-2xl">{member.avatar}</span>
                <span className={`text-xs px-2 py-1 rounded-full ${
                  member.status === 'Active' 
                    ? 'bg-emerald-500/20 text-emerald-400' 
                    : 'bg-slate-700 text-slate-400'
                }`}>
                  {member.status}
                </span>
              </div>
              
              <h3 className="font-semibold text-white text-sm">{member.name}</h3>
              <p className="text-xs text-slate-400">{member.role}</p>
              
              <div className="mt-3 flex items-center gap-1 text-xs text-slate-500">
                <Bot className="w-3 h-3" />
                {member.modelProvider.includes('+') ? 'Multi' : member.modelProvider}
              </div>
            </button>
          )
        })}
      </div>

      {/* Selected Member Details */}
      {selectedMember ? (
        <div className={`card p-6 border-l-4 ${colorClasses[selectedMember.color]}`}>
          <div className="flex items-start justify-between mb-6">
            <div className="flex items-center gap-4">
              <div className={`p-4 rounded-xl ${colorClasses[selectedMember.color]}`}>
                <selectedMember.icon className="w-8 h-8" />
              </div>
              <div>
                <h2 className="text-2xl font-bold text-white">{selectedMember.name}</h2>
                <p className="text-slate-400">{selectedMember.role}</p>
              </div>
            </div>
            
            <div className="text-right">
              <div className="flex items-center gap-2">
                <Cpu className="w-4 h-4 text-slate-400" />
                <span className="text-sm text-slate-400">{selectedMember.model}</span>
              </div>
              <p className="text-xs text-slate-500 mt-1">via {selectedMember.modelProvider}</p>
            </div>
          </div>

          <div className="grid md:grid-cols-2 gap-6">
            <div>
              <h3 className="text-sm font-semibold text-slate-300 mb-3">About</h3>
              <p className="text-slate-400 text-sm leading-relaxed">
                {selectedMember.description}
              </p>
              
              <div className="mt-4 flex items-center gap-2 text-sm text-slate-500">
                <MessageSquare className="w-4 h-4" />
                {selectedMember.contact}
              </div>
            </div>

            <div>
              <h3 className="text-sm font-semibold text-slate-300 mb-3">Responsibilities</h3>
              <ul className="space-y-2">
                {selectedMember.responsibilities.map((resp, idx) => (
                  <li key={idx} className="flex items-start gap-2 text-sm text-slate-400">
                    <span className="text-indigo-400 mt-1">•</span>
                    {resp}
                  </li>
                ))}
              </ul>
            </div>
          </div>
        </div>
      ) : (
        <div className="card p-8 text-center">
          <p className="text-slate-400">Select a team member to view details</p>
        </div>
      )}

      {/* Model Legend - Optimized */}
      <div className="card p-6">
        <h3 className="text-lg font-semibold text-white mb-4">Optimized Model Configuration</h3>
        
        <div className="grid md:grid-cols-3 gap-4 text-sm">
          {/* Primary Models */}
          <div className="space-y-3">
            <p className="text-xs font-semibold text-slate-500 uppercase tracking-wider mb-2">Primary (4 team members)</p>
            
            <div className="flex items-center justify-between p-3 bg-slate-900 rounded-lg border border-emerald-500/30">
              <div className="flex items-center gap-2">
                <span className="text-emerald-400">●</span>
                <div>
                  <span className="text-white font-medium">Kimi for Coding / k2p5</span>
                  <p className="text-xs text-slate-500">Complex reasoning & coding</p>
                </div>
              </div>
              <span className="text-xs text-emerald-400">FREE</span>
            </div>
          </div>
          
          {/* Secondary Models */}
          <div className="space-y-3">
            <p className="text-xs font-semibold text-slate-500 uppercase tracking-wider mb-2">Secondary (2 team members)</p>
            
            <div className="flex items-center justify-between p-3 bg-slate-900 rounded-lg border border-indigo-500/30">
              <div className="flex items-center gap-2">
                <span className="text-indigo-400">●</span>
                <div>
                  <span className="text-white font-medium">Kimi K2.5</span>
                  <p className="text-xs text-slate-500">General tasks & creativity</p>
                </div>
              </div>
              <span className="text-xs text-indigo-400">FREE</span>
            </div>
          </div>
          
          {/* Optional Premium */}
          <div className="space-y-3">
            <p className="text-xs font-semibold text-slate-500 uppercase tracking-wider mb-2">Optional Premium</p>
            
            <div className="flex items-center justify-between p-3 bg-slate-900 rounded-lg border border-amber-500/30 opacity-70">
              <div className="flex items-center gap-2">
                <span className="text-amber-400">●</span>
                <div>
                  <span className="text-white font-medium">GPT-4o</span>
                  <p className="text-xs text-slate-500">Visual design review</p>
                </div>
              </div>
              <span className="text-xs text-amber-400">PAID</span>
            </div>
          </div>
        </div>
        
        <div className="mt-6 pt-4 border-t border-slate-800">
          <div className="grid md:grid-cols-2 gap-4 text-xs text-slate-500">
            <div>
              <p className="font-semibold text-slate-400 mb-1">Team Distribution:</p>
              <ul className="space-y-1">
                <li>• Luna, Researcher, Developer, PM → Kimi for Coding</li>
                <li>• SDR, Designer → Kimi K2.5</li>
              </ul>
            </div>
            <div>
              <p className="font-semibold text-slate-400 mb-1">Why These Models:</p>
              <ul className="space-y-1">
                <li>• K2.5 = Best for reasoning, planning, coding</li>
                <li>• K2.5 = Best for creativity, communication</li>
              </ul>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}

export default Team
