import React, { useState, useEffect } from 'react';
import axios from 'axios';
import { Link } from 'react-router-dom'; 

const API_BASE_URL = 'http://127.0.0.1:3000';

function PageLoader() {
  return (
    <div className="flex justify-center items-center py-20">
      <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-green-600"></div>
    </div>
  );
}

// This component shows the 4 summary cards
function DashboardSummary({ claims }) {
  const pending = claims.filter(c => c.status === 'FlaggedForReview').length;
  // We only get flagged claims, so total is just the length
  const totalFlagged = claims.length;

  // We don't have Approved/Rejected data from this endpoint, so we'll just show what we have.
  return (
    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
      <div className="bg-white rounded-xl shadow-sm border border-beige-200 p-6">
        <div className="flex items-center">
          <div className="p-3 bg-amber-50 rounded-lg">
            <span className="text-amber-600 text-2xl">⏳</span>
          </div>
          <div className="ml-4">
            <p className="text-sm font-medium text-gray-700">Pending Review</p>
            <h3 id="pendingClaims" className="text-2xl font-bold text-gray-900">{pending}</h3>
          </div>
        </div>
      </div>
      
      <div className="bg-white rounded-xl shadow-sm border border-beige-200 p-6">
        <div className="flex items-center">
          <div className="p-3 bg-green-50 rounded-lg">
            <span className="text-green-600 text-2xl">📋</span>
          </div>
          <div className="ml-4">
            <p className="text-sm font-medium text-gray-700">Total Flagged Claims</p>
            <h3 id="totalClaims" className="text-2xl font-bold text-gray-900">{totalFlagged}</h3>
          </div>
        </div>
      </div>
      
      {/* These are placeholders, as our API only returns pending claims */}
      <div className="bg-white rounded-xl shadow-sm border border-beige-200 p-6">
        <div className="flex items-center">
          <div className="p-3 bg-blue-50 rounded-lg">
            <span className="text-blue-600 text-2xl">✅</span>
          </div>
          <div className="ml-4">
            <p className="text-sm font-medium text-gray-700">Approved (All time)</p>
            <h3 id="approvedClaims" className="text-2xl font-bold text-gray-900">--</h3>
          </div>
        </div>
      </div>

      <div className="bg-white rounded-xl shadow-sm border border-beige-200 p-6">
        <div className="flex items-center">
          <div className="p-3 bg-brown-50 rounded-lg">
            <span className="text-brown-600 text-2xl">❌</span>
          </div>
          <div className="ml-4">
            <p className="text-sm font-medium text-gray-700">Rejected (All time)</p>
            <h3 id="rejectedClaims" className="text-2xl font-bold text-gray-900">--</h3>
          </div>
        </div>
      </div>
    </div>
  );
}

// This component shows the list of claims
function ClaimsTable({ claims }) {
  if (claims.length === 0) {
    return (
      <div className="bg-blue-50 border border-blue-200 text-blue-800 p-4 rounded-lg text-center">
        No claims are currently flagged for review.
      </div>
    );
  }

  return (
    <div className="bg-white rounded-xl shadow-sm border border-beige-200 overflow-hidden">
      <table className="min-w-full divide-y divide-beige-200">
        <thead className="bg-beige-50">
          <tr>
            <th className="px-6 py-3 text-left text-xs font-medium text-gray-700 uppercase tracking-wider">Claim ID</th>
            <th className="px-6 py-3 text-left text-xs font-medium text-gray-700 uppercase tracking-wider">Farmer ID</th>
            <th className="px-6 py-3 text-left text-xs font-medium text-gray-700 uppercase tracking-wider">Farm ID</th>
            <th className="px-6 py-3 text-left text-xs font-medium text-gray-700 uppercase tracking-wider">Calamity</th>
            <th className="px-6 py-3 text-left text-xs font-medium text-gray-700 uppercase tracking-wider">Status</th>
            <th className="px-6 py-3 text-left text-xs font-medium text-gray-700 uppercase tracking-wider">Action</th>
          </tr>
        </thead>
        <tbody className="bg-white divide-y divide-beige-100">
          {claims.map((claim) => (
            <tr key={claim.claimID}>
              <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">{claim.claimID}</td>
              <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-700">{claim.farmerID}</td>
              <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-700">{claim.farmID}</td>
              <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-700">{claim.calamityType}</td>
              <td className="px-6 py-4 whitespace-nowrap text-sm">
                <span className="px-2 py-1 inline-flex text-xs leading-5 font-semibold rounded-full bg-amber-100 text-amber-800">
                  {claim.status}
                </span>
              </td>
              <td className="px-6 py-4 whitespace-nowrap text-sm">
                {/* This Link component is from react-router-dom.
                  It will navigate to the /claim/:claimID page.
                  The `state` prop passes the entire claim object to the next page,
                  so we don't have to re-fetch it.
                */}
                <Link
                  to={`/claim/${claim.claimID}`}
                  state={{ claim: claim }}
                  className="text-green-600 hover:text-green-800 font-medium"
                >
                  Review Claim
                </Link>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}


export default function ClaimsDashboard() {
  const [claims, setClaims] = useState([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState(null);

  const fetchFlaggedClaims = async () => {
    setIsLoading(true);
    setError(null);
    try {
      const response = await axios.get(`${API_BASE_URL}/claims/by-status/FlaggedForReview`);
      setClaims(response.data || []);
    } catch (err) {
      console.error("Error fetching claims:", err);
      setError("Failed to load claims. Make sure the Go backend is running.");
    }
    setIsLoading(false);
  };

  useEffect(() => {
    fetchFlaggedClaims();
  }, []);

  const renderContent = () => {
    if (isLoading) {
      return <PageLoader />;
    }

    if (error) {
      return (
        <div className="bg-brown-50 border border-brown-200 text-brown-800 p-4 rounded-lg text-center">
          {error}
        </div>
      );
    }

    return (
      <>
        <DashboardSummary claims={claims} />
        
        {/* Claims List Section */}
        <div className="mb-6">
          <h2 className="text-2xl font-bold text-gray-900">Claims for Review</h2>
          <p className="text-gray-700 mt-1">Review and take action on claims flagged for manual verification.</p>
        </div>
        <ClaimsTable claims={claims} />
      </>
    );
  };

  return (
    <>
      {/* Page Header */}
      <div className="mb-6">
        <h1 className="text-3xl font-bold text-gray-900">Claim Management Dashboard</h1>
        <p className="text-gray-700 mt-1">Monitor and manage all flagged claims.</p>
      </div>

      {/* Content Area */}
      {renderContent()}
    </>
  );
}