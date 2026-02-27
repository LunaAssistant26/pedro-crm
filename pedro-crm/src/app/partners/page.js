import { partners } from '@/lib/data';

export default function PartnersPage() {
  return (
    <div>
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-gray-900">Partners</h1>
        <p className="mt-2 text-gray-600">Your PSPs, Acquirers, and Orchestrators</p>
      </div>

      <div className="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-3">
        {partners.map((partner) => (
          <a
            key={partner.id}
            href={`/partners/${partner.id}`}
            className="bg-white shadow rounded-lg hover:shadow-lg transition-shadow"
          >
            <div className="p-6">
              <div className="flex items-center justify-between">
                <div className="flex items-center">
                  <div className="flex-shrink-0 bg-indigo-100 rounded-lg p-3">
                    <svg className="h-6 w-6 text-indigo-600" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4" />
                    </svg>
                  </div>
                  <div className="ml-4">
                    <h3 className="text-lg font-medium text-gray-900">{partner.name}</h3>
                    <p className="text-sm text-gray-500">{partner.type}</p>
                  </div>
                </div>
                <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${
                  partner.status === 'Active'
                    ? 'bg-green-100 text-green-800'
                    : 'bg-gray-100 text-gray-800'
                }`}>
                  {partner.status}
                </span>
              </div>

              <div className="mt-4">
                <div className="flex items-center text-sm text-gray-500">
                  <svg className="flex-shrink-0 mr-1.5 h-4 w-4 text-gray-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" />
                  </svg>
                  {partner.contact}
                </div>
              </div>

              <div className="mt-4 pt-4 border-t border-gray-100">
                <div className="text-sm">
                  <span className="font-medium text-gray-900">Revenue Share:</span>{' '}
                  <span className="text-gray-600">{partner.revenueShare}</span>
                </div>
              </div>

              <div className="mt-4">
                <div className="flex flex-wrap gap-1">
                  {partner.industries.slice(0, 3).map((industry) => (
                    <span
                      key={industry}
                      className="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium bg-gray-100 text-gray-800"
                    >
                      {industry}
                    </span>
                  ))}
                </div>
              </div>
            </div>
          </a>
        ))}
      </div>
    </div>
  );
}
