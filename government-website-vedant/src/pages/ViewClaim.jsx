import React, { useState } from 'react';
import { useLocation, useNavigate, Link } from 'react-router-dom';
import axios from 'axios';

const API_BASE_URL = 'http://127.0.0.1:3000';

function Spinner() {
  return (
    <div className="animate-spin rounded-full h-5 w-5 border-b-2 border-white"></div>
  );
}

// This is the modal for rejecting a claim
function RejectModal({ onCancel, onSubmit, isLoading }) {
  const [reason, setReason] = useState('');

  const handleSubmit = () => {
    if (reason.trim()) {
      onSubmit(reason);
    } else {
      alert('Please provide a rejection reason.');
    }
  };

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4 z-50">
      <div className="bg-white rounded-xl shadow-lg max-w-md w-full p-6">
        <h3 className="text-lg font-semibold text-gray-900 mb-4">Confirm Rejection</h3>
        <div>
          <label htmlFor="reason" className="block text-sm font-medium text-gray-700 mb-2">
            Reason for Rejection
          </label>
          <textarea
            id="reason"
            rows="4"
            value={reason}
            onChange={(e) => setReason(e.target.value)}
            className="w-full p-3 border border-beige-300 rounded-lg focus:ring-2 focus:ring-green-500"
            placeholder="E.g., Evidence provided does not match satellite data..."
          />
        </div>
        <div className="flex space-x-3 justify-end mt-6">
          <button
            onClick={onCancel}
            className="px-4 py-2 border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50"
          >
            Cancel
          </button>
          <button
            onClick={handleSubmit}
            disabled={isLoading}
            className="flex justify-center items-center w-40 px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700"
          >
            {isLoading ? <Spinner /> : 'Confirm Rejection'}
          </button>
        </div>
      </div>
    </div>
  );
}

function ApproveModal({ onCancel, onSubmit, isLoading }) {
  const [amount, setAmount] = useState('');

  const handleSubmit = () => {
    const payoutAmount = parseInt(amount, 10);
    if (payoutAmount > 0) {
      onSubmit(payoutAmount);
    } else {
      alert('Please provide a valid payout amount.');
    }
  };

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4 z-50">
      <div className="bg-white rounded-xl shadow-lg max-w-md w-full p-6">
        <h3 className="text-lg font-semibold text-gray-900 mb-4">Confirm Approval</h3>
        <div>
          <label htmlFor="amount" className="block text-sm font-medium text-gray-700 mb-2">
            Payout Amount (INR)
          </label>
          <input
            id="amount"
            type="number"
            value={amount}
            onChange={(e) => setAmount(e.target.value)}
            className="w-full p-3 border border-beige-300 rounded-lg focus:ring-2 focus:ring-green-500"
            placeholder="E.g., 5000"
          />
        </div>
        <div className="flex space-x-3 justify-end mt-6">
          <button
            onClick={onCancel}
            className="px-4 py-2 border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50"
          >
            Cancel
          </button>
          <button
            onClick={handleSubmit}
            disabled={isLoading}
            className="flex justify-center items-center w-40 px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700"
          >
            {isLoading ? <Spinner /> : 'Confirm Approval'}
          </button>
        </div>
      </div>
    </div>
  );
}


export default function ViewClaim() {
  const [isRejecting, setIsRejecting] = useState(false);
  const [isApproving, setIsApproving] = useState(false);
  const [isLoading, setIsLoading] = useState(false);
  
  const location = useLocation();
  const navigate = useNavigate();
  
  const { claim } = location.state || {};

  if (!claim) {
    return (
      <div className="text-center">
        <h1 className="text-xl font-bold text-red-600">Error</h1>
        <p className="text-gray-700 mt-2">No claim data found. Please navigate from the dashboard.</p>
        <Link to="/claims" className="inline-block mt-4 text-green-600 hover:underline">
          &larr; Back to Claims Dashboard
        </Link>
      </div>
    );
  }

  // --- API Handlers ---

  const handleApprove = async (payoutAmount) => {
    setIsLoading(true);
    try {
      const body = {
        claimID: claim.claimID,
        payoutAmount: payoutAmount
      };
      await axios.post(`${API_BASE_URL}/approveClaim`, body);
      alert('Claim Approved Successfully!');
      navigate('/claims'); 
    } catch (err) {
      console.error("Error approving claim:", err);
      alert('Failed to approve claim. Check console for details.');
    }
    setIsLoading(false);
    setIsApproving(false);
  };

  const handleReject = async (reason) => {
    setIsLoading(true);
    try {
      const body = {
        claimID: claim.claimID,
        reasonForRejection: reason
      };
      await axios.post(`${API_BASE_URL}/rejectClaim`, body);
      alert('Claim Rejected Successfully!');
      navigate('/claims'); 
    } catch (err) {
      console.error("Error rejecting claim:", err);
      alert('Failed to reject claim. Check console for details.');
    }
    setIsLoading(false);
    setIsRejecting(false);
  };

  return (
    <>
      {isRejecting && (
        <RejectModal
          isLoading={isLoading}
          onCancel={() => setIsRejecting(false)}
          onSubmit={handleReject}
        />
      )}
      {isApproving && (
        <ApproveModal
          isLoading={isLoading}
          onCancel={() => setIsApproving(false)}
          onSubmit={handleApprove}
        />
      )}

      {/* Breadcrumb */}
      <nav className="flex items-center space-x-2 text-sm text-gray-600 mb-6">
        <Link to="/claims" className="hover:text-green-700">Claims Dashboard</Link>
        <span>&rsaquo;</span>
        <span className="text-gray-900 font-medium">Review Claim</span>
      </nav>

      {/* Claim Details Card */}
      <div className="bg-white rounded-xl shadow-sm border border-beige-200 p-6 md:p-8 mb-6">
        <div className="flex flex-col md:flex-row items-start justify-between mb-6">
          <div>
            <h1 className="text-3xl font-bold text-gray-900">Claim Review</h1>
            <p className="text-gray-600 mt-1">Claim ID: {claim.claimID}</p>
          </div>
          <div className="mt-4 md:mt-0 px-4 py-2 rounded-full text-sm font-medium bg-amber-100 text-amber-800">
            {claim.status}
          </div>
        </div>

        {/* Claim Info Grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 gap-x-8 gap-y-6">
          {/* Column 1 */}
          <div className="space-y-4">
            <h3 className="text-lg font-semibold text-gray-900 border-b border-beige-200 pb-2">Farmer Information</h3>
            <div>
              <label className="block text-sm font-medium text-gray-600">Farmer ID</label>
              <p className="text-gray-900 font-medium">{claim.farmerID}</p>
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-600">Farm ID</label>
              <p className="text-gray-900 font-medium">{claim.farmID}</p>
            </div>
          </div>
          
          {/* Column 2 */}
          <div className="space-y-4">
            <h3 className="text-lg font-semibold text-gray-900 border-b border-beige-200 pb-2">Calamity Details</h3>
            <div>
              <label className="block text-sm font-medium text-gray-600">Calamity Type</label>
              <p className="text-gray-900 font-medium">{claim.calamityType}</p>
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-600">Date of Calamity</label>
              <p className="text-gray-900 font-medium">{new Date(claim.dateOfCalamity).toLocaleDateString()}</p>
            </div>
          </div>

          {/* Full Width Row */}
          <div className="md:col-span-2 space-y-4 pt-4">
            <h3 className="text-lg font-semibold text-gray-900 border-b border-beige-200 pb-2">Satellite & Damage Data</h3>
            <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
              <div className="bg-beige-50 border border-beige-200 p-3 rounded-lg">
                <label className="block text-sm font-medium text-gray-600">NDVI Value</label>
                <p className="text-gray-900 text-lg font-bold">{claim.NDVIValue}</p>
              </div>
              <div className="bg-beige-50 border border-beige-200 p-3 rounded-lg">
                <label className="block text-sm font-medium text-gray-600">Damage %</label>
                <p className="text-red-600 text-lg font-bold">{claim.damagePercentage}%</p>
              </div>
              <div className="md:col-span-2 bg-beige-50 border border-beige-200 p-3 rounded-lg">
                <label className="block text-sm font-medium text-gray-600">Satellite Data Hash</label>
                <p className="text-gray-900 text-sm font-medium truncate">{claim.satelliteDataHash}</p>
              </div>
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-600">Supporting Evidence (Farmer)</label>
              <a 
                href={claim.evidenceHash} 
                target="_blank" 
                rel="noopener noreferrer"
                className="text-green-600 hover:underline font-medium"
              >
                View Uploaded Evidence
              </a>
            </div>
          </div>
        </div>
      </div>

      {/* Action Section */}
      <div className="bg-white rounded-xl shadow-sm border border-beige-200 p-6">
        <h2 className="text-xl font-semibold text-gray-900 mb-6">Verification & Decision</h2>
        <div className="border-t border-beige-200 pt-6">
          <div className="flex flex-col sm:flex-row gap-4 justify-end">
            <button 
              onClick={() => navigate('/claims')}
              className="px-6 py-3 border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50 transition-colors"
            >
              &larr; Back to Dashboard
            </button>
            <button
              onClick={() => setIsRejecting(true)}
              className="px-6 py-3 bg-red-600 text-white rounded-lg hover:bg-red-700 transition-colors"
            >
              Reject Claim
            </button>
            <button
              onClick={() => setIsApproving(true)}
              className="px-6 py-3 bg-green-600 text-white rounded-lg hover:bg-green-700 transition-colors"
            >
              Approve Claim
            </button>
          </div>
        </div>
      </div>
    </>
  );
}