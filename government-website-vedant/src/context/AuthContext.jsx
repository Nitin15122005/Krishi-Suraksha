import React, { createContext, useState, useContext } from 'react';
import axios from 'axios';

const API_BASE_URL = 'http://127.0.0.1:3000';

const AuthContext = createContext(null);

export function useAuth() {
  return useContext(AuthContext);
}

export function AuthProvider({ children }) {
  const [user, setUser] = useState(JSON.parse(localStorage.getItem('user')));

  const login = async (email, password) => {
    try {
      const response = await axios.post(`${API_BASE_URL}/loginGov`, {
        email,
        password,
      });
      const userData = response.data;
      localStorage.setItem('user', JSON.stringify(userData));
      setUser(userData);
      return true; 
    } catch (error) {
      console.error('Login failed:', error.response.data.error);
      throw new Error(error.response.data.error || 'Login failed');
    }
  };

  const logout = () => {
    localStorage.removeItem('user');
    setUser(null);
  };

  const value = { user, login, logout };

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}