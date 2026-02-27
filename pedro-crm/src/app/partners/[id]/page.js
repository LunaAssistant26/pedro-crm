import { partners, deals } from '@/lib/data';
import { notFound } from 'next/navigation';

// Generate static pages for all partners
export function generateStaticParams() {
  return partners.map((partner) => ({
    id: partner.id,
  }));
}

export default function PartnerDetailPage({ params }) {
  const partner = partners.find((p) => p.id === params.id);

  if (!partner) {
    notFound();
  }

  const partnerDeals = deals.filter((d) => d.partnerId === partner.id);

  return (
    <div>
      <div className="mb-6">
        <a href="/partners" className="text-sm text-gray-500 hover:text-gray-700">
          ← Back to Partners
        </a>
      </div>

      <div className="bg-white shadow rounded-lg">
        <div className="px-4 py-5 sm:p-6">
          <div className="flex items-center justify-between">
            <div className="flex items-center">
              <div className="flex-shrink-0 bg-indigo-100 rounded-lg p-4">
                <svg className="h-8 w-8 text-indigo-600" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4" />
                </svg>
              </div>
              <div className="ml-6">
                <h1 className="text-2xl font-bold text-gray-900">{partner.name}</h1>
                <p className="mt-1 text-sm text-gray-500">{partner.type} • {partner.status}</p>
              </div>
            </div>
            <a
              href={partner.website}
              target="_blank"
              rel="noopener noreferrer"
              className="inline-flex items-center px-4 py-2 border border-gray-300 shadow-sm text-sm font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50"
            >
              Website
            </a>
          </div>

          <div className="mt-8 grid grid-cols-1 gap-6 lg:grid-cols-2">
            <div>
              <h3 className="text-lg font-medium text-gray-900 mb-4">Contact</h3>
              <div className="bg-gray-50 rounded-lg p-4">
                <p className="text-sm text-gray-900">{partner.contact}</p>
              </div>
            </div>

            <div>
              <h3 className="text-lg font-medium text-gray-900 mb-4">Pricing</h3>
              <div className="bg-gray-50 rounded-lg p-4">
                <p className="text-sm"><span className="font-medium">Revenue Share:</span> {partner.revenueShare}</p>
              </div>
            </div>
          </div>

          <div className="mt-8">
            <h3 className="text-lg font-medium text-gray-900 mb-4">Capabilities</h3>
            <div className="bg-gray-50 rounded-lg p-4">
              <p className="text-sm font-medium">Countries:</p>
              <ul className="mt-2 text-sm text-gray-700">
                {partner.countries.map((country) => (
                  <li key={country}>{country}</li>
                ))}
              </ul>
              <p className="text-sm font-medium mt-4">Industries:</p>
              <ul className="mt-2 text-sm text-gray-700">
                {partner.industries.map((industry) => (
                  <li key={industry}>{industry}</li>
                ))}
              </ul>
            </div>
          </div>

          {partnerDeals.length > 0 && (
            <div className="mt-8">
              <h3 className="text-lg font-medium text-gray-900 mb-4">Active Deals ({partnerDeals.length})</h3>
              <div className="space-y-3">
                {partnerDeals.map((deal) => (
                  <a
                    key={deal.id}
                    href={`/deals/${deal.id}`}
                    className="block bg-gray-50 rounded-lg p-4 hover:bg-gray-100"
                  >
                    <p className="text-sm font-medium text-gray-900">{deal.name}</p>
                    <p className="text-xs text-gray-500">{deal.industry}</p>
                  </a>
                ))}
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
