import { useState } from 'react'
import { 
  ChevronLeft, 
  ChevronRight, 
  Clock, 
  Bot,
  Repeat,
  AlertCircle
} from 'lucide-react'
import { format, startOfWeek, addDays, isSameDay } from 'date-fns'

// Initial calendar data - placeholder for future activities
const initialEvents = [
  {
    id: 'heartbeat',
    title: 'Heartbeat Check',
    description: 'Daily system check and proactive tasks',
    assignee: 'Luna',
    type: 'cron',
    schedule: 'Every 30 minutes',
    day: 0, // Monday
    time: '09:00',
    priority: 'high'
  },
  {
    id: 'crm-review',
    title: 'CRM Review',
    description: 'Review deals, partners, and follow-ups',
    assignee: 'Luna',
    type: 'daily',
    schedule: 'Daily',
    day: 0,
    time: '10:00',
    priority: 'medium'
  },
  {
    id: 'deal-followup',
    title: 'Deal Follow-ups',
    description: 'Check and remind on pending deal actions',
    assignee: 'Luna',
    type: 'daily',
    schedule: 'Daily',
    day: 1, // Tuesday
    time: '14:00',
    priority: 'high'
  },
  {
    id: 'memory-maintenance',
    title: 'Memory Maintenance',
    description: 'Review and compact daily memory files',
    assignee: 'Luna',
    type: 'weekly',
    schedule: 'Weekly',
    day: 4, // Friday
    time: '16:00',
    priority: 'low'
  },
  // Researcher's Daily Tasks
  {
    id: 'research-morning',
    title: 'Business Research #1',
    description: 'Research first business opportunity area - market analysis, competition, validation',
    assignee: 'Researcher',
    type: 'daily',
    schedule: 'Daily (Mon-Fri)',
    day: 0, // Monday
    time: '09:30',
    priority: 'high'
  },
  {
    id: 'research-afternoon',
    title: 'Business Research #2',
    description: 'Research second business opportunity area - market analysis, competition, validation',
    assignee: 'Researcher',
    type: 'daily',
    schedule: 'Daily (Mon-Fri)',
    day: 0, // Monday
    time: '14:00',
    priority: 'high'
  },
  {
    id: 'research-morning-tue',
    title: 'Business Research #1',
    description: 'Research first business opportunity area - market analysis, competition, validation',
    assignee: 'Researcher',
    type: 'daily',
    schedule: 'Daily (Mon-Fri)',
    day: 1, // Tuesday
    time: '09:30',
    priority: 'high'
  },
  {
    id: 'research-afternoon-tue',
    title: 'Business Research #2',
    description: 'Research second business opportunity area - market analysis, competition, validation',
    assignee: 'Researcher',
    type: 'daily',
    schedule: 'Daily (Mon-Fri)',
    day: 1, // Tuesday
    time: '14:00',
    priority: 'high'
  },
  {
    id: 'research-morning-wed',
    title: 'Business Research #1',
    description: 'Research first business opportunity area - market analysis, competition, validation',
    assignee: 'Researcher',
    type: 'daily',
    schedule: 'Daily (Mon-Fri)',
    day: 2, // Wednesday
    time: '09:30',
    priority: 'high'
  },
  {
    id: 'research-afternoon-wed',
    title: 'Business Research #2',
    description: 'Research second business opportunity area - market analysis, competition, validation',
    assignee: 'Researcher',
    type: 'daily',
    schedule: 'Daily (Mon-Fri)',
    day: 2, // Wednesday
    time: '14:00',
    priority: 'high'
  },
  {
    id: 'research-morning-thu',
    title: 'Business Research #1',
    description: 'Research first business opportunity area - market analysis, competition, validation',
    assignee: 'Researcher',
    type: 'daily',
    schedule: 'Daily (Mon-Fri)',
    day: 3, // Thursday
    time: '09:30',
    priority: 'high'
  },
  {
    id: 'research-afternoon-thu',
    title: 'Business Research #2',
    description: 'Research second business opportunity area - market analysis, competition, validation',
    assignee: 'Researcher',
    type: 'daily',
    schedule: 'Daily (Mon-Fri)',
    day: 3, // Thursday
    time: '14:00',
    priority: 'high'
  },
  {
    id: 'research-morning-fri',
    title: 'Business Research #1',
    description: 'Research first business opportunity area - market analysis, competition, validation',
    assignee: 'Researcher',
    type: 'daily',
    schedule: 'Daily (Mon-Fri)',
    day: 4, // Friday
    time: '09:30',
    priority: 'high'
  },
  {
    id: 'research-afternoon-fri',
    title: 'Business Research #2',
    description: 'Research second business opportunity area - market analysis, competition, validation',
    assignee: 'Researcher',
    type: 'daily',
    schedule: 'Daily (Mon-Fri)',
    day: 4, // Friday
    time: '14:00',
    priority: 'high'
  },
  // Weekly Review with PM and Luna
  {
    id: 'research-review',
    title: 'Research Review',
    description: 'Weekly review of researched opportunities with Luna and Program Manager to decide which to pursue',
    assignee: 'Researcher + Luna + PM',
    type: 'weekly',
    schedule: 'Weekly (Friday)',
    day: 4, // Friday
    time: '15:30',
    priority: 'medium'
  }
]

const weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']

function Calendar() {
  const [currentWeek, setCurrentWeek] = useState(new Date())
  const [events] = useState(initialEvents)
  const [selectedEvent, setSelectedEvent] = useState(null)

  const weekStart = startOfWeek(currentWeek, { weekStartsOn: 1 })
  const weekDaysFull = weekDays.map((day, idx) => addDays(weekStart, idx))

  const getEventsForDay = (dayIndex) => {
    return events.filter(event => event.day === dayIndex)
  }

  const priorityColors = {
    high: 'border-l-red-500 bg-red-500/10',
    medium: 'border-l-amber-500 bg-amber-500/10',
    low: 'border-l-slate-500 bg-slate-500/10'
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-xl font-semibold text-white">Weekly Schedule</h2>
          <p className="text-slate-400 text-sm">Team activities and cron jobs</p>
        </div>
        
        <div className="flex items-center gap-2">
          <button
            onClick={() => setCurrentWeek(addDays(currentWeek, -7))}
            className="p-2 rounded-lg bg-slate-800 text-slate-400 hover:text-white"
          >
            <ChevronLeft className="w-5 h-5" />
          </button>
          
          <span className="text-white font-medium px-4">
            {format(weekStart, 'MMM d')} - {format(addDays(weekStart, 6), 'MMM d, yyyy')}
          </span>
          
          <button
            onClick={() => setCurrentWeek(addDays(currentWeek, 7))}
            className="p-2 rounded-lg bg-slate-800 text-slate-400 hover:text-white"
          >
            <ChevronRight className="w-5 h-5" />
          </button>
        </div>
      </div>

      {/* Calendar Grid */}
      <div className="card overflow-hidden">
        <div className="grid grid-cols-7 border-b border-slate-800">
          {weekDays.map((day, idx) => (
            <div key={day} className="p-4 text-center border-r border-slate-800 last:border-r-0">
              <p className="text-sm font-medium text-slate-400">{day}</p>
              <p className={`text-lg font-semibold ${
                isSameDay(weekDaysFull[idx], new Date()) ? 'text-indigo-400' : 'text-white'
              }`}>
                {format(weekDaysFull[idx], 'd')}
              </p>
            </div>
          ))}
        </div>

        <div className="grid grid-cols-7 min-h-[400px]">
          {weekDays.map((day, idx) => {
            const dayEvents = getEventsForDay(idx)
            return (
              <div 
                key={day} 
                className="p-2 border-r border-slate-800 last:border-r-0 bg-slate-900/50 min-h-[100px]"
              >
                <div className="space-y-2">
                  {dayEvents.map((event) => (
                    <button
                      key={event.id}
                      onClick={() => setSelectedEvent(event)}
                      className={`w-full text-left p-2 rounded border-l-2 ${priorityColors[event.priority]} hover:opacity-80 transition-opacity`}
                    >
                      <div className="flex items-center gap-1 mb-1">
                        {event.type === 'cron' ? <Repeat className="w-3 h-3 text-slate-400" /> :
                         <Clock className="w-3 h-3 text-slate-400" />}
                        <span className="text-xs text-slate-400">{event.time}</span>
                      </div>
                      <p className="text-xs font-medium text-white truncate">{event.title}</p>
                      <div className="flex items-center gap-1 mt-1">
                        <Bot className="w-3 h-3 text-indigo-400" />
                        <span className="text-xs text-slate-500">{event.assignee}</span>
                      </div>
                    </button>
                  ))}
                </div>              
              </div>
            )
          })}
        </div>
      </div>

      {/* Event Details */}
      {selectedEvent ? (
        <div className="card p-6">
          <div className="flex items-start justify-between mb-4">
            <div>
              <div className="flex items-center gap-2 mb-2">
                <h3 className="text-lg font-semibold text-white">{selectedEvent.title}</h3>
                <span className={`text-xs px-2 py-1 rounded-full ${
                  selectedEvent.priority === 'high' 
                    ? 'bg-red-500/20 text-red-400' :
                  selectedEvent.priority === 'medium'
                    ? 'bg-amber-500/20 text-amber-400'
                    : 'bg-slate-700 text-slate-400'
                }`}>
                  {selectedEvent.priority} priority
                </span>
              </div>
              
              <p className="text-slate-400">{selectedEvent.description}</p>
            </div>
            
            <button
              onClick={() => setSelectedEvent(null)}
              className="text-slate-500 hover:text-white"
            >
              ×
            </button>
          </div>

          <div className="grid md:grid-cols-3 gap-4 text-sm">
            <div className="flex items-center gap-2 text-slate-400">
              <Clock className="w-4 h-4" />
              <span>{selectedEvent.schedule} at {selectedEvent.time}</span>
            </div>
            
            <div className="flex items-center gap-2 text-slate-400">
              <Bot className="w-4 h-4 text-indigo-400" />
              <span>Assigned to: {selectedEvent.assignee}</span>
            </div>
            
            <div className="flex items-center gap-2 text-slate-400">
              <Repeat className="w-4 h-4" />
              <span className="capitalize">{selectedEvent.type}</span>
            </div>
          </div>
        </div>
      ) : (
        <div className="card p-6">
          <div className="flex items-center gap-3 text-slate-400">
            <AlertCircle className="w-5 h-5" />
            <p>Click on an event to view details. More team activities will be added as the team grows.</p>
          </div>
        </div>
      )}

      {/* Legend */}
      <div className="flex flex-wrap gap-4 text-sm">
        <div className="flex items-center gap-2">
          <div className="w-3 h-3 rounded-full bg-red-500/20 border border-red-500"></div>
          <span className="text-slate-400">High Priority</span>
        </div>
        <div className="flex items-center gap-2">
          <div className="w-3 h-3 rounded-full bg-amber-500/20 border border-amber-500"></div>
          <span className="text-slate-400">Medium Priority</span>
        </div>
        <div className="flex items-center gap-2">
          <div className="w-3 h-3 rounded-full bg-slate-500/20 border border-slate-500"></div>
          <span className="text-slate-400">Low Priority</span>
        </div>
      </div>
    </div>
  )
}

export default Calendar
