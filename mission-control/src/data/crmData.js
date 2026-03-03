export const partners = [
  {
    id: 'emerchantpay',
    name: 'emerchantpay',
    type: 'Card Acquirer',
    status: 'Active',
    contact: 'Suzanne',
    website: 'https://www.emerchantpay.com',
    regions: ['EU (EEA)'],
    paymentMethods: ['Visa', 'Mastercard'],
    industries: ['EU Licensed Gambling', 'FX/CFD Trading', 'Adult'],
    settlementTimeframe: 'T+2',
    settlementCurrencies: ['EUR', 'GBP', 'USD', 'AUD', 'CAD'],
    rollingReserve: 'Flexible - depends on client',
    commissionShare: '30%',
    activeClients: 5,
    keyStrengths: [
      '5 active clients already processing',
      'Strong in EU licensed Gambling, FX, Adult',
      'Multiple settlement currencies',
      'Fast T+2 settlement'
    ],
    clients: [
      { 
        name: 'LFA International Ltd.', 
        description: 'EU licensed online gambling operator',
        clientId: 'client-lfa'
      },
      { 
        name: 'Yellow Social Interactive Ltd.', 
        description: 'EU licensed online gaming operator',
        clientId: 'client-yellow'
      },
      { 
        name: 'B-two Operations Ltd.', 
        description: 'EU licensed online casino operator',
        clientId: 'client-btwo'
      },
      { 
        name: 'Globex SARL', 
        description: 'EU licensed online gambling operator',
        clientId: 'client-globex'
      },
      { 
        name: 'Play Spree Ltd.', 
        description: 'EU licensed online gaming operator',
        clientId: 'client-playspree'
      }
    ],
    notes: 'First partner in CRM. Strong relationship with Suzanne.',
    lastUpdated: '2026-02-27'
  },
  {
    id: 'ofapay',
    name: 'OFAPay',
    type: 'PSP (Payment Service Provider)',
    status: 'Active',
    contact: 'Adi',
    website: 'https://ofapay.com',
    regions: ['China', 'Vietnam', 'Indonesia', 'Philippines', 'India', 'Japan', 'Korea', 'Bangladesh'],
    paymentMethods: ['Alipay', 'VietQR', 'QRIS', 'GCash', 'UPI', 'USDT', 'Local Wallets'],
    industries: ['FX', 'Gaming', 'Crypto'],
    settlementTimeframe: 'D+0 (Same Day)',
    settlementCurrencies: ['USDT Only'],
    rollingReserve: 'Standard',
    commissionShare: 'Add 0.5-2% margin on buy rates',
    activeClients: 0,
    keyStrengths: [
      '8 Asian markets with one integration',
      'Best rates: Vietnam VietQR 1.6%, Indonesia QRIS 1.7%',
      'USDT settlement only (fast, crypto-friendly)',
      '24/7 service, D+0 settlement',
      'Perfect for FX/Gaming verticals'
    ],
    clients: [],
    notes: 'New partner added March 2, 2026. Asia specialist with local payment methods. Potential margin: +1% on buy rates.',
    lastUpdated: '2026-03-02'
  }
]

export const deals = [
  // Add deals here as they come in
  // Example structure:
  // {
  //   id: 'deal-1',
  //   name: 'Client X',
  //   industry: 'Gambling',
  //   status: 'In Discussion',
  //   monthlyVolume: 2000000,
  //   monthlyRevenue: 4000,
  //   priority: 'High',
  //   partner: 'emerchantpay',
  //   nextAction: 'Follow up on pricing',
  //   lastContact: '2026-02-28'
  // }
]

export const clients = [
  {
    id: 'client-lfa',
    name: 'LFA International Ltd.',
    industry: 'Gambling / Gaming',
    status: 'Active',
    partner: 'emerchantpay',
    description: 'Online gambling/gaming operator. Details pending research.',
    geo: 'EU',
    monthlyVolume: null,
    notes: 'One of 5 active clients processing through emerchantpay'
  },
  {
    id: 'client-yellow',
    name: 'Yellow Social Interactive Ltd.',
    industry: 'Gambling / Gaming',
    status: 'Active',
    partner: 'emerchantpay',
    description: 'Online gambling/gaming operator. Details pending research.',
    geo: 'EU',
    monthlyVolume: null,
    notes: 'One of 5 active clients processing through emerchantpay'
  },
  {
    id: 'client-btwo',
    name: 'B-two Operations Ltd.',
    industry: 'Gambling / Gaming',
    status: 'Active',
    partner: 'emerchantpay',
    description: 'Online gambling/gaming operator. Details pending research.',
    geo: 'EU',
    monthlyVolume: null,
    notes: 'One of 5 active clients processing through emerchantpay'
  },
  {
    id: 'client-globex',
    name: 'Globex SARL',
    industry: 'Gambling / Gaming',
    status: 'Active',
    partner: 'emerchantpay',
    description: 'Online gambling/gaming operator. Details pending research.',
    geo: 'EU',
    monthlyVolume: null,
    notes: 'One of 5 active clients processing through emerchantpay'
  },
  {
    id: 'client-playspree',
    name: 'Play Spree Ltd.',
    industry: 'Gambling / Gaming',
    status: 'Active',
    partner: 'emerchantpay',
    description: 'Online gambling/gaming operator. Details pending research.',
    geo: 'EU',
    monthlyVolume: null,
    notes: 'One of 5 active clients processing through emerchantpay'
  }
]
