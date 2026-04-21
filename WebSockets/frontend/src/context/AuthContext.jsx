import React, { createContext, useContext, useState, useEffect } from 'react';

const AuthContext = createContext(null);

// Default credentials (hardcoded for now)
const DEFAULT_CREDENTIALS = {
  serialNumber: 'AGAS-2026-001',
  password: 'admin123'
};

export const AuthProvider = ({ children }) => {
  const [user, setUser] = useState(null);
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [loading, setLoading] = useState(true);

  // Check if user is already logged in (from localStorage)
  useEffect(() => {
    const storedUser = localStorage.getItem('agas_user');
    if (storedUser) {
      try {
        const userData = JSON.parse(storedUser);
        setUser(userData);
        setIsAuthenticated(true);
      } catch (error) {
        localStorage.removeItem('agas_user');
      }
    }
    setLoading(false);
  }, []);

  const login = (serialNumber, password) => {
    // Validate credentials
    if (
      serialNumber === DEFAULT_CREDENTIALS.serialNumber &&
      password === DEFAULT_CREDENTIALS.password
    ) {
      const userData = {
        serialNumber,
        name: 'Gas Monitoring User',
        email: 'user@agas.com',
        location: 'Lab Building A',
        deviceType: 'Gas Sensor v2',
        registeredDate: '2026-01-15',
        lastLogin: new Date().toISOString()
      };

      setUser(userData);
      setIsAuthenticated(true);
      localStorage.setItem('agas_user', JSON.stringify(userData));
      return { success: true };
    } else {
      return { success: false, error: 'Invalid serial number or password' };
    }
  };

  const logout = () => {
    setUser(null);
    setIsAuthenticated(false);
    localStorage.removeItem('agas_user');
  };

  const value = {
    user,
    isAuthenticated,
    loading,
    login,
    logout
  };

  if (loading) {
    return (
      <div style={{ 
        display: 'flex', 
        justifyContent: 'center', 
        alignItems: 'center', 
        height: '100vh',
        background: 'var(--secondary-bg)'
      }}>
        <div style={{ 
          fontSize: '1.5rem', 
          color: 'var(--primary-gray)',
          fontWeight: 600
        }}>
          Loading...
        </div>
      </div>
    );
  }

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
};

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
};
