# WORKFLOW_AUTO.md - AI Development Process

_Last updated: 2026-03-03_

## 🎯 Our Hybrid AI Development Workflow

**Primary Rule:** Start with Kimi, escalate to OpenAI only when needed.

---

## 🤖 Model Selection Guide

### **Default: Kimi K2.5 (kimi-coding/k2p5)**
**Use for:**
- ✅ Initial feature implementation
- ✅ UI/SwiftUI components
- ✅ Standard API integrations
- ✅ Refactoring and cleanup
- ✅ Adding screens/views
- ✅ Tests and documentation
- ✅ Bug fixes (first 2 attempts)

**Cost:** ~$0.60 input / $2.50 output per 1M tokens

### **Escalation: OpenAI GPT-5.2 (openai/gpt-5.2)**
**Use ONLY when:**
- 🚨 Kimi failed 2+ times on same issue
- 🚨 Complex architecture decisions
- 🚨 Performance optimization needed
- 🚨 Security-sensitive code
- 🚨 Multi-file refactoring (10+ files)
- 🚨 Before major releases (code review)
- 🚨 When Kimi says "I can't" or gets stuck

**Cost:** ~$1.75 input / $14.00 output per 1M tokens

---

## 🔄 Development Workflow

### **Sprint Planning Phase**
1. Break work into tasks
2. Label each task: KIMI or OPENAI
3. Default assumption: KIMI unless complexity warrants OpenAI

### **Daily Development Loop**
```
START → Kimi implements feature
        ↓
    Success? → YES → Done ✓
        ↓ NO
    Try Kimi again (different approach)
        ↓
    Success? → YES → Done ✓
        ↓ NO
    ESCALATE to OpenAI
        ↓
    Get architectural solution
        ↓
    Kimi implements specifics
        ↓
    Done ✓
```

### **Quality Gates**
**Before escalating to OpenAI, check:**
- [ ] Kimi attempted fix with different prompt?
- [ ] Issue affects multiple files?
- [ ] Is this architectural vs implementation?
- [ ] Would human dev need senior help?

**After OpenAI solution:**
- [ ] Document the fix for future reference
- [ ] Have Kimi implement (cheaper)
- [ ] Test thoroughly
- [ ] Update knowledge base

---

## 🏗️ Project-Specific Rules

### **iOS Apps (SwiftUI)**
**Kimi handles:**
- SwiftUI views, navigation
- MapKit integration
- CoreLocation
- UI polish, animations
- Basic data models

**Escalate to OpenAI:**
- Complex routing algorithms
- Offline sync architecture
- Payment/subscription logic
- Performance optimization
- Security implementation

---

_This workflow evolves. Update based on real project learnings._
