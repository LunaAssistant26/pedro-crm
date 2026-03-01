import { useState } from 'react'
import { 
  Building2, 
  Users, 
  Handshake, 
  TrendingUp, 
  Clock, 
  DollarSign,
  Globe,
  CreditCard,
  Mail,
  CheckCircle2
} from 'lucide-react'
import { partners, deals, clients } from '../data/crmData'

const statusColors = {
  'Lead': 'badge-warning',
  'In Discussion': 'badge-info',
  'Proposal Sent': 'badge-info',
  'Contracting': 'badge-warning',
  'Live': 'badge-success',
  'Closed-Lost': 'badge-danger',
  'Active': 'badge-success',
  'On Hold': 'badge-warning',
  'Dormant': 'badge-danger'
}

function CRM() {
  const [activeSubTab, setActiveSubTab] = useState('partners')

  return (
    <div className="space-y-6">
      {/* Stats Overview */}
      <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
        <div className="card p-4">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-slate-400">Active Partners</p>
              <p className="text-2xl font-bold text-white">{partners.filter(p => p.status === 'Active').length}</p>
            </div>
            <div className="bg-indigo-500/20 p-3 rounded-lg">
              <Handshake className="w-5 h-5 text-indigo-400" />
            </div>
          </div>
        </div>

        <div className="card p-4">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-slate-400">Active Deals</p>
              <p className="text-2xl font-bold text-white">{deals.filter(d => d.status !== 'Closed-Lost').length}</p>
            </div>
            <div className="bg-emerald-500/20 p-3 rounded-lg">
              <TrendingUp className="w-5 h-5 text-emerald-400" />
            </div>
          </div>
        </div>

        <div className="card p-4">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-slate-400">Live Clients</p>
              <p className="text-2xl font-bold text-white">{deals.filter(d => d.status === 'Live').length}</p>
            </div>
            <div className="bg-amber-500/20 p-3 rounded-lg">
              <CheckCircle2 className="w-5 h-5 text-amber-400" />
            </div>
          </div>
        </div>

        <div className="card p-4">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-slate-400">Est. Monthly Revenue</p>
              <p className="text-2xl font-bold text-white">€{deals.reduce((acc, d) => acc + (d.monthlyRevenue || 0), 0).toLocaleString()}</p>
            </div>
            <div className="bg-purple-500/20 p-3 rounded-lg">
              <DollarSign className="w-5 h-5 text-purple-400" />
            </div>
          </div>
        </div>
      </div>

      {/* Sub Tabs */}
      <div className="flex gap-2 border-b border-slate-800 pb-4">
        {['partners', 'deals', 'clients'].map((tab) => (
          <button
            key={tab}
            onClick={() => setActiveSubTab(tab)}
            className={`px-4 py-2 rounded-lg text-sm font-medium capitalize transition-all ${
              activeSubTab === tab
                ? 'bg-slate-800 text-white'
                : 'text-slate-400 hover:text-white'
            }`}
          >
            {tab}
          </button>
        ))}
      </div>

      {/* Content */}
      <div className="space-y-4">
        {activeSubTab === 'partners' && <PartnersView />}
        {activeSubTab === 'deals' && <DealsView />}
        {activeSubTab === 'clients' && <ClientsView />}
      </div>
    </div>
  )
}

function PartnersView() {
  return (
    <div className="grid gap-4">
      {partners.map((partner) => (
        <div key={partner.id} className="card p-6">
          <div className="flex flex-col md:flex-row md:items-start justify-between gap-4">
            <div className="flex-1">
              <div className="flex items-center gap-3 mb-3">
                <h3 className="text-xl font-semibold text-white">{partner.name}</h3>
                <span className={`badge ${statusColors[partner.status]}`}>
                  {partner.status}
                </span>
                <span className="badge badge-info">{partner.type}</span>
              </div>
              
              <div className="grid md:grid-cols-2 gap-4 text-sm">
                <div className="space-y-2">
                  <div className="flex items-center gap-2 text-slate-400">
                    <Users className="w-4 h-4" />
                    <span>Contact: <span className="text-white">{partner.contact}</span></span>
                  </div>
                  <div className="flex items-center gap-2 text-slate-400">
                    <Globe className="w-4 h-4" />
                    <span>Regions: <span className="text-white">{partner.regions.join(', ')}</span></span>
                  </div>
                  <div className="flex items-center gap-2 text-slate-400">
                    <CreditCard className="w-4 h-4" />
                    <span>Methods: <span className="text-white">{partner.paymentMethods.join(', ')}</span></span>
                  </div>
                </div>
                
                <div className="space-y-2">
                  <div className="flex items-center gap-2 text-slate-400">
                    <Clock className="w-4 h-4" />
                    <span>Settlement: <span className="text-white">{partner.settlementTimeframe}</span></span>
                  </div>
                  <div className="flex items-center gap-2 text-slate-400">
                    <DollarSign className="w-4 h-4" />
                    <span>Revenue Share: <span className="text-emerald-400 font-medium">{partner.commissionShare}</span></span>
                  </div>
                  <div className="flex items-center gap-2 text-slate-400">
                    <Building2 className="w-4 h-4" />
                    <span>Active Clients: <span className="text-white font-medium">{partner.activeClients}</span></span>
                  </div>
                </div>
              </div>

              <div className="mt-4 pt-4 border-t border-slate-700">
                <p className="text-sm text-slate-400 mb-2">Industries:</p>
                <div className="flex flex-wrap gap-2">
                  {partner.industries.map((industry) => (
                    <span key={industry} className="badge badge-info">
                      {industry}
                    </span>
                  ))}
                </div>
              </div>
            </div>
          </div>
        </div>
      ))}
    </div>
  )
}

function DealsView() {
  return (
    <div className="grid gap-4">
      {deals.length === 0 ? (
        <div className="card p-8 text-center">
          <p className="text-slate-400">No deals yet. Add your first deal to get started.</p>
        </div>
      ) : (
        deals.map((deal) => (
          <div key={deal.id} className="card p-6">
            <div className="flex flex-col md:flex-row md:items-start justify-between gap-4">
              <div className="flex-1">
                <div className="flex items-center gap-3 mb-2">
                  <h3 className="text-lg font-semibold text-white">{deal.name}</h3>
                  <span className={`badge ${statusColors[deal.status]}`}>
                    {deal.status}
                  </span>
                </div>
                
                <p className="text-slate-400 text-sm mb-3">{deal.industry}</p>
                
                <div className="grid md:grid-cols-3 gap-4 text-sm">
                  <div>
                    <p className="text-slate-500">Monthly Volume</p>
                    <p className="text-white font-medium">€{deal.monthlyVolume?.toLocaleString() || 'TBD'}</p>
                  </div>
                  <div>
                    <p className="text-slate-500">Est. Revenue</p>
                    <p className="text-emerald-400 font-medium">€{deal.monthlyRevenue?.toLocaleString() || 'TBD'}/mo</p>
                  </div>
                  <div>
                    <p className="text-slate-500">Priority</p>
                    <p className={`font-medium ${
                      deal.priority === 'High' ? 'text-red-400' : 
                      deal.priority === 'Medium' ? 'text-amber-400' : 'text-slate-300'
                    }`}>
                      {deal.priority}
                    </p>
                  </div>
                </div>

                {deal.nextAction && (
                  <div className="mt-4 pt-4 border-t border-slate-700">
                    <p className="text-sm text-slate-400">
                      <span className="text-indigo-400">Next Action:</span> {deal.nextAction}
                    </p>
                  </div>
                )}
              </div>
            </div>
          </div>
        ))
      )}
    </div>
  )
}

function ClientsView() {
  return (
    <div className="grid gap-4">
      {clients.length === 0 ? (
        <div className="card p-8 text-center">
          <p className="text-slate-400">No clients added yet.</p>
        </div>
      ) : (
        <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-4">
          {clients.map((client) => (
            <div key={client.id} className="card p-4">
              <div className="flex items-center gap-3 mb-3">
                <div className="bg-indigo-500/20 p-2 rounded-lg">
                  <Building2 className="w-5 h-5 text-indigo-400" />
                </div>
                <div>
                  <h3 className="font-semibold text-white">{client.name}</h3>
                  <span className="badge badge-success text-xs">{client.status}</span>
                </div>
              </div>
              
              <p className="text-sm text-slate-400 mb-2">{client.industry}</p>
              
              {client.description && (
                <p className="text-xs text-slate-500 mb-3 italic">{client.description}</p>
              )}
              
              <div className="space-y-2 text-xs text-slate-500">
                {client.partner && (
                  <div className="flex items-center gap-2">
                    <Handshake className="w-3 h-3" />
                    Partner: <span className="text-indigo-400">{client.partner}</span>
                  </div>
                )}
                
                {client.geo && (
                  <div className="flex items-center gap-2">
                    <Globe className="w-3 h-3" />
                    Region: {client.geo}
                  </div>
                )}
                
                {client.contact && (
                  <div className="flex items-center gap-2">
                    <Mail className="w-3 h-3" />
                    {client.contact}
                  </div>
                )}
              </div>
              
              {client.notes && (
                <div className="mt-3 pt-3 border-t border-slate-700">
                  <p className="text-xs text-slate-600">{client.notes}</p>
                </div>
              )}
            </div>
          ))}
        </div>
      )}
    </div>
  )
}

export default CRM
