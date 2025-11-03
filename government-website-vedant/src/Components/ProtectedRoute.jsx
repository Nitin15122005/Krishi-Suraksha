import React from 'react';
import { useAuth } from '../context/AuthContext';
import { Navigate } from 'react-router-dom';

export default function ProtectedRoute({ children }) {
  const { user } = useAuth();

  if (!user) {
    // If user is not logged in, redirect them to the /login page
    return <Navigate to="/login" />;
  }

  return children;
}