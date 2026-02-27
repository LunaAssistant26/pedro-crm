import { deals, partners } from '@/lib/data';

const statusColors = {
  Lead: 'bg-gray-100 text-gray-800',
  'In Discussion': 'bg-blue-100 text-blue-800',
  'Proposal Sent': 'bg-yellow-100 text-yellow-800',
  Contracting: 'bg-purple-100 text-purple-800',
  Live: 'bg-green-100 text-green-800',
  'Closed-Lost': 'bg-red-100 text-red-800',
};

export default function DealsPage() {
  return (
    <div>
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-gray-900">Deals</h1>
        <p className="mt-2 text-gray-600">Track your referral deals and pipeline</p>
      </div>

      <div className="bg-white shadow rounded-lg">
        <div className="px-4 py-5 sm:p-6">
          <h3 className="text-lg font-medium leading-6 text-gray-900 mb-4">All Deals</h3>
          <div className="divide-y divide-gray-200">
            {deals.map((deal) => {
              const partner = partners.find((p) => p.id === deal.partnerId);
              return (
                <a
                  key={deal.id}
                  href={`/deals/${deal.id}`}
                  className="block hover:bg-gray-50"
                >
                  <div className="px-4 py-4">
                    <div className="flex items-center justify-between">
                      <div className="flex items-center">
                        <div className="flex-shrink-0 bg-indigo-100 rounded-lg p-2">
                          <svg className="h-5 w-5 text-indigo-600" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M21 13.255A23.931 23.931 0 0112 15c-3.183 0-6.22-.62-9-1.745M16 6V4a2 2 0 00-2-2h-4a2 2 0 00-2 2v2m4 6h.01M5 20h14a2 2 0 002-2V8a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" />
                          </svg>
                        </div>
                        <div className="ml-4">
                          <p className="text-sm font-medium text-gray-900">{deal.name}</p>
                          <p className="text-sm text-gray-500">{deal.industry}</p>
                        </div>
                      </div>
                      <div className="flex items-center space-x-4">
                        {partner && (
                          <div className="text-sm text-gray-500">{partner.name}</div>
                        )}
                        <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${statusColors[deal.status]}`}>
                          {deal.status}
                        </span>
                      </div>
                    </div>
                  </div>
                </a>
              );
            })}
          </div>
        </div>
      </div>
    </div>
  );
}
