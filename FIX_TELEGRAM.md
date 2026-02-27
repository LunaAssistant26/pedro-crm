# Fix for Telegram /home/node Error

The issue is OpenClaw is trying to write to `/home/node/.openclaw/` but your macOS home is `/Users/pedro`.

## Quick Fix

Run this in Terminal with admin privileges:

```bash
sudo mkdir -p /home/node
sudo chown $(whoami) /home/node
ln -s /Users/pedro/.openclaw /home/node/.openclaw
```

Then restart OpenClaw:
```bash
openclaw gateway restart
```

## Alternative Fix (if above doesn't work)

Edit your shell profile to override HOME for OpenClaw:

```bash
# Add to ~/.zshrc or ~/.bash_profile
export OPENCLAW_HOME=/Users/pedro
```

Then reload and restart:
```bash
source ~/.zshrc
launchctl unload ~/Library/LaunchAgents/ai.openclaw.gateway.plist
launchctl load ~/Library/LaunchAgents/ai.openclaw.gateway.plist
```

## Test

After fixing, send a message to your Telegram bot - it should work!
