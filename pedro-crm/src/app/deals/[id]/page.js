import { deals, partners } from '@/lib/data';
import { notFound } from 'next/navigation';

// Generate static pages for all deals
export function generateStaticParams() {
  return deals.map((deal) => ({
    id: deal.id,
  }));
}

const statusColors = {
  Lead: 'bg-gray-100 text-gray-800',
  'In Discussion': 'bg-blue-100 text-blue-800',
  'Proposal Sent': 'bg-yellow-100 text-yellow-800',
  Contracting: 'bg-purple-100 text-purple-800',
  Live: 'bg-green-100 text-green-800',
  'Closed-Lost': 'bg-red-100 text-red-800',
};

const priorityColors = {
  High: 'bg-red-100 text-red-800',
  Medium: 'bg-yellow-100 text-yellow-800',
  Low: 'bg-gray-100 text-gray-800',
};

export default function DealDetailPage({ params }) {
  const deal = deals.find((d) => d.id === params.id);

  if (!deal) {
    notFound();
  }

  const partner = partners.find((p) => p.id === deal.partnerId);

  return (
    <div>
      <div className="mb-6">
        <a href="/deals" className="text-sm text-gray-500 hover:text-gray-700">
          ← Back to Deals
        </a>
      </div>

      <div className="bg-white shadow rounded-lg">
        <div className="px-4 py-5 sm:p-6">
          <div className="flex items-start justify-between">
            <div className="flex items-center">
              <div className="flex-shrink-0 bg-indigo-100 rounded-lg p-4">
                <svg className="h-8 w-8 text-indigo-600" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M21 13.255A23.931 23.931 0 0112 15c-3.183 0-6.22-.62-9-1.745M16 6V4a2 2 0 00-2-2h-4a2 2 0 00-2 2v2m4 6h.01M5 20h14a2 2 0 002-2V8a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" />
                </svg>
              </div>
              <div className="ml-6">
                <h1 className="text-2xl font-bold text-gray-900">{deal.name}</h1>
                <p className="mt-1 text-sm text-gray-500">{deal.industry}</p>
                <div className="mt-2 flex items-center space-x-2">
                  <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${statusColors[deal.status]}`}>
                    {deal.status}
                  </span>
                  <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${priorityColors[deal.priority]}`}>
                    {deal.priority} Priority
                  </span>
                </div>
              </div>
            </div>
          </div>

          <div className="mt-8 grid grid-cols-1 gap-6 lg:grid-cols-3">
            <div className="bg-gray-50 rounded-lg p-4">
              <p className="text-sm font-medium text-gray-900">Monthly Volume</p>
              <p className="mt-2 text-lg font-semibold text-gray-900">{deal.monthlyVolume}</p>
            </div>

            <div className="bg-gray-50 rounded-lg p-4">
              <p className="text-sm font-medium text-gray-900">Potential Revenue</p>
              <p className="mt-2 text-lg font-semibold text-gray-900">{deal.potentialRevenue}</p>
            </div>

            <div className="bg-gray-50 rounded-lg p-4">
              <p className="text-sm font-medium text-gray-900">Industry</p>
              <p className="mt-2 text-lg font-semibold text-gray-900">{deal.industry}</p>
            </div>
          </div>

          {partner && (
            <div className="mt-8">
              <h3 className="text-lg font-medium text-gray-900 mb-4">Partner</h3>
              <a
                href={`/partners/${partner.id}`}
                className="block bg-gray-50 rounded-lg p-4 hover:bg-gray-100"
              >
                <p className="text-sm font-medium text-gray-900">{partner.name}</p>
                <p className="text-xs text-gray-500">{partner.type} • {partner.revenueShare} revenue share</p>
              </a>
            </div>
          )}

          <div className="mt-8">
            <h3 className="text-lg font-medium text-gray-900 mb-4">Description</h3>
            <div className="bg-gray-50 rounded-lg p-4">
              <p className="text-sm text-gray-700">{deal.description}</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
