// Financial Data Service
// Aggregates data from multiple APIs for the Financial Advisor

const ALPHA_VANTAGE_BASE = 'https://www.alphavantage.co/query';
const COINGECKO_BASE = 'https://api.coingecko.com/api/v3';
const NEWSAPI_BASE = 'https://newsapi.org/v2';

// Cache to avoid hitting API limits
const cache = new Map();
const CACHE_DURATION = 5 * 60 * 1000; // 5 minutes

function getCached(key) {
  const cached = cache.get(key);
  if (cached && Date.now() - cached.timestamp < CACHE_DURATION) {
    return cached.data;
  }
  return null;
}

function setCached(key, data) {
  cache.set(key, { data, timestamp: Date.now() });
}

// Alpha Vantage - Stock/ETF Quotes
export async function getStockQuote(symbol, apiKey) {
  const cacheKey = `stock_${symbol}`;
  const cached = getCached(cacheKey);
  if (cached) return cached;

  try {
    const response = await fetch(
      `${ALPHA_VANTAGE_BASE}?function=GLOBAL_QUOTE&symbol=${symbol}&apikey=${apiKey}`
    );
    const data = await response.json();
    const quote = data['Global Quote'];
    
    const result = {
      symbol: quote['01. symbol'],
      price: parseFloat(quote['05. price']),
      change: parseFloat(quote['09. change']),
      changePercent: quote['10. change percent'],
      volume: parseInt(quote['06. volume']),
      lastUpdated: quote['07. latest trading day']
    };
    
    setCached(cacheKey, result);
    return result;
  } catch (error) {
    console.error('Alpha Vantage error:', error);
    return null;
  }
}

// Alpha Vantage - Company Overview
export async function getCompanyOverview(symbol, apiKey) {
  const cacheKey = `overview_${symbol}`;
  const cached = getCached(cacheKey);
  if (cached) return cached;

  try {
    const response = await fetch(
      `${ALPHA_VANTAGE_BASE}?function=OVERVIEW&symbol=${symbol}&apikey=${apiKey}`
    );
    const data = await response.json();
    
    const result = {
      symbol: data.Symbol,
      name: data.Name,
      sector: data.Sector,
      industry: data.Industry,
      marketCap: data.MarketCapitalization,
      peRatio: data.PERatio,
      dividendYield: data.DividendYield,
      description: data.Description
    };
    
    setCached(cacheKey, result);
    return result;
  } catch (error) {
    console.error('Company overview error:', error);
    return null;
  }
}

// CoinGecko - Crypto Prices
export async function getCryptoPrice(coinId, currency = 'eur') {
  const cacheKey = `crypto_${coinId}_${currency}`;
  const cached = getCached(cacheKey);
  if (cached) return cached;

  try {
    const response = await fetch(
      `${COINGECKO_BASE}/simple/price?ids=${coinId}&vs_currencies=${currency}&include_24hr_change=true`
    );
    const data = await response.json();
    
    const result = {
      coin: coinId,
      price: data[coinId][currency],
      change24h: data[coinId][`${currency}_24h_change`]
    };
    
    setCached(cacheKey, result);
    return result;
  } catch (error) {
    console.error('CoinGecko error:', error);
    return null;
  }
}

// CoinGecko - Crypto Market Data
export async function getCryptoMarketData(coinId) {
  const cacheKey = `crypto_market_${coinId}`;
  const cached = getCached(cacheKey);
  if (cached) return cached;

  try {
    const response = await fetch(
      `${COINGECKO_BASE}/coins/${coinId}?localization=false&tickers=false&market_data=true&community_data=false&developer_data=false`
    );
    const data = await response.json();
    
    const result = {
      name: data.name,
      symbol: data.symbol,
      currentPrice: data.market_data.current_price.eur,
      marketCap: data.market_data.market_cap.eur,
      volume24h: data.market_data.total_volume.eur,
      high24h: data.market_data.high_24h.eur,
      low24h: data.market_data.low_24h.eur,
      priceChange24h: data.market_data.price_change_24h,
      priceChangePercentage24h: data.market_data.price_change_percentage_24h,
      ath: data.market_data.ath.eur,
      athDate: data.market_data.ath_date.eur,
      atl: data.market_data.atl.eur
    };
    
    setCached(cacheKey, result);
    return result;
  } catch (error) {
    console.error('Crypto market data error:', error);
    return null;
  }
}

// NewsAPI - Financial News
export async function getFinancialNews(query = 'stocks OR crypto OR investing', apiKey) {
  const cacheKey = `news_${query}`;
  const cached = getCached(cacheKey);
  if (cached) return cached;

  try {
    const today = new Date().toISOString().split('T')[0];
    const response = await fetch(
      `${NEWSAPI_BASE}/everything?q=${encodeURIComponent(query)}&from=${today}&sortBy=publishedAt&language=en&apiKey=${apiKey}`
    );
    const data = await response.json();
    
    const result = data.articles.slice(0, 5).map(article => ({
      title: article.title,
      description: article.description,
      url: article.url,
      publishedAt: article.publishedAt,
      source: article.source.name
    }));
    
    setCached(cacheKey, result);
    return result;
  } catch (error) {
    console.error('NewsAPI error:', error);
    return null;
  }
}

// Technical Analysis - Simple Moving Average
export async function getSMA(symbol, interval = 'daily', timePeriod = 50, apiKey) {
  const cacheKey = `sma_${symbol}_${timePeriod}`;
  const cached = getCached(cacheKey);
  if (cached) return cached;

  try {
    const response = await fetch(
      `${ALPHA_VANTAGE_BASE}?function=SMA&symbol=${symbol}&interval=${interval}&time_period=${timePeriod}&series_type=close&apikey=${apiKey}`
    );
    const data = await response.json();
    
    const smaData = data['Technical Analysis: SMA'];
    const latestDate = Object.keys(smaData)[0];
    
    const result = {
      symbol,
      period: timePeriod,
      sma: parseFloat(smaData[latestDate]['SMA']),
      date: latestDate
    };
    
    setCached(cacheKey, result);
    return result;
  } catch (error) {
    console.error('SMA error:', error);
    return null;
  }
}

// Portfolio Analysis
export async function analyzePortfolio(portfolio, alphaVantageKey) {
  const analysis = {
    totalValue: 0,
    dailyChange: 0,
    assets: [],
    lastUpdated: new Date().toISOString()
  };

  for (const asset of portfolio) {
    let data;
    
    if (asset.type === 'crypto') {
      data = await getCryptoPrice(asset.id);
    } else {
      data = await getStockQuote(asset.symbol, alphaVantageKey);
    }

    if (data) {
      const value = data.price * asset.quantity;
      const dailyChange = data.change24h || data.change || 0;
      
      analysis.assets.push({
        ...asset,
        currentPrice: data.price,
        value,
        dailyChange,
        dailyChangePercent: asset.type === 'crypto' 
          ? data.change24h 
          : (data.change / (data.price - data.change)) * 100
      });
      
      analysis.totalValue += value;
      analysis.dailyChange += dailyChange * asset.quantity;
    }
  }

  return analysis;
}

// Market Sentiment Analysis (based on news)
export function analyzeSentiment(newsArticles) {
  if (!newsArticles || newsArticles.length === 0) return 'neutral';
  
  const positiveWords = ['surge', 'rally', 'gain', 'growth', 'bull', 'moon', 'breakout', ' ATH'];
  const negativeWords = ['crash', 'drop', 'bear', 'dump', 'fear', 'recession', 'sell-off', 'loss'];
  
  let score = 0;
  
  newsArticles.forEach(article => {
    const text = `${article.title} ${article.description}`.toLowerCase();
    
    positiveWords.forEach(word => {
      if (text.includes(word)) score++;
    });
    
    negativeWords.forEach(word => {
      if (text.includes(word)) score--;
    });
  });
  
  if (score > 2) return 'bullish';
  if (score < -2) return 'bearish';
  return 'neutral';
}

// Export for use in components
export default {
  getStockQuote,
  getCompanyOverview,
  getCryptoPrice,
  getCryptoMarketData,
  getFinancialNews,
  getSMA,
  analyzePortfolio,
  analyzeSentiment
};
