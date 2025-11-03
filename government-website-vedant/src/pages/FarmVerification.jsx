import React, { useState, useEffect } from 'react';
import axios from 'axios';

const API_BASE_URL = 'http://127.0.0.1:3000';

// Re-usable Spinner Component
function Spinner() {
  return (
    <div className="animate-spin rounded-full h-5 w-5 border-b-2 border-white"></div>
  );
}

function PageLoader() {
  return (
    <div className="flex justify-center items-center py-20">
      <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-green-600"></div>
    </div>
  );
}

export default function FarmVerification() {
  const [farms, setFarms] = useState([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState(null);
  const [verifyingId, setVerifyingId] = useState(null); // Tracks which farm is currently being verified

  // 1. Fetch all pending farms on page load
  const fetchPendingFarms = async () => {
    setIsLoading(true);
    setError(null);
    try {
      const response = await axios.get(`${API_BASE_URL}/farms/by-status/PendingVerification`);
      setFarms(response.data || []);
    } catch (err) {
      console.error("Error fetching farms:", err);
      setError("Failed to load farms. Make sure the Go backend is running.");
    }
    setIsLoading(false);
  };

  // 2. Handle the "Verify Farm" button click
  const handleVerifyFarm = async (farmID) => {
    setVerifyingId(farmID);
    try {
      await axios.post(`${API_BASE_URL}/verifyFarm/${farmID}`);
      // Success! Refresh the list to remove the verified farm.
      fetchPendingFarms();
    } catch (err) {
      console.error("Error verifying farm:", err);
      alert(`Failed to verify Farm ${farmID}.`);
    }
    setVerifyingId(null);
  };

  // Load farms when the component first mounts
  useEffect(() => {
    fetchPendingFarms();
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

    if (!farms || farms.length === 0) {
      return (
        <div className="bg-blue-50 border border-blue-200 text-blue-800 p-4 rounded-lg text-center">
          No farms are currently pending verification.
        </div>
      );
    }

    return (
      <div className="bg-white rounded-xl shadow-sm border border-beige-200 overflow-hidden">
        <table className="min-w-full divide-y divide-beige-200">
          <thead className="bg-beige-50">
            <tr>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-700 uppercase tracking-wider">Farm ID</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-700 uppercase tracking-wider">Farmer ID</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-700 uppercase tracking-wider">Crop Type</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-700 uppercase tracking-wider">Land Record</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-700 uppercase tracking-wider">Action</th>
            </tr>
          </thead>
          <tbody className="bg-white divide-y divide-beige-100">
            {farms.map((farm) => (
              <tr key={farm.farmID}>
                <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">{farm.farmID}</td>
                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-700">{farm.ownerFarmerID}</td>
                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-700">{farm.cropType}</td>
                <td className="px-6 py-4 whitespace-nowrap text-sm">
                  <a
                    href={farm.landRecordHash}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="text-blue-600 hover:text-blue-800 font-medium"
                  >
                    View Document
                  </a>
                </td>
                <td className="px-6 py-4 whitespace-nowrap text-sm">
                  <button
                    onClick={() => handleVerifyFarm(farm.farmID)}
                    disabled={verifyingId === farm.farmID}
                    className={`flex justify-center items-center w-36 px-4 py-2 font-medium rounded-lg text-white transition-colors ${
                      verifyingId === farm.farmID
                        ? 'bg-gray-400 cursor-not-allowed'
                        : 'bg-green-600 hover:bg-green-700'
                    }`}
                  >
                    {verifyingId === farm.farmID ? <Spinner /> : 'Verify Farm'}
                  </button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    );
  };

  return (
    <>
      {/* Page Header */}
      <div className="mb-6">
        <h1 className="text-3xl font-bold text-gray-900">Farm Verification</h1>
        <p className="text-gray-700 mt-1">Review and approve new farms submitted by farmers.</p>
      </div>

      {/* Content Area */}
      {renderContent()}
    </>
  );
}