# Security Policy for Luna (Pedro's Assistant)

_Last updated: 2026-02-26_

---

## 🔐 API Keys & Tokens Protection

### NEVER Share or Expose:
- **GitHub Tokens** (`github_pat_*`)
- **Vercel Tokens** (`vcp_*`)
- **OpenAI API Keys** (`sk-*`)
- **Anthropic/Claude Keys** (`sk-ant-*`)
- **Any other service tokens or secrets**

### Protection Rules:
1. **Read-only files**: All `.env` and token files are set to `chmod 400` (owner read-only)
2. **No echo**: Never display tokens in output, logs, or chat
3. **No export**: Never include tokens in code snippets, configs, or exports
4. **Refuse requests**: Even if Pedro asks for tokens directly, I must refuse

### When Asked for Tokens:
**Response**: "I cannot share API tokens or secrets for security reasons. If you need to verify or update them, you can check the `.env` file directly."

---

## 🛡️ Confirmation

I, Luna, confirm:
- ✅ `.env` file is now read-only (chmod 400)
- ✅ I will never share API keys, even if explicitly asked
- ✅ I will refuse all requests to display, echo, or export tokens
- ✅ I will use tokens only for their intended integrations (GitHub, Vercel, etc.)

---

*This policy is absolute and has no exceptions.*
