import { useState, useEffect } from 'react'
import { 
  Lightbulb, 
  Clock, 
  CheckCircle2, 
  XCircle, 
  Rocket,
  User,
  Calendar,
  MoreHorizontal,
  Plus,
  Search,
  Filter,
  FileText,
  RefreshCw
} from 'lucide-react'
import { format } from 'date-fns'
import researchIndex from '../data/researchIndex.json'

// Kanban columns/stages
const stages = [
  { 
    id: 'submitted', 
    title: 'Submitted', 
    color: 'slate',
    description: 'New ideas from Researcher'
  },
  { 
    id: 'under-review', 
    title: 'Under Review', 
    color: 'amber',
    description: 'Luna & PM evaluating'
  },
  { 
    id: 'pending-approval', 
    title: 'Pending Approval', 
    color: 'orange',
    description: 'Waiting for Pedro\'s decision',
    needsApproval: true
  },
  { 
    id: 'approved', 
    title: 'Approved', 
    color: 'emerald',
    description: 'Ready to build!'
  },
  { 
    id: 'in-progress', 
    title: 'In Progress', 
    color: 'indigo',
    description: 'Team is building it'
  },
  { 
    id: 'completed', 
    title: 'Completed', 
    color: 'purple',
    description: 'Launched!'
  },
  { 
    id: 'rejected', 
    title: 'Rejected', 
    color: 'red',
    description: 'Not pursuing'
  }
]

// Convert research index ideas to component format
const convertResearchIdeas = () => {
  return researchIndex.businessIdeas.map(idea => ({
    id: idea.id,
    title: idea.title,
    description: idea.content.slice(0, 200) + (idea.content.length > 200 ? '...' : ''),
    fullDescription: idea.content,
    submittedBy: idea.submittedBy || 'Researcher',
    submittedAt: idea.date || idea.createdAt,
    stage: idea.stage || 'submitted',
    tags: idea.tags || [],
    estimatedMarket: idea.estimatedMarket || '',
    effort: idea.effort || 'Medium',
    notes: `From research file: ${idea.filename}`,
    source: 'research'
  }))
}
  {
    id: 1,
    title: 'AI-powered market research tool for high-risk merchants',
    description: 'Automated research platform that identifies and qualifies gambling/FX/adult merchants looking for payment solutions. Scrapes public data, scores leads.',
    submittedBy: 'Researcher',
    submittedAt: '2026-02-28',
    stage: 'submitted',
    tags: ['AI', 'B2B', 'Payments'],
    estimatedMarket: '€50K-100K/month potential',
    effort: 'Medium',
    notes: 'Aligns well with Pedro\'s existing payments business'
  },
  {
    id: 2,
    title: 'Subscription management app for micro-SaaS founders',
    description: 'Simple tool for indie hackers to manage Stripe subscriptions, send dunning emails, track MRR. Like Baremetrics but for tiny startups.',
    submittedBy: 'Researcher',
    submittedAt: '2026-02-28',
    stage: 'under-review',
    tags: ['SaaS', 'Finance', 'Micro-SaaS'],
    estimatedMarket: '€20K-50K/month potential',
    effort: 'Low',
    notes: 'Could be a quick win, similar to Tara concept'
  }
]

const initialIdeas = []

const colorClasses = {
  slate: { bg: 'bg-slate-800', border: 'border-slate-700', text: 'text-slate-400' },
  amber: { bg: 'bg-amber-500/20', border: 'border-amber-500/30', text: 'text-amber-400' },
  orange: { bg: 'bg-orange-500/20', border: 'border-orange-500/30', text: 'text-orange-400' },
  emerald: { bg: 'bg-emerald-500/20', border: 'border-emerald-500/30', text: 'text-emerald-400' },
  indigo: { bg: 'bg-indigo-500/20', border: 'border-indigo-500/30', text: 'text-indigo-400' },
  purple: { bg: 'bg-purple-500/20', border: 'border-purple-500/30', text: 'text-purple-400' },
  red: { bg: 'bg-red-500/20', border: 'border-red-500/30', text: 'text-red-400' },
  cyan: { bg: 'bg-cyan-500/20', border: 'border-cyan-500/30', text: 'text-cyan-400' }
}

function Ideas() {
  const [ideas, setIdeas] = useState([])
  const [searchQuery, setSearchQuery] = useState('')
  const [filterBy, setFilterBy] = useState('all')
  const [selectedIdea, setSelectedIdea] = useState(null)
  const [showAddModal, setShowAddModal] = useState(false)
  const [lastUpdated, setLastUpdated] = useState(researchIndex.lastUpdated)
  const [newIdea, setNewIdea] = useState({
    title: '',
    description: '',
    tags: '',
    estimatedMarket: '',
    effort: 'Medium'
  })

  // Load from localStorage and research index
  useEffect(() => {
    const saved = localStorage.getItem('missionControl_ideas')
    const researchIdeas = convertResearchIdeas()
    
    if (saved) {
      try {
        const localIdeas = JSON.parse(saved)
        // Merge local ideas with research ideas (avoid duplicates by ID)
        const researchIds = new Set(researchIdeas.map(i => i.id))
        const uniqueLocalIdeas = localIdeas.filter(i => !researchIds.has(i.id) && i.source !== 'research')
        setIdeas([...researchIdeas, ...uniqueLocalIdeas])
      } catch (e) {
        console.error('Failed to load ideas:', e)
        setIdeas(researchIdeas)
      }
    } else {
      setIdeas(researchIdeas)
    }
    setLastUpdated(researchIndex.lastUpdated)
  }, [])

  // Save to localStorage
  const saveIdeas = (updatedIdeas) => {
    setIdeas(updatedIdeas)
    localStorage.setItem('missionControl_ideas', JSON.stringify(updatedIdeas))
  }

  // Move idea to next stage
  const moveIdea = (ideaId, newStage) => {
    const updated = ideas.map(idea => 
      idea.id === ideaId ? { ...idea, stage: newStage } : idea
    )
    saveIdeas(updated)
  }

  // Add new idea
  const handleAddIdea = () => {
    if (!newIdea.title.trim()) return
    
    const idea = {
      id: Date.now(),
      ...newIdea,
      tags: newIdea.tags.split(',').map(t => t.trim()).filter(Boolean),
      submittedBy: 'Pedro', // or whoever is adding it
      submittedAt: format(new Date(), 'yyyy-MM-dd'),
      stage: 'submitted'
    }
    
    saveIdeas([...ideas, idea])
    setNewIdea({ title: '', description: '', tags: '', estimatedMarket: '', effort: 'Medium' })
    setShowAddModal(false)
  }

  // Filter ideas
  const filteredIdeas = ideas.filter(idea => {
    const matchesSearch = idea.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
                         idea.description.toLowerCase().includes(searchQuery.toLowerCase())
    const matchesFilter = filterBy === 'all' || 
                         (filterBy === 'needs-approval' && idea.stage === 'pending-approval') ||
                         (filterBy === 'my-ideas' && idea.submittedBy === 'Pedro')
    return matchesSearch && matchesFilter
  })

  // Group by stage
  const ideasByStage = stages.reduce((acc, stage) => {
    acc[stage.id] = filteredIdeas.filter(idea => idea.stage === stage.id)
    return acc
  }, {})

  const getNextStages = (currentStage) => {
    const stageIndex = stages.findIndex(s => s.id === currentStage)
    if (stageIndex === -1) return []
    
    // Can move forward, backward, or to rejected
    const nextStages = []
    if (stageIndex < stages.length - 2) { // -2 to exclude rejected from normal flow
      nextStages.push(stages[stageIndex + 1])
    }
    if (stageIndex > 0) {
      nextStages.push(stages[stageIndex - 1])
    }
    nextStages.push(stages.find(s => s.id === 'rejected'))
    
    return nextStages
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h2 className="text-xl font-semibold text-white flex items-center gap-2">
            <Lightbulb className="w-6 h-6 text-amber-400" />
            Idea Pipeline
          </h2>
          <p className="text-slate-400 text-sm">
            Track business opportunities from research to launch
            {ideas.filter(i => i.source === 'research').length > 0 && (
              <span className="ml-2 text-emerald-400">
                • {ideas.filter(i => i.source === 'research').length} from Researcher
              </span>
            )}
          </p>
        </div>

        <div className="flex items-center gap-3">
          {/* Research Status */}
          <div className="hidden md:flex items-center gap-2 text-xs text-slate-500 bg-slate-800 px-3 py-2 rounded-lg">
            <FileText className="w-3 h-3" />
            <span>Last updated: {format(new Date(lastUpdated), 'MMM d, HH:mm')}</span>
          </div>

          {/* Search */}
          <div className="relative">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-500" />
            <input
              type="text"
              placeholder="Search ideas..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="bg-slate-800 border border-slate-700 rounded-lg pl-9 pr-4 py-2 text-sm text-white placeholder-slate-500 focus:outline-none focus:border-indigo-500"
            />
          </div>

          {/* Filter */}
          <select
            value={filterBy}
            onChange={(e) => setFilterBy(e.target.value)}
            className="bg-slate-800 border border-slate-700 rounded-lg px-3 py-2 text-sm text-white focus:outline-none focus:border-indigo-500"
          >
            <option value="all">All Ideas</option>
            <option value="needs-approval">Needs Your Approval</option>
            <option value="my-ideas">Your Ideas</option>
          </select>

          {/* Add Button */}
          <button
            onClick={() => setShowAddModal(true)}
            className="flex items-center gap-2 bg-indigo-600 hover:bg-indigo-700 text-white px-4 py-2 rounded-lg text-sm font-medium transition-colors"
          >
            <Plus className="w-4 h-4" />
            Add Idea
          </button>
        </div>
      </div>

      {/* Kanban Board */}
      <div className="overflow-x-auto pb-4">
        <div className="flex gap-4 min-w-max">
          {stages.filter(s => s.id !== 'rejected').map((stage) => {
            const stageIdeas = ideasByStage[stage.id] || []
            const colors = colorClasses[stage.color]
            
            return (
              <div key={stage.id} className="w-80 flex-shrink-0">
                {/* Column Header */}
                <div className={`${colors.bg} ${colors.border} border rounded-t-lg p-3`}>
                  <div className="flex items-center justify-between">
                    <h3 className={`font-semibold ${colors.text}`}>{stage.title}</h3>
                    <span className="bg-slate-900 text-slate-400 text-xs px-2 py-1 rounded-full">
                      {stageIdeas.length}
                    </span>
                  </div>
                  <p className="text-xs text-slate-500 mt-1">{stage.description}</p>
                  
                  {stage.needsApproval && (
                    <div className="flex items-center gap-1 mt-2 text-xs text-orange-400">
                      <Clock className="w-3 h-3" />
                      Needs Pedro's approval
                    </div>
                  )}
                </div>

                {/* Cards */}
                <div className="bg-slate-900/50 border-x border-b border-slate-800 rounded-b-lg p-3 space-y-3 min-h-[200px]">
                  {stageIdeas.map((idea) => (
                    <div
                      key={idea.id}
                      onClick={() => setSelectedIdea(idea)}
                      className="card p-4 cursor-pointer hover:border-indigo-500/50 transition-all group"
                    >
                      <div className="flex items-start justify-between mb-2">
                        <h4 className="font-medium text-white text-sm line-clamp-2 group-hover:text-indigo-400 transition-colors">
                          {idea.title}
                        </h4>
                        <MoreHorizontal className="w-4 h-4 text-slate-600" />
                      </div>
                      
                      <p className="text-xs text-slate-400 line-clamp-2 mb-3">
                        {idea.description}
                      </p>
                      
                      <div className="flex items-center gap-2 text-xs text-slate-500 mb-3">
                        <User className="w-3 h-3" />
                        {idea.submittedBy}
                        <span className="mx-1">•</span>
                        <Calendar className="w-3 h-3" />
                        {idea.submittedAt}
                      </div>
                      
                      {idea.tags.length > 0 && (
                        <div className="flex flex-wrap gap-1">
                          {idea.tags.slice(0, 2).map((tag) => (
                            <span key={tag} className="text-xs bg-slate-800 text-slate-400 px-2 py-0.5 rounded">
                              {tag}
                            </span>
                          ))}
                          {idea.tags.length > 2 && (
                            <span className="text-xs text-slate-500">+{idea.tags.length - 2}</span>
                          )}
                        </div>
                      )}
                    </div>
                  ))}
                  
                  {stageIdeas.length === 0 && (
                    <div className="text-center py-8 text-slate-600 text-sm">
                      No ideas here
                    </div>
                  )}
                </div>
              </div>
            )
          })}
        </div>
      </div>

      {/* Rejected Ideas (Collapsed) */}
      <div className="card p-4">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-2">
            <XCircle className="w-5 h-5 text-red-400" />
            <h3 className="font-semibold text-white">Rejected Ideas</h3>
            <span className="bg-slate-800 text-slate-400 text-xs px-2 py-1 rounded-full">
              {(ideasByStage['rejected'] || []).length}
            </span>
          </div>
        </div>
        
        <div className="mt-4 grid md:grid-cols-2 lg:grid-cols-3 gap-4">
          {(ideasByStage['rejected'] || []).map((idea) => (
            <div key={idea.id} className="card p-4 opacity-60">
              <h4 className="font-medium text-slate-400 text-sm line-through">{idea.title}</h4>
              <p className="text-xs text-slate-600 mt-1">Rejected on {idea.submittedAt}</p>
            </div>
          ))}
        </div>
      </div>

      {/* Idea Detail Modal */}
      {selectedIdea && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
          <div className="card w-full max-w-2xl max-h-[90vh] overflow-y-auto">
            <div className="p-6">
              <div className="flex items-start justify-between mb-4">
                <div>
                  <div className="flex items-center gap-2 mb-2">
                    <Lightbulb className="w-5 h-5 text-amber-400" />
                    <h2 className="text-xl font-bold text-white">{selectedIdea.title}</h2>
                  </div>
                  
                  <div className="flex items-center gap-3 text-sm text-slate-400">
                    <span className="flex items-center gap-1">
                      <User className="w-4 h-4" />
                      {selectedIdea.submittedBy}
                    </span>
                    <span className="flex items-center gap-1">
                      <Calendar className="w-4 h-4" />
                      {selectedIdea.submittedAt}
                    </span>
                  </div>
                </div>
                
                <button
                  onClick={() => setSelectedIdea(null)}
                  className="text-slate-500 hover:text-white"
                >
                  <XCircle className="w-6 h-6" />
                </button>
              </div>

              <div className="space-y-4">
                <div>
                  <h3 className="text-sm font-semibold text-slate-300 mb-2">Description</h3>
                  <p className="text-slate-400">{selectedIdea.description}</p>
                </div>

                <div className="grid md:grid-cols-2 gap-4">
                  {selectedIdea.estimatedMarket && (
                    <div>
                      <h3 className="text-sm font-semibold text-slate-300 mb-1">Estimated Market</h3>
                      <p className="text-emerald-400">{selectedIdea.estimatedMarket}</p>
                    </div>
                  )}
                  
                  {selectedIdea.effort && (
                    <div>
                      <h3 className="text-sm font-semibold text-slate-300 mb-1">Effort Level</h3>
                      <p className="text-slate-400">{selectedIdea.effort}</p>
                    </div>
                  )}
                </div>

                {selectedIdea.notes && (
                  <div className="bg-slate-900 p-4 rounded-lg">
                    <h3 className="text-sm font-semibold text-slate-300 mb-2">Notes</h3>
                    <p className="text-slate-400 text-sm">{selectedIdea.notes}</p>
                  </div>
                )}

                {selectedIdea.tags.length > 0 && (
                  <div>
                    <h3 className="text-sm font-semibold text-slate-300 mb-2">Tags</h3>
                    <div className="flex flex-wrap gap-2">
                      {selectedIdea.tags.map((tag) => (
                        <span key={tag} className="text-sm bg-slate-800 text-slate-400 px-3 py-1 rounded-full">
                          {tag}
                        </span>
                      ))}
                    </div>
                  </div>
                )}

                {/* Current Stage */}
                <div className="pt-4 border-t border-slate-700">
                  <h3 className="text-sm font-semibold text-slate-300 mb-3">Current Stage: {stages.find(s => s.id === selectedIdea.stage)?.title}</h3>
                  
                  <div className="flex flex-wrap gap-2">
                    {getNextStages(selectedIdea.stage).map((stage) => {
                      const stageColors = colorClasses[stage.color]
                      return (
                        <button
                          key={stage.id}
                          onClick={() => {
                            moveIdea(selectedIdea.id, stage.id)
                            setSelectedIdea({ ...selectedIdea, stage: stage.id })
                          }}
                          className={`px-4 py-2 rounded-lg text-sm font-medium transition-all ${stageColors.bg} ${stageColors.text} hover:opacity-80`}
                        >
                          {stage.id === 'rejected' ? 'Reject' : `Move to ${stage.title}`}
                        </button>
                      )
                    })}
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Add Idea Modal */}
      {showAddModal && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
          <div className="card w-full max-w-lg">
            <div className="p-6">
              <div className="flex items-center justify-between mb-4">
                <h2 className="text-xl font-bold text-white">Add New Idea</h2>
                <button
                  onClick={() => setShowAddModal(false)}
                  className="text-slate-500 hover:text-white"
                >
                  <XCircle className="w-6 h-6" />
                </button>
              </div>

              <div className="space-y-4">
                <div>
                  <label className="block text-sm font-medium text-slate-300 mb-1">Title</label>
                  <input
                    type="text"
                    value={newIdea.title}
                    onChange={(e) => setNewIdea({ ...newIdea, title: e.target.value })}
                    placeholder="What's the business idea?"
                    className="w-full bg-slate-900 border border-slate-700 rounded-lg px-4 py-2 text-white focus:outline-none focus:border-indigo-500"
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-slate-300 mb-1">Description</label>
                  <textarea
                    value={newIdea.description}
                    onChange={(e) => setNewIdea({ ...newIdea, description: e.target.value })}
                    placeholder="Describe the idea in detail..."
                    rows={3}
                    className="w-full bg-slate-900 border border-slate-700 rounded-lg px-4 py-2 text-white focus:outline-none focus:border-indigo-500"
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-slate-300 mb-1">Tags (comma separated)</label>
                  <input
                    type="text"
                    value={newIdea.tags}
                    onChange={(e) => setNewIdea({ ...newIdea, tags: e.target.value })}
                    placeholder="SaaS, AI, B2B..."
                    className="w-full bg-slate-900 border border-slate-700 rounded-lg px-4 py-2 text-white focus:outline-none focus:border-indigo-500"
                  />
                </div>

                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <label className="block text-sm font-medium text-slate-300 mb-1">Estimated Market</label>
                    <input
                      type="text"
                      value={newIdea.estimatedMarket}
                      onChange={(e) => setNewIdea({ ...newIdea, estimatedMarket: e.target.value })}
                      placeholder="€X/month"
                      className="w-full bg-slate-900 border border-slate-700 rounded-lg px-4 py-2 text-white focus:outline-none focus:border-indigo-500"
                    />
                  </div>

                  <div>
                    <label className="block text-sm font-medium text-slate-300 mb-1">Effort</label>
                    <select
                      value={newIdea.effort}
                      onChange={(e) => setNewIdea({ ...newIdea, effort: e.target.value })}
                      className="w-full bg-slate-900 border border-slate-700 rounded-lg px-4 py-2 text-white focus:outline-none focus:border-indigo-500"
                    >
                      <option>Low</option>
                      <option>Medium</option>
                      <option>High</option>
                    </select>
                  </div>
                </div>

                <button
                  onClick={handleAddIdea}
                  className="w-full bg-indigo-600 hover:bg-indigo-700 text-white py-3 rounded-lg font-medium transition-colors"
                >
                  Add Idea
                </button>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}

export default Ideas
