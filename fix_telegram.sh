#!/bin/bash
# Fix Telegram /home/node error for OpenClaw on macOS

echo "Creating /home/node directory..."
sudo mkdir -p /home/node

echo "Setting ownership to current user..."
sudo chown $(whoami):staff /home/node

echo "Creating symlink for .openclaw..."
ln -sf /Users/$(whoami)/.openclaw /home/node/.openclaw

echo "Verifying..."
ls -la /home/node/

echo ""
echo "Restarting OpenClaw gateway..."
openclaw gateway restart

echo ""
echo "✅ Fix applied! Try sending a message to your Telegram bot now."
