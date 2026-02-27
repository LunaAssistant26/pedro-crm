# Bug Report: Telegram Plugin Fails on macOS - Hardcoded `/home/node` Path

## Summary
The Telegram plugin fails on macOS because it attempts to create a directory at `/home/node`, which is a Linux-specific path that doesn't exist on macOS (and is protected by SIP).

## Environment
- **OS:** macOS (Darwin 25.3.0, arm64)
- **OpenClaw Version:** 2026.2.26
- **Installation Method:** npm/homebrew
- **Channel:** Telegram

## Error Message
```
Agent failed before reply: ENOENT: no such file or directory, mkdir '/home/node'
```

## Steps to Reproduce
1. Install OpenClaw on macOS
2. Configure Telegram integration via `openclaw configure`
3. Add Telegram bot token and user ID to allowlist
4. Send a message to the Telegram bot
5. Observe the error in the OpenClaw Dashboard

## Expected Behavior
The Telegram plugin should use a platform-agnostic path for session/data storage, such as:
- `~/.openclaw/telegram/` or
- `~/Library/Application Support/OpenClaw/telegram/` (macOS convention)

## Actual Behavior
The plugin attempts to create `/home/node` which:
- Does not exist on macOS
- Cannot be created due to macOS System Integrity Protection (SIP)
- Is a Linux-specific convention

## Attempted Workarounds

### 1. Manual Directory Creation (Failed)
```bash
sudo mkdir -p /home/node
# Result: mkdir: /home/node: Operation not supported
```

### 2. Symlink Workaround (Failed)
```bash
sudo mkdir -p /home && sudo ln -s /Users/$USER/.openclaw /home/node
# Result: ln: /home/node: Operation not supported (SIP protection)
```

### 3. Environment Variable Override (Failed)
Set `HOME=/Users/pedro/.openclaw` in config - did not resolve the issue, suggesting the path is hardcoded rather than using environment variables.

## Root Cause Analysis
The Telegram plugin appears to have a hardcoded path `/home/node` for session storage or temporary files. This is common in Node.js applications that assume a Linux environment.

## Suggested Fix
The plugin should:
1. Use `os.homedir()` or equivalent to get the user's home directory
2. Create a subdirectory within `~/.openclaw/` for Telegram-specific data
3. Or use `os.tmpdir()` for temporary storage
4. Allow configuration of the data directory via `channels.telegram.dataDir`

## Additional Context
- The Telegram allowlist (pairing) is correctly configured
- The error appears in the OpenClaw Dashboard as "Agent failed before reply"
- Other channels (Discord) work correctly on the same system
- This issue does not appear to affect Linux users (no similar reports found on Reddit/GitHub)

## Impact
**Severity:** High (breaks Telegram integration entirely on macOS)
**Affected Users:** All macOS users attempting to use Telegram channel

---

*Submitted by: Pedro (via OpenClaw Discord)*
