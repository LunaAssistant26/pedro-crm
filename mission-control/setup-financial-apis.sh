#!/bin/bash

echo "🔧 Financial Advisor API Setup"
echo "==============================="
echo ""

# Check if .env.financial exists
if [ -f ".env.financial" ]; then
    echo "✅ .env.financial already exists"
    echo ""
    read -p "Do you want to overwrite it? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Setup cancelled."
        exit 0
    fi
fi

echo "You'll need API keys from these services:"
echo ""
echo "1. Alpha Vantage (Stocks/ETFs): https://www.alphavantage.co/support/#api-key"
echo "2. NewsAPI (Financial News): https://newsapi.org/register"
echo "3. CoinGecko (Crypto): https://www.coingecko.com/en/api/pricing (optional - works without key)"
echo ""
echo "All have FREE tiers that are sufficient for personal use."
echo ""

# Prompt for API keys
echo "Enter your API keys (press Enter to skip):"
echo ""

read -p "Alpha Vantage API Key: " ALPHA_KEY
read -p "NewsAPI Key: " NEWS_KEY
read -p "CoinGecko API Key (optional): " COINGECKO_KEY

# Create .env.financial file
cat > .env.financial << EOF
# Financial Advisor API Keys
# Get your free API keys from:
# - Alpha Vantage: https://www.alphavantage.co/support/#api-key
# - NewsAPI: https://newsapi.org/register
# - CoinGecko: https://www.coingecko.com/en/api/pricing (optional)

VITE_ALPHA_VANTAGE_KEY=$ALPHA_KEY
VITE_NEWS_API_KEY=$NEWS_KEY
VITE_COINGECKO_KEY=$COINGECKO_KEY
EOF

echo ""
echo "✅ Created .env.financial"
echo ""
echo "🔒 IMPORTANT:"
echo "   - Never commit .env.financial to GitHub"
echo "   - Keep your API keys secret"
echo "   - Free tier limits:"
echo "     - Alpha Vantage: 5 calls/min, 500/day"
echo "     - NewsAPI: 100 requests/day"
echo "     - CoinGecko: generous free limits"
echo ""
echo "🚀 Next steps:"
echo "   1. Restart Mission Control: npm run dev"
echo "   2. Visit the Financial tab"
echo "   3. Click 'Refresh' to test the APIs"
echo ""

# Make script executable
chmod +x setup-financial-apis.sh
