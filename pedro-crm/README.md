# Pedro's Payments CRM

Visual CRM for your payments referral business.

## 🚀 Quick Deploy

```bash
cd /Users/pedro/.openclaw/workspace/pedro-crm
npm install
npm run build
vercel --prod
```

## 📊 Data

Edit `src/lib/data.js` to add partners and deals:

- `partners` array - Add your PSPs/Acquirers
- `deals` array - Add your client deals

## 📝 Pages

- **Dashboard** (`/`) - Overview with stats
- **Partners** (`/partners`) - All PSPs/Acquirers
- **Partner Detail** (`/partners/[id]`) - Full partner info
- **Deals** (`/deals`) - Pipeline view
- **Deal Detail** (`/deals/[id]`) - Individual deal info

---

*Simple CRM with JavaScript - No TypeScript headaches!*
