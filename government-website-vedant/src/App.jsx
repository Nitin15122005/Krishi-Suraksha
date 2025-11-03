import React from 'react';
import { Routes, Route, NavLink, useNavigate, Navigate } from 'react-router-dom';
import { useAuth } from './context/AuthContext';

// Import Pages
import FarmVerification from './pages/FarmVerification';
import ClaimsDashboard from './pages/ClaimsDashboard';
import ViewClaim from './pages/ViewClaim';
import LoginPage from './pages/LoginPage';


function NavItem({ to, children }) {
  const activeStyle = "bg-green-100 text-green-700";
  const inactiveStyle = "text-gray-600 hover:bg-beige-100 hover:text-gray-800";
  return (
    <NavLink
      to={to}
      className={({ isActive }) =>
        `px-3 py-2 rounded-md text-sm font-medium transition-colors ${isActive ? activeStyle : inactiveStyle}`
      }
    >
      {children}
    </NavLink>
  );
}

// This is the main layout with the header and navigation
function MainLayout({ children }) {
  const { user, logout } = useAuth();
  const navigate = useNavigate();

  const handleLogout = () => {
    logout();
    navigate('/login');
  };

  return (
    <div className="min-h-screen bg-beige-50">
      <header className="bg-white shadow-sm border-b border-beige-200 sticky top-0 z-10">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center h-16">
            <div className="flex-shrink-0 flex items-center">
              <span className="text-xl font-bold text-green-700">Krishi Suraksha</span>
              <span className="ml-4 pl-4 border-l border-gray-300 text-gray-800 font-medium hidden sm:block">
                Admin Portal
              </span>
            </div>
            <nav className="flex items-center space-x-2 sm:space-x-4">
              <NavItem to="/">Farm Verification</NavItem>
              <NavItem to="/claims">Claim Verification</NavItem>
              <button
                onClick={handleLogout}
                className="px-3 py-2 rounded-md text-sm font-medium text-gray-600 hover:bg-red-50 hover:text-red-700"
              >
                Logout ({user.name})
              </button>
            </nav>
          </div>
        </div>
      </header>
      <main className="max-w-7xl mx-auto p-6 lg:p-8">
        {children}
      </main>
    </div>
  );
}

// This component handles all the routing logic
export default function App() {
  const { user } = useAuth();
  
  // If the user is not logged in, show a different set of routes
  // This prevents the main layout from appearing on the login page
  if (!user) {
    return (
      <Routes>
        <Route path="/login" element={<LoginPage />} />
        {/* Any other path redirects to login */}
        <Route path="*" element={<Navigate to="/login" />} /> 
      </Routes>
    );
  }

  // If the user IS logged in, show the main app
  return (
    <MainLayout>
      <Routes>
        <Route path="/" element={<FarmVerification />} />
        <Route path="/claims" element={<ClaimsDashboard />} />
        <Route path="/claim/:claimId" element={<ViewClaim />} />
        {/* Any other path redirects to home */}
        <Route path="*" element={<Navigate to="/" />} />
      </Routes>
    </MainLayout>
  );
}