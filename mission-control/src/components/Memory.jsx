import { useState, useEffect } from 'react';
import { Brain, FileText, Calendar, Search, RefreshCw, Clock, AlertTriangle } from 'lucide-react';
import { MEMORY_FILES } from '../data/memoryFiles';

// Memory content is served from Vite public folder at /memory/*.md
// We keep this folder in sync with workspace memory files.

export default function Memory() {
  const [activeFile, setActiveFile] = useState('memory-md');
  const [content, setContent] = useState('');
  const [loading, setLoading] = useState(true);
  const [searchQuery, setSearchQuery] = useState('');
  const [lastUpdated, setLastUpdated] = useState(null);

  const loadMemoryContent = async (fileId) => {
    setLoading(true);

    // Small delay for nicer UX
    await new Promise(resolve => setTimeout(resolve, 150));

    const file = MEMORY_FILES.find(f => f.id === fileId) || MEMORY_FILES[0];

    try {
      const res = await fetch(`/memory/${file.filename}`);
      if (!res.ok) throw new Error(`HTTP ${res.status}`);
      const text = await res.text();
      setContent(text);
      setLastUpdated(new Date());
    } catch (err) {
      setContent(`⚠️ Could not load ${file.filename}.\n\nMake sure the file exists in mission-control/public/memory/.\n\nError: ${String(err)}`);
      setLastUpdated(new Date());
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadMemoryContent(activeFile);
  }, [activeFile]);

  const filteredContent = searchQuery
    ? content.split('\n').filter(line => 
        line.toLowerCase().includes(searchQuery.toLowerCase())
      ).join('\n')
    : content;

  const renderMarkdown = (text) => {
    return text.split('\n').map((line, index) => {
      // Headers
      if (line.startsWith('# ')) {
        return <h1 key={index} className="text-2xl font-bold text-white mb-4">{line.slice(2)}</h1>;
      }
      if (line.startsWith('## ')) {
        return <h2 key={index} className="text-xl font-semibold text-white mt-6 mb-3">{line.slice(3)}</h2>;
      }
      if (line.startsWith('### ')) {
        return <h3 key={index} className="text-lg font-medium text-white mt-4 mb-2">{line.slice(4)}</h3>;
      }
      
      // Lists
      if (line.startsWith('- ')) {
        return <li key={index} className="ml-4 text-slate-300 mb-1">{line.slice(2)}</li>;
      }
      if (line.startsWith('  - ')) {
        return <li key={index} className="ml-8 text-slate-400 mb-1 text-sm">{line.slice(4)}</li>;
      }
      
      // Empty lines
      if (line.trim() === '') {
        return <div key={index} className="h-2" />;
      }
      
      // Horizontal rule
      if (line.startsWith('---')) {
        return <hr key={index} className="border-slate-700 my-4" />;
      }
      
      // Bold text
      const boldText = line.replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>');
      
      // Regular paragraph
      return <p key={index} className="text-slate-300 mb-2" dangerouslySetInnerHTML={{ __html: boldText }} />;
    });
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex justify-between items-center">
        <div className="flex items-center gap-3">
          <div className="bg-purple-500/20 p-2 rounded-lg">
            <Brain className="w-5 h-5 text-purple-400" />
          </div>
          <div>
            <h2 className="text-xl font-semibold text-white">Memory</h2>
            <p className="text-sm text-slate-400">Searchable memory and daily logs</p>
          </div>
        </div>

        <div className="flex items-center gap-3">
          {lastUpdated && (
            <span className="text-sm text-slate-500">
              Updated: {lastUpdated.toLocaleTimeString()}
            </span>
          )}
          <button
            onClick={() => loadMemoryContent(activeFile)}
            disabled={loading}
            className="flex items-center gap-2 px-4 py-2 bg-slate-800 hover:bg-slate-700 rounded-lg text-sm transition-colors disabled:opacity-50"
          >
            <RefreshCw className={`w-4 h-4 ${loading ? 'animate-spin' : ''}`} />
            Refresh
          </button>
        </div>
      </div>

      {/* Search */}
      <div className="relative">
        <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-500" />
        <input
          type="text"
          placeholder="Search memory..."
          value={searchQuery}
          onChange={(e) => setSearchQuery(e.target.value)}
          className="w-full pl-10 pr-4 py-2 bg-slate-900 border border-slate-800 rounded-lg text-sm focus:outline-none focus:border-indigo-500 text-white"
        />
      </div>

      {/* File Selection */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        {MEMORY_FILES.map((file) => (
          <button
            key={file.id}
            onClick={() => setActiveFile(file.id)}
            className={`p-4 rounded-lg border transition-all text-left ${
              activeFile === file.id
                ? 'bg-indigo-600/20 border-indigo-500/50'
                : 'bg-slate-900 border-slate-800 hover:border-slate-700'
            }`}
          >
            <div className="flex items-start gap-3">
              <div className={`p-2 rounded-lg ${
                activeFile === file.id ? 'bg-indigo-500/20' : 'bg-slate-800'
              }`}>
                {file.type === 'long-term' ? (
                  <Brain className="w-4 h-4 text-purple-400" />
                ) : (
                  <Calendar className="w-4 h-4 text-blue-400" />
                )}
              </div>
              <div>
                <h3 className={`font-medium ${
                  activeFile === file.id ? 'text-indigo-300' : 'text-white'
                }`}>
                  {file.name}
                </h3>
                <p className="text-xs text-slate-500 mt-1">{file.description}</p>
                <span className={`inline-block mt-2 text-xs px-2 py-0.5 rounded-full ${
                  file.type === 'long-term' 
                    ? 'bg-purple-500/20 text-purple-400'
                    : 'bg-blue-500/20 text-blue-400'
                }`}>
                  {file.type === 'long-term' ? 'Long-term' : 'Daily'}
                </span>
              </div>
            </div>
          </button>
        ))}
      </div>

      {/* Content */}
      <div className="bg-slate-900 rounded-lg border border-slate-800">
        <div className="px-6 py-4 border-b border-slate-800 flex justify-between items-center">
          <div className="flex items-center gap-2">
            <FileText className="w-4 h-4 text-slate-500" />
            <span className="text-sm text-slate-400">
              {MEMORY_FILES.find(f => f.id === activeFile)?.name}
            </span>
          </div>
          <div className="flex items-center gap-2 text-xs text-slate-500">
            <Clock className="w-3 h-3" />
            Daily updates at 10:00 PM
          </div>
        </div>

        <div className="p-6 max-h-[600px] overflow-y-auto">
          {loading ? (
            <div className="flex items-center justify-center py-12">
              <RefreshCw className="w-6 h-6 animate-spin text-slate-500" />
            </div>
          ) : searchQuery && !filteredContent ? (
            <div className="text-center py-12 text-slate-500">
              No matches found for "{searchQuery}"
            </div>
          ) : (
            <div className="prose prose-invert max-w-none">
              {renderMarkdown(filteredContent || content)}
            </div>
          )}
        </div>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
        <div className="bg-slate-900 rounded-lg p-4 border border-slate-800">
          <p className="text-sm text-slate-500">Memory Files</p>
          <p className="text-2xl font-bold text-white">{MEMORY_FILES.length}</p>
        </div>
        <div className="bg-slate-900 rounded-lg p-4 border border-slate-800">
          <p className="text-sm text-slate-500">Daily Updates</p>
          <p className="text-2xl font-bold text-white">10:00 PM</p>
        </div>
        <div className="bg-slate-900 rounded-lg p-4 border border-slate-800">
          <p className="text-sm text-slate-500">Projects Tracked</p>
          <p className="text-2xl font-bold text-white">{new Set(MEMORY_FILES.map(f => f.type)).size}</p>
        </div>
        <div className="bg-slate-900 rounded-lg p-4 border border-slate-800">
          <p className="text-sm text-slate-500">Cron Jobs</p>
          <p className="text-2xl font-bold text-white">3</p>
        </div>
      </div>
    </div>
  );
}
