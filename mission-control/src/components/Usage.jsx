import { useState, useEffect } from 'react'
import { 
  Cpu, 
  TrendingUp, 
  AlertCircle, 
  CheckCircle2, 
  Zap,
  DollarSign,
  Activity,
  BarChart3
} from 'lucide-react'

// Model usage data - in production this could be fetched from APIs or stored in localStorage
const initialModelUsage = {
  'kimi-coding/k2p5': {
    name: 'Kimi for Coding',
    provider: 'kimi-coding',
    alias: 'Kimi for Coding',
    used: 0,
    limit: null, // Unlimited or unknown
    costPer1M: { input: 0, output: 0 }, // Free tier
    dailyRequests: 0,
    status: 'active',
    color: 'indigo'
  },
  'moonshot/kimi-k2.5': {
    name: 'Kimi K2.5',
    provider: 'moonshot',
    alias: 'Kimi K2.5',
    used: 0,
    limit: null,
    costPer1M: { input: 0, output: 0 }, // Free tier
    dailyRequests: 0,
    status: 'active',
    color: 'purple'
  },
  'ollama/llama3.1:8b': {
    name: 'Llama 3.1 8B',
    provider: 'ollama',
    alias: 'Local Model',
    used: 0,
    limit: null,
    costPer1M: { input: 0, output: 0 }, // Local = free
    dailyRequests: 0,
    status: 'active',
    color: 'emerald'
  }
}

const colorClasses = {
  indigo: {
    bg: 'bg-indigo-500/20',
    text: 'text-indigo-400',
    border: 'border-indigo-500/30',
    bar: 'bg-indigo-500'
  },
  purple: {
    bg: 'bg-purple-500/20',
    text: 'text-purple-400',
    border: 'border-purple-500/30',
    bar: 'bg-purple-500'
  },
  emerald: {
    bg: 'bg-emerald-500/20',
    text: 'text-emerald-400',
    border: 'border-emerald-500/30',
    bar: 'bg-emerald-500'
  },
  amber: {
    bg: 'bg-amber-500/20',
    text: 'text-amber-400',
    border: 'border-amber-500/30',
    bar: 'bg-amber-500'
  },
  blue: {
    bg: 'bg-blue-500/20',
    text: 'text-blue-400',
    border: 'border-blue-500/30',
    bar: 'bg-blue-500'
  }
}

function Usage() {
  const [modelUsage, setModelUsage] = useState(initialModelUsage)
  const [lastUpdated, setLastUpdated] = useState(new Date().toISOString())
  const [showAllModels, setShowAllModels] = useState(false)

  // Load from localStorage on mount
  useEffect(() => {
    const saved = localStorage.getItem('missionControl_modelUsage')
    if (saved) {
      try {
        const parsed = JSON.parse(saved)
        setModelUsage(parsed.data)
        setLastUpdated(parsed.lastUpdated)
      } catch (e) {
        console.error('Failed to load usage data:', e)
      }
    }
  }, [])

  // Calculate totals
  const totalRequests = Object.values(modelUsage).reduce((acc, model) => acc + (model.dailyRequests || 0), 0)
  const activeModels = Object.values(modelUsage).filter(m => m.status === 'active').length
  const freeModels = Object.values(modelUsage).filter(m => m.costPer1M.input === 0 && m.costPer1M.output === 0).length

  // Future models that might be added
  const futureModels = [
    { id: 'gpt-4o', name: 'GPT-4o', provider: 'OpenAI', status: 'planned', color: 'amber' },
    { id: 'claude-3-5', name: 'Claude 3.5 Sonnet', provider: 'Anthropic', status: 'planned', color: 'amber' },
    { id: 'perplexity-sonar', name: 'Perplexity Sonar', provider: 'Perplexity', status: 'planned', color: 'blue' }
  ]

  const handleManualUpdate = (modelId, field, value) => {
    const updated = {
      ...modelUsage,
      [modelId]: {
        ...modelUsage[modelId],
        [field]: parseInt(value) || 0
      }
    }
    setModelUsage(updated)
    localStorage.setItem('missionControl_modelUsage', JSON.stringify({
      data: updated,
      lastUpdated: new Date().toISOString()
    }))
    setLastUpdated(new Date().toISOString())
  }

  const getUsagePercentage = (model) => {
    if (!model.limit || model.limit === null) return null
    return Math.min((model.used / model.limit) * 100, 100)
  }

  const getUsageColor = (percentage) => {
    if (percentage === null) return 'emerald'
    if (percentage >= 90) return 'red'
    if (percentage >= 75) return 'amber'
    return 'emerald'
  }

  return (
    <div className="space-y-6">
      {/* Overview Cards */}
      <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
        <div className="card p-4">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-slate-400">Active Models</p>
              <p className="text-2xl font-bold text-white">{activeModels}</p>
            </div>
            <div className="bg-indigo-500/20 p-3 rounded-lg">
              <Cpu className="w-5 h-5 text-indigo-400" />
            </div>
          </div>
        </div>

        <div className="card p-4">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-slate-400">Today's Requests</p>
              <p className="text-2xl font-bold text-white">{totalRequests}</p>
            </div>
            <div className="bg-emerald-500/20 p-3 rounded-lg">
              <Activity className="w-5 h-5 text-emerald-400" />
            </div>
          </div>
        </div>

        <div className="card p-4">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-slate-400">Free Models</p>
              <p className="text-2xl font-bold text-white">{freeModels}</p>
            </div>
            <div className="bg-purple-500/20 p-3 rounded-lg">
              <DollarSign className="w-5 h-5 text-purple-400" />
            </div>
          </div>
        </div>

        <div className="card p-4">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-slate-400">Status</p>
              <p className="text-lg font-bold text-emerald-400 flex items-center gap-1">
                <CheckCircle2 className="w-4 h-4" />
                All Good
              </p>
            </div>
            <div className="bg-emerald-500/20 p-3 rounded-lg">
              <Zap className="w-5 h-5 text-emerald-400" />
            </div>
          </div>
        </div>
      </div>

      {/* Active Models */}
      <div>
        <h3 className="text-lg font-semibold text-white mb-4 flex items-center gap-2">
          <BarChart3 className="w-5 h-5 text-indigo-400" />
          Model Usage
        </h3>

        <div className="grid gap-4">
          {Object.entries(modelUsage).map(([modelId, model]) => {
            const colors = colorClasses[model.color]
            const usagePercent = getUsagePercentage(model)
            const usageColor = getUsageColor(usagePercent)

            return (
              <div key={modelId} className={`card p-6 border-l-4 ${colors.border}`}>
                <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
                  {/* Model Info */}
                  <div className="flex items-center gap-4">
                    <div className={`p-3 rounded-xl ${colors.bg}`}>
                      <Cpu className={`w-6 h-6 ${colors.text}`} />
                    </div>
                    <div>
                      <h4 className="font-semibold text-white">{model.name}</h4>
                      <p className="text-sm text-slate-400">{model.provider}</p>
                    </div>
                  </div>

                  {/* Usage Stats */}
                  <div className="flex items-center gap-6">
                    {/* Requests */}
                    <div className="text-center">
                      <p className="text-xs text-slate-500 mb-1">Today's Requests</p>
                      <input
                        type="number"
                        value={model.dailyRequests}
                        onChange={(e) => handleManualUpdate(modelId, 'dailyRequests', e.target.value)}
                        className="w-20 bg-slate-900 border border-slate-700 rounded px-2 py-1 text-white text-center text-sm focus:outline-none focus:border-indigo-500"
                      />
                    </div>

                    {/* Cost */}
                    <div className="text-center">
                      <p className="text-xs text-slate-500 mb-1">Cost per 1M</p>
                      <p className="text-sm text-white">
                        ${model.costPer1M.input + model.costPer1M.output > 0 
                          ? `$${model.costPer1M.input + model.costPer1M.output}` 
                          : 'Free'}
                      </p>
                    </div>

                    {/* Status */}
                    <div className="flex items-center gap-2">
                      {model.status === 'active' ? (
                        <span className="flex items-center gap-1 text-xs text-emerald-400">
                          <CheckCircle2 className="w-3 h-3" />
                          Active
                        </span>
                      ) : (
                        <span className="flex items-center gap-1 text-xs text-amber-400">
                          <AlertCircle className="w-3 h-3" />
                          Limited
                        </span>
                      )}
                    </div>
                  </div>
                </div>

                {/* Usage Bar (if limit is known) */}
                {model.limit && (
                  <div className="mt-4">
                    <div className="flex justify-between text-xs mb-1">
                      <span className="text-slate-400">Usage</span>
                      <span className={`font-medium ${
                        usageColor === 'red' ? 'text-red-400' :
                        usageColor === 'amber' ? 'text-amber-400' :
                        'text-emerald-400'
                      }`}>
                        {model.used.toLocaleString()} / {model.limit.toLocaleString()} 
                        ({usagePercent.toFixed(1)}%)
                      </span>
                    </div>
                    <div className="h-2 bg-slate-800 rounded-full overflow-hidden">
                      <div 
                        className={`h-full transition-all ${
                          usageColor === 'red' ? 'bg-red-500' :
                          usageColor === 'amber' ? 'bg-amber-500' :
                          colors.bar
                        }`}
                        style={{ width: `${usagePercent}%` }}
                      />
                    </div>
                  </div>
                )}

                {/* No limit indicator */}
                {!model.limit && (
                  <div className="mt-4 flex items-center gap-2 text-xs text-slate-500">
                    <CheckCircle2 className="w-3 h-3 text-emerald-400" />
                    No usage limits configured (free tier or unlimited)
                  </div>
                )}
              </div>
            )
          })}
        </div>
      </div>

      {/* Future Models */}
      <div>
        <button
          onClick={() => setShowAllModels(!showAllModels)}
          className="text-sm text-slate-400 hover:text-white flex items-center gap-2 mb-4"
        >
          {showAllModels ? 'Hide' : 'Show'} Future Models
        </button>

        {showAllModels && (
          <div className="grid md:grid-cols-3 gap-4">
            {futureModels.map((model) => {
              const colors = colorClasses[model.color]
              return (
                <div key={model.id} className={`card p-4 opacity-60`}>
                  <div className="flex items-center gap-3">
                    <div className={`p-2 rounded-lg ${colors.bg}`}>
                      <Cpu className={`w-4 h-4 ${colors.text}`} />
                    </div>
                    <div>
                      <h4 className="font-medium text-white text-sm">{model.name}</h4>
                      <p className="text-xs text-slate-400">{model.provider}</p>
                    </div>
                  </div>
                  <div className="mt-3">
                    <span className="text-xs text-amber-400">Planned</span>
                  </div>
                </div>
              )
            })}
          </div>
        )}
      </div>

      {/* Notes */}
      <div className="card p-4">
        <div className="flex items-start gap-3">
          <AlertCircle className="w-5 h-5 text-amber-400 flex-shrink-0 mt-0.5" />
          <div className="text-sm text-slate-400">
            <p className="mb-2">
              <strong className="text-white">Usage Tracking:</strong> Currently using free/open-source models. 
              You can manually update request counts to track usage.
            </p>
            <p>
              Last updated: {new Date(lastUpdated).toLocaleString()}
            </p>
          </div>
        </div>
      </div>
    </div>
  )
}

export default Usage
