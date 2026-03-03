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

### **Backend/API Development**
**Kimi handles:**
- Standard CRUD endpoints
- Database models
- Basic middleware
- Documentation

**Escalate to OpenAI:**
- Authentication/authz systems
- Rate limiting strategies
- Microservice architecture
- Complex data pipelines

### **Web Development**
**Kimi handles:**
- React/Vue components
- CSS/styling
- Form handling
- Basic state management

**Escalate to OpenAI:**
- Complex state architecture (Redux/Zustand)
- Performance optimization
- Security (auth, XSS prevention)
- Build/deployment pipelines

---

## 💰 Cost Optimization Rules

1. **Budget per task:**
   - Kimi tasks: $0.05-0.20 budget
   - OpenAI tasks: $0.50-2.00 budget
   - Code reviews: $1.00-3.00 budget

2. **Weekly cost tracking:**
   - Target: 80% Kimi / 20% OpenAI usage
   - If OpenAI >30%, review escalation criteria

3. **Batch OpenAI reviews:**
   - Save 3-5 issues for single review
   - More efficient than individual escalations

---

## 📝 Documentation Requirements

**When escalating to OpenAI:**
- Document the problem Kimi couldn't solve
- Include error messages/logs
- Note the OpenAI solution
- Update this file with patterns learned

**After each sprint:**
- Review cost breakdown
- Identify tasks that could have been Kimi
- Update rules based on learnings

---

## 🚀 Current Project Status

### **Walking Routes iOS App**
- **Current Phase:** Polish & Monetization
- **Next Sprint:** Paywall, offline maps, TestFlight prep
- **Default Model:** Kimi
- **Escalation Triggers:** Subscription logic, offline architecture

### **Next Apps Queue**
- Apply this workflow from Day 1
- Document which model worked best for what

---

## 🔧 Tool Configuration

### **Subagent Spawning**
```javascript
// Default Developer
{
  runtime: "subagent",
  model: "moonshot/kimi-k2.5",  // Always start here
  mode: "run" | "session"
}

// Escalation Developer
{
  runtime: "subagent", 
  model: "openai/gpt-5.2",  // Only when needed
  mode: "run" | "session"
}
```

### **Labeling Convention**
- `[KIMI]` - Standard implementation task
- `[ESCALATE]` - Needs OpenAI reasoning
- `[OPENAI]` - Confirmed OpenAI task
- `[REVIEW]` - Pre-release code review

---

## 📊 Success Metrics

**Target Ratios:**
- 80% of tasks completed with Kimi
- 20% escalated to OpenAI
- 80% cost savings vs OpenAI-only
- <5% of Kimi tasks need escalation (efficiency metric)

**Review Monthly:**
- Cost per feature delivered
- Time to completion by model
- Quality metrics (bugs, refactor needs)

---

_This workflow evolves. Update based on real project learnings._
