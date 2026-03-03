import { useState, useMemo, useEffect } from 'react'
import { 
  FileText, 
  Search, 
  Tag, 
  Calendar, 
  User, 
  Folder,
  X
} from 'lucide-react'
import { documents, categories, allTags } from '../data/documents'

export default function Docs() {
  const [searchQuery, setSearchQuery] = useState('')
  const [selectedCategory, setSelectedCategory] = useState('All')
  const [selectedTags, setSelectedTags] = useState([])
  const [selectedDoc, setSelectedDoc] = useState(null)
  const [docContent, setDocContent] = useState('')
  const [docLoading, setDocLoading] = useState(false)
  const [docError, setDocError] = useState(null)

  // Filter documents based on search, category, and tags
  const filteredDocs = useMemo(() => {
    return documents.filter(doc => {
      // Search filter
      const searchLower = searchQuery.toLowerCase()
      const matchesSearch = 
        searchQuery === '' ||
        doc.title.toLowerCase().includes(searchLower) ||
        doc.summary.toLowerCase().includes(searchLower) ||
        doc.tags.some(tag => tag.toLowerCase().includes(searchLower))
      
      // Category filter
      const matchesCategory = 
        selectedCategory === 'All' || 
        doc.category === selectedCategory
      
      // Tags filter
      const matchesTags = 
        selectedTags.length === 0 ||
        selectedTags.every(tag => doc.tags.includes(tag))
      
      return matchesSearch && matchesCategory && matchesTags
    })
  }, [searchQuery, selectedCategory, selectedTags])

  const toggleTag = (tag) => {
    setSelectedTags(prev => 
      prev.includes(tag) 
        ? prev.filter(t => t !== tag)
        : [...prev, tag]
    )
  }

  const clearFilters = () => {
    setSearchQuery('')
    setSelectedCategory('All')
    setSelectedTags([])
  }

  useEffect(() => {
    const load = async () => {
      if (!selectedDoc) return
      setDocLoading(true)
      setDocError(null)
      setDocContent('')
      try {
        const res = await fetch(`/docs/${selectedDoc.docFile}`)
        if (!res.ok) throw new Error(`HTTP ${res.status}`)
        const text = await res.text()
        setDocContent(text)
      } catch (e) {
        setDocError(String(e))
      } finally {
        setDocLoading(false)
      }
    }
    load()
  }, [selectedDoc])

  const renderMarkdown = (text) => {
    return text.split('\n').map((line, index) => {
      if (line.startsWith('# ')) return <h1 key={index} className="text-2xl font-bold text-white mb-4">{line.slice(2)}</h1>
      if (line.startsWith('## ')) return <h2 key={index} className="text-xl font-semibold text-white mt-6 mb-3">{line.slice(3)}</h2>
      if (line.startsWith('### ')) return <h3 key={index} className="text-lg font-medium text-white mt-4 mb-2">{line.slice(4)}</h3>
      if (line.startsWith('- ')) return <li key={index} className="ml-4 text-slate-300 mb-1">{line.slice(2)}</li>
      if (line.startsWith('  - ')) return <li key={index} className="ml-8 text-slate-400 mb-1 text-sm">{line.slice(4)}</li>
      if (line.trim() === '') return <div key={index} className="h-2" />
      if (line.startsWith('---')) return <hr key={index} className="border-slate-700 my-4" />
      const boldText = line.replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>')
      return <p key={index} className="text-slate-300 mb-2" dangerouslySetInnerHTML={{ __html: boldText }} />
    })
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-3">
          <div className="bg-emerald-500/20 p-2 rounded-lg">
            <FileText className="w-5 h-5 text-emerald-400" />
          </div>
          <div>
            <h2 className="text-xl font-semibold text-white">Documents</h2>
            <p className="text-sm text-slate-400">{filteredDocs.length} of {documents.length} documents</p>
          </div>
        </div>
        <div className="flex items-center gap-2">
          {(searchQuery || selectedCategory !== 'All' || selectedTags.length > 0) && (
            <button
              onClick={clearFilters}
              className="flex items-center gap-1 px-3 py-1.5 text-xs text-slate-400 hover:text-white transition-colors"
            >
              <X className="w-3 h-3" />
              Clear filters
            </button>
          )}
        </div>
      </div>

      {/* Search and Filters */}
      <div className="space-y-4">
        {/* Search Bar */}
        <div className="relative">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-400" />
          <input
            type="text"
            placeholder="Search documents, summaries, or tags..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="w-full bg-slate-900 border border-slate-700 rounded-lg pl-10 pr-4 py-2.5 text-sm text-white placeholder-slate-500 focus:outline-none focus:border-emerald-500 transition-colors"
          />
        </div>

        {/* Category Filter */}
        <div className="flex items-center gap-2 flex-wrap">
          <div className="flex items-center gap-1 text-slate-400 text-xs">
            <Folder className="w-3 h-3" />
            Category:
          </div>
          {categories.map(category => (
            <button
              key={category}
              onClick={() => setSelectedCategory(category)}
              className={`px-3 py-1 rounded-full text-xs font-medium transition-all ${
                selectedCategory === category
                  ? 'bg-emerald-500/20 text-emerald-400 border border-emerald-500/30'
                  : 'bg-slate-800 text-slate-400 hover:text-white border border-transparent'
              }`}
            >
              {category}
            </button>
          ))}
        </div>

        {/* Tags Filter */}
        <div className="flex items-center gap-2 flex-wrap">
          <div className="flex items-center gap-1 text-slate-400 text-xs">
            <Tag className="w-3 h-3" />
            Tags:
          </div>
          {allTags.slice(0, 15).map(tag => (
            <button
              key={tag}
              onClick={() => toggleTag(tag)}
              className={`px-2.5 py-1 rounded-full text-xs transition-all ${
                selectedTags.includes(tag)
                  ? 'bg-indigo-500/20 text-indigo-400 border border-indigo-500/30'
                  : 'bg-slate-800 text-slate-400 hover:text-white border border-transparent'
              }`}
            >
              {tag}
            </button>
          ))}
          {allTags.length > 15 && (
            <span className="text-xs text-slate-500">+{allTags.length - 15} more</span>
          )}
        </div>
      </div>

      {/* Documents List */}
      {!selectedDoc ? (
        <div className="grid grid-cols-1 gap-3">
          {filteredDocs.map((doc) => (
            <div
              key={doc.id}
              onClick={() => setSelectedDoc(doc)}
              className="card p-4 cursor-pointer hover:border-emerald-500 transition-all group"
            >
              <div className="flex items-start justify-between mb-3">
                <div className="flex items-center gap-3">
                  <div className="bg-slate-800 p-2 rounded-lg">
                    <FileText className="w-4 h-4 text-emerald-400" />
                  </div>
                  <div>
                    <h3 className="font-medium text-white group-hover:text-emerald-400 transition-colors">
                      {doc.title}
                    </h3>
                    <div className="flex items-center gap-2 text-xs text-slate-400 mt-0.5">
                      <span className="px-2 py-0.5 bg-slate-800 rounded text-slate-300">
                        {doc.category}
                      </span>
                      <span className="flex items-center gap-1">
                        <Calendar className="w-3 h-3" />
                        {doc.date}
                      </span>
                      <span className="flex items-center gap-1">
                        <User className="w-3 h-3" />
                        {doc.author}
                      </span>
                    </div>
                  </div>
                </div>
                <span className={`px-2 py-0.5 rounded text-xs ${
                  doc.status === 'Complete' 
                    ? 'bg-emerald-500/20 text-emerald-400' 
                    : 'bg-amber-500/20 text-amber-400'
                }`}>
                  {doc.status}
                </span>
              </div>

              <p className="text-sm text-slate-300 mb-3 line-clamp-2">
                {doc.summary}
              </p>

              <div className="flex flex-wrap gap-1.5">
                {doc.tags.map(tag => (
                  <span 
                    key={tag}
                    className="px-2 py-0.5 bg-slate-800 rounded text-xs text-slate-400"
                  >
                    #{tag}
                  </span>
                ))}
              </div>
            </div>
          ))}

          {filteredDocs.length === 0 && (
            <div className="text-center py-12">
              <FileText className="w-12 h-12 text-slate-600 mx-auto mb-3" />
              <p className="text-slate-400">No documents found matching your filters.</p>
              <button
                onClick={clearFilters}
                className="mt-2 text-emerald-400 hover:text-emerald-300 text-sm"
              >
                Clear all filters
              </button>
            </div>
          )}
        </div>
      ) : (
        /* Document Detail View */
        <div className="space-y-6">
          {/* Back Button */}
          <button
            onClick={() => setSelectedDoc(null)}
            className="flex items-center gap-2 text-slate-400 hover:text-white transition-colors text-sm"
          >
            ← Back to documents
          </button>

          {/* Document Header */}
          <div className="card p-6">
            <div className="flex items-start justify-between mb-4">
              <div>
                <div className="flex items-center gap-2 mb-2">
                  <span className="px-2 py-0.5 bg-slate-800 rounded text-xs text-slate-300">
                    {selectedDoc.category}
                  </span>
                  <span className={`px-2 py-0.5 rounded text-xs ${
                    selectedDoc.status === 'Complete' 
                      ? 'bg-emerald-500/20 text-emerald-400' 
                      : 'bg-amber-500/20 text-amber-400'
                  }`}>
                    {selectedDoc.status}
                  </span>
                </div>
                <h2 className="text-xl font-bold text-white mb-2">{selectedDoc.title}</h2>
                <div className="flex items-center gap-4 text-sm text-slate-400">
                  <span className="flex items-center gap-1">
                    <Calendar className="w-4 h-4" />
                    {selectedDoc.date}
                  </span>
                  <span className="flex items-center gap-1">
                    <User className="w-4 h-4" />
                    {selectedDoc.author}
                  </span>
                </div>
              </div>
            </div>

            <div className="prose prose-invert max-w-none">
              <h3 className="text-lg font-semibold text-white mb-2">Summary</h3>
              <p className="text-slate-300 leading-relaxed">{selectedDoc.summary}</p>

              <h3 className="text-lg font-semibold text-white mt-6 mb-2">Document</h3>
              <div className="bg-slate-950 border border-slate-800 rounded-lg p-4 max-h-[520px] overflow-y-auto">
                {docLoading ? (
                  <p className="text-slate-400">Loading…</p>
                ) : docError ? (
                  <p className="text-amber-400">Could not load this document yet: {docError}</p>
                ) : (
                  <div className="prose prose-invert max-w-none">
                    {renderMarkdown(docContent || 'No content available.')}
                  </div>
                )}
              </div>
            </div>

            <div className="mt-6 pt-6 border-t border-slate-800">
              <h3 className="text-sm font-medium text-slate-400 mb-3">Tags</h3>
              <div className="flex flex-wrap gap-2">
                {selectedDoc.tags.map(tag => (
                  <span 
                    key={tag}
                    className="px-3 py-1 bg-slate-800 rounded-full text-sm text-slate-300"
                  >
                    #{tag}
                  </span>
                ))}
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}
