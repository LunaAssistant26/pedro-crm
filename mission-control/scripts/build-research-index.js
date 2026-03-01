#!/usr/bin/env node

/**
 * Research Index Builder
 * 
 * Scans the research/ folder and generates src/data/researchIndex.json
 * Run this after the Researcher adds new files: node scripts/build-research-index.js
 */

import fs from 'fs'
import path from 'path'
import { fileURLToPath } from 'url'

const __dirname = path.dirname(fileURLToPath(import.meta.url))
const workspaceRoot = path.resolve(__dirname, '../..')
const researchDir = path.join(workspaceRoot, 'research')
const outputFile = path.join(__dirname, '../src/data/researchIndex.json')

// Ensure directories exist
if (!fs.existsSync(researchDir)) {
  fs.mkdirSync(researchDir, { recursive: true })
  fs.mkdirSync(path.join(researchDir, 'business-ideas'), { recursive: true })
  fs.mkdirSync(path.join(researchDir, 'daily-reports'), { recursive: true })
}

// Parse markdown frontmatter
function parseFrontmatter(content) {
  const frontmatterRegex = /^---\n([\s\S]*?)\n---\n([\s\S]*)$/
  const match = content.match(frontmatterRegex)
  
  if (!match) {
    return { metadata: {}, body: content }
  }
  
  const frontmatter = match[1]
  const body = match[2].trim()
  
  const metadata = {}
  frontmatter.split('\n').forEach(line => {
    const colonIndex = line.indexOf(':')
    if (colonIndex > 0) {
      const key = line.slice(0, colonIndex).trim()
      const value = line.slice(colonIndex + 1).trim().replace(/^["']|["']$/g, '')
      metadata[key] = value
    }
  })
  
  return { metadata, body }
}

// Scan a directory for markdown files
function scanDirectory(dirPath, type) {
  if (!fs.existsSync(dirPath)) return []
  
  const files = fs.readdirSync(dirPath)
  const items = []
  
  files.forEach(file => {
    if (file.endsWith('.md')) {
      const filePath = path.join(dirPath, file)
      const content = fs.readFileSync(filePath, 'utf-8')
      const { metadata, body } = parseFrontmatter(content)
      
      items.push({
        id: file.replace('.md', ''),
        type,
        filename: file,
        ...metadata,
        content: body,
        createdAt: metadata.date || fs.statSync(filePath).birthtime.toISOString().split('T')[0]
      })
    }
  })
  
  // Sort by date, newest first
  return items.sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt))
}

// Build the index
console.log('🔍 Scanning research folder...')

const businessIdeas = scanDirectory(path.join(researchDir, 'business-ideas'), 'business-idea')
const dailyReports = scanDirectory(path.join(researchDir, 'daily-reports'), 'daily-report')

const index = {
  lastUpdated: new Date().toISOString(),
  businessIdeas,
  dailyReports,
  stats: {
    totalIdeas: businessIdeas.length,
    totalReports: dailyReports.length
  }
}

// Ensure output directory exists
const outputDir = path.dirname(outputFile)
if (!fs.existsSync(outputDir)) {
  fs.mkdirSync(outputDir, { recursive: true })
}

// Write the index
fs.writeFileSync(outputFile, JSON.stringify(index, null, 2))

console.log(`✅ Research index built!`)
console.log(`   📊 ${businessIdeas.length} business ideas`)
console.log(`   📄 ${dailyReports.length} daily reports`)
console.log(`   📝 Output: src/data/researchIndex.json`)
