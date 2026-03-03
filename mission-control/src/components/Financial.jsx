import { useState, useEffect } from 'react';
import { TrendingUp, DollarSign, AlertTriangle, Calendar, RefreshCw, Newspaper, BarChart3 } from 'lucide-react';
import { 
  getStockQuote, 
  getCryptoPrice, 
  getFinancialNews, 
  analyzeSentiment,
  getCompanyOverview 
} from '../services/financialData';

// Portfolio configuration
const PORTFOLIO = [
  { symbol: 'VUSA', type: 'stock', quantity: 47, name: 'Vanguard S&P 500 ETF', allocation: 40 },
  { symbol: 'NVDA', type: 'stock', quantity: 2.5, name: 'NVIDIA Corp', allocation: 20 },
  { symbol: 'bitcoin', type: 'crypto', quantity: 0.019, name: 'Bitcoin', allocation: 10 },
  { symbol: 'EUNA', type: 'stock', quantity: 336, name: 'iShares MSCI World ESG', allocation: 30 },
];

// API Keys (in production, these come from environment variables)
const ALPHA_VANTAGE_KEY = import.meta.env.VITE_ALPHA_VANTAGE_KEY || '';
const NEWS_API_KEY = import.meta.env.VITE_NEWS_API_KEY || '';

export default function Financial() {
  const [portfolioData, setPortfolioData] = useState([]);
  const [news, setNews] = useState([]);
  const [sentiment, setSentiment] = useState('neutral');
  const [loading, setLoading] = useState(true);
  const [lastUpdated, setLastUpdated] = useState(null);
  const [totalValue, setTotalValue] = useState(10000);
  const [dailyChange, setDailyChange] = useState(0);

  const fetchData = async () => {
    setLoading(true);
    
    try {
      // Fetch portfolio data
      const portfolioUpdates = await Promise.all(
        PORTFOLIO.map(async (asset) => {
          if (asset.type === 'crypto') {
            const data = await getCryptoPrice(asset.symbol);
            return {
              ...asset,
              currentPrice: data?.price || 0,
              change24h: data?.change24h || 0,
              value: (data?.price || 0) * asset.quantity
            };
          } else {
            const data = await getStockQuote(asset.symbol, ALPHA_VANTAGE_KEY);
            return {
              ...asset,
              currentPrice: data?.price || 0,
              change: data?.change || 0,
              changePercent: data?.changePercent || '0%',
              value: (data?.price || 0) * asset.quantity
            };
          }
        })
      );

      // Calculate totals
      const total = portfolioUpdates.reduce((sum, asset) => sum + asset.value, 0);
      const change = portfolioUpdates.reduce((sum, asset) => {
        const change = asset.type === 'crypto' 
          ? (asset.change24h / 100) * asset.value 
          : asset.change * asset.quantity;
        return sum + change;
      }, 0);

      setPortfolioData(portfolioUpdates);
      setTotalValue(total);
      setDailyChange(change);

      // Fetch news
      if (NEWS_API_KEY) {
        const newsData = await getFinancialNews('stocks crypto investing', NEWS_API_KEY);
        setNews(newsData || []);
        setSentiment(analyzeSentiment(newsData || []));
      }

      setLastUpdated(new Date());
    } catch (error) {
      console.error('Error fetching financial data:', error);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchData();
    // Refresh every 5 minutes
    const interval = setInterval(fetchData, 5 * 60 * 1000);
    return () => clearInterval(interval);
  }, []);

  const getSentimentColor = () => {
    switch (sentiment) {
      case 'bullish': return 'text-green-600 bg-green-100';
      case 'bearish': return 'text-red-600 bg-red-100';
      default: return 'text-yellow-600 bg-yellow-100';
    }
  };

  const getRiskColor = (risk) => {
    if (risk.includes('Low')) return 'bg-green-100 text-green-800';
    if (risk.includes('Medium')) return 'bg-yellow-100 text-yellow-800';
    return 'bg-red-100 text-red-800';
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex justify-between items-center">
        <div>
          <h2 className="text-2xl font-bold text-white">Financial Advisor</h2>
          <p className="text-slate-400 mt-1">Live portfolio tracking & investment research</p>
        </div>
        <div className="flex items-center gap-3">
          {lastUpdated && (
            <span className="text-sm text-slate-500">
              Updated: {lastUpdated.toLocaleTimeString()}
            </span>
          )}
          <button
            onClick={fetchData}
            disabled={loading}
            className="flex items-center gap-2 px-4 py-2 bg-indigo-600 hover:bg-indigo-700 rounded-lg text-sm font-medium transition-colors disabled:opacity-50"
          >
            <RefreshCw className={`h-4 w-4 ${loading ? 'animate-spin' : ''}`} />
            Refresh
          </button>
        </div>
      </div>

      {/* Portfolio Overview Cards */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
        <div className="bg-slate-900 rounded-lg p-4 border border-slate-800">
          <div className="flex items-center space-x-3">
            <div className="bg-blue-500/20 p-2 rounded-lg">
              <DollarSign className="h-5 w-5 text-blue-400" />
            </div>
            <div>
              <p className="text-sm text-slate-400">Portfolio Value</p>
              <p className="text-xl font-bold text-white">€{totalValue.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}</p>
            </div>
          </div>
        </div>

        <div className="bg-slate-900 rounded-lg p-4 border border-slate-800">
          <div className="flex items-center space-x-3">
            <div className={`p-2 rounded-lg ${dailyChange >= 0 ? 'bg-green-500/20' : 'bg-red-500/20'}`}>
              <TrendingUp className={`h-5 w-5 ${dailyChange >= 0 ? 'text-green-400' : 'text-red-400'}`} />
            </div>
            <div>
              <p className="text-sm text-slate-400">24h Change</p>
              <p className={`text-xl font-bold ${dailyChange >= 0 ? 'text-green-400' : 'text-red-400'}`}>
                {dailyChange >= 0 ? '+' : ''}€{dailyChange.toFixed(2)}
              </p>
            </div>
          </div>
        </div>

        <div className="bg-slate-900 rounded-lg p-4 border border-slate-800">
          <div className="flex items-center space-x-3">
            <div className="bg-purple-500/20 p-2 rounded-lg">
              <BarChart3 className="h-5 w-5 text-purple-400" />
            </div>
            <div>
              <p className="text-sm text-slate-400">Market Sentiment</p>
              <span className={`px-2 py-1 rounded-full text-xs font-medium ${getSentimentColor()}`}>
                {sentiment.toUpperCase()}
              </span>
            </div>
          </div>
        </div>

        <div className="bg-slate-900 rounded-lg p-4 border border-slate-800">
          <div className="flex items-center space-x-3">
            <div className="bg-indigo-500/20 p-2 rounded-lg">
              <Calendar className="h-5 w-5 text-indigo-400" />
            </div>
            <div>
              <p className="text-sm text-slate-400">Updates</p>
              <p className="text-sm text-white">Mon-Fri 9:00 AM</p>
            </div>
          </div>
        </div>
      </div>

      {/* Portfolio Holdings */}
      <div className="bg-slate-900 rounded-lg border border-slate-800">
        <div className="px-6 py-4 border-b border-slate-800">
          <h3 className="text-lg font-semibold text-white">Portfolio Holdings</h3>
          <p className="text-sm text-slate-400 mt-1">Live prices from Yahoo Finance & CoinGecko</p>
        </div>

        <div className="divide-y divide-slate-800">
          {portfolioData.map((asset, index) => (
            <div key={index} className="px-6 py-4 hover:bg-slate-800/50 transition-colors">
              <div className="flex justify-between items-start">
                <div className="flex-1">
                  <div className="flex items-center space-x-3">
                    <h4 className="font-semibold text-white">{asset.name}</h4>
                    <span className="text-sm text-slate-500">({asset.symbol.toUpperCase()})</span>
                    <span className={`px-2 py-0.5 rounded-full text-xs font-medium ${getRiskColor(
                      asset.allocation >= 30 ? 'Low' : asset.allocation >= 15 ? 'Medium' : 'High'
                    )}`}>
                      {asset.type === 'crypto' ? 'Crypto' : asset.type === 'stock' ? 'Stock' : 'ETF'}
                    </span>
                  </div>

                  <div className="mt-2 grid grid-cols-2 md:grid-cols-5 gap-4">
                    <div>
                      <p className="text-sm text-slate-500">Current Price</p>
                      <p className="font-medium text-white">
                        €{asset.currentPrice?.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 }) || 'N/A'}
                      </p>
                    </div>

                    <div>
                      <p className="text-sm text-slate-500">24h Change</p>
                      <p className={`font-medium ${
                        (asset.change24h || asset.change) >= 0 ? 'text-green-400' : 'text-red-400'
                      }`}>
                        {(asset.change24h || asset.change) >= 0 ? '+' : ''}
                        {(asset.change24h || asset.change)?.toFixed(2)}%
                      </p>
                    </div>

                    <div>
                      <p className="text-sm text-slate-500">Quantity</p>
                      <p className="font-medium text-white">{asset.quantity}</p>
                    </div>

                    <div>
                      <p className="text-sm text-slate-500">Value</p>
                      <p className="font-medium text-white">€{asset.value?.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}</p>
                    </div>

                    <div>
                      <p className="text-sm text-slate-500">Allocation</p>
                      <p className="font-medium text-white">{asset.allocation}%</p>
                    </div>
                  </div>
                </div>
              </div>            </div>
          ))}
        </div>
      </div>

      {/* Market News */}
      {news.length > 0 && (
        <div className="bg-slate-900 rounded-lg border border-slate-800">
          <div className="px-6 py-4 border-b border-slate-800">
            <div className="flex items-center space-x-2">
              <Newspaper className="h-5 w-5 text-indigo-400" />
              <h3 className="text-lg font-semibold text-white">Latest Market News</h3>
            </div>
          </div>

          <div className="divide-y divide-slate-800">
            {news.map((article, index) => (
              <a
                key={index}
                href={article.url}
                target="_blank"
                rel="noopener noreferrer"
                className="block px-6 py-4 hover:bg-slate-800/50 transition-colors"
              >
                <div className="flex justify-between items-start">
                  <div className="flex-1">
                    <h4 className="font-medium text-white hover:text-indigo-400 transition-colors">
                      {article.title}
                    </h4>
                    <p className="text-sm text-slate-400 mt-1 line-clamp-2">
                      {article.description}
                    </p>
                    <div className="flex items-center space-x-4 mt-2">
                      <span className="text-xs text-slate-500">{article.source}</span>
                      <span className="text-xs text-slate-500">
                        {new Date(article.publishedAt).toLocaleDateString()}
                      </span>
                    </div>
                  </div>
                </div>              </a>
            ))}
          </div>
        </div>
      )}

      {/* Disclaimer */}
      <div className="bg-yellow-500/10 border border-yellow-500/20 rounded-lg p-4">
        <div className="flex items-start space-x-3">
          <AlertTriangle className="h-5 w-5 text-yellow-400 mt-0.5" />
          <div>
            <p className="font-medium text-yellow-200">Investment Disclaimer</p>
            <p className="text-sm text-yellow-200/70 mt-1">
              This is educational research, not financial advice. All investments carry risk. 
              Past performance doesn't guarantee future results. Data is delayed (15-20 min) 
              and for informational purposes only. Always do your own research and consult a 
              licensed financial advisor before making investment decisions.
            </p>
          </div>
        </div>
      </div>
    </div>
  );
}
