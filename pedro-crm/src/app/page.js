import { partners, deals } from '@/lib/data';

export default function Dashboard() {
  const activePartners = partners.filter((p) => p.status === 'Active');
  const liveDeals = deals.filter((d) => d.status === 'Live');

  return (
    <div>
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-gray-900">Dashboard</h1>
        <p className="mt-2 text-gray-600">Overview of your payments referral business</p>
      </div>

      <div className="grid grid-cols-1 gap-5 sm:grid-cols-2 lg:grid-cols-4">
        <a href="/partners" className="bg-white overflow-hidden shadow rounded-lg hover:shadow-md">
          <div className="p-5">
            <div className="flex items-center">
              <div className="flex-shrink-0 rounded-md p-3 bg-blue-500">
                <svg className="h-6 w-6 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4" />
                </svg>
              </div>
              <div className="ml-5 w-0 flex-1">
                <dl>
                  <dt className="text-sm font-medium text-gray-500 truncate">Active Partners</dt>
                  <dd className="text-2xl font-semibold text-gray-900">{activePartners.length}</dd>
                </dl>
              </div>
            </div>
          </div>
        </a>

        <a href="/deals" className="bg-white overflow-hidden shadow rounded-lg hover:shadow-md">
          <div className="p-5">
            <div className="flex items-center">
              <div className="flex-shrink-0 rounded-md p-3 bg-green-500">
                <svg className="h-6 w-6 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
              </div>
              <div className="ml-5 w-0 flex-1">
                <dl>
                  <dt className="text-sm font-medium text-gray-500 truncate">Live Deals</dt>
                  <dd className="text-2xl font-semibold text-gray-900">{liveDeals.length}</dd>
                </dl>
              </div>
            </div>
          </div>
        </a>
      </div>

      <div className="mt-8 grid grid-cols-1 gap-8 lg:grid-cols-2">
        <div className="bg-white shadow rounded-lg">
          <div className="px-4 py-5 sm:p-6">
            <h3 className="text-lg font-medium leading-6 text-gray-900">Active Partners</h3>
            <div className="mt-4">
              <ul className="-my-4 divide-y divide-gray-200">
                {activePartners.map((partner) => (
                  <li key={partner.id} className="flex items-center py-4">
                    <div className="min-w-0 flex-1">
                      <p className="text-sm font-medium text-gray-900 truncate">{partner.name}</p>
                      <p className="text-sm text-gray-500">{partner.type} • {partner.revenueShare} revenue share</p>
                    </div>
                    <div>
                      <a href={`/partners/${partner.id}`} className="text-indigo-600 hover:text-indigo-900 text-sm font-medium">
                        View
                      </a>
                    </div>
                  </li>
                ))}
              </ul>
            </div>
          </div>
        </div>

        <div className="bg-white shadow rounded-lg">
          <div className="px-4 py-5 sm:p-6">
            <h3 className="text-lg font-medium leading-6 text-gray-900">Live Deals</h3>
            <div className="mt-4">
              <ul className="-my-4 divide-y divide-gray-200">
                {liveDeals.slice(0, 5).map((deal) => (
                  <li key={deal.id} className="flex items-center py-4">
                    <div className="min-w-0 flex-1">
                      <p className="text-sm font-medium text-gray-900 truncate">{deal.name}</p>
                      <p className="text-sm text-gray-500">{deal.industry} • {deal.potentialRevenue}</p>
                    </div>
                    <div>
                      <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-green-100 text-green-800">
                        {deal.status}
                      </span>
                    </div>
                  </li>
                ))}
              </ul>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
