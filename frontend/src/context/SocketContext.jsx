import React, { createContext, useContext, useEffect, useState } from 'react';
import io from 'socket.io-client';
import { useAuth } from './AuthContext';

const SocketContext = createContext(null);

// const SERVER_URL = import.meta.env.VITE_SOCKET_URL || '"https://backend-agas.vercel.app/';
const SERVER_URL = import.meta.env.VITE_SOCKET_URL || 'https://agas-backend-agtlp.ondigitalocean.app';
const SOCKET_PATH = import.meta.env.VITE_SOCKET_PATH || '/socket.io';

export const SocketProvider = ({ children }) => {
  const { isAuthenticated } = useAuth();
  const [socket, setSocket] = useState(null);
  const [connected, setConnected] = useState(false);
  const [gasData, setGasData] = useState(null);
  const [eventCount, setEventCount] = useState(0);
  const [connectionIssue, setConnectionIssue] = useState(null);
  const [healthStatus, setHealthStatus] = useState({
    status: 'unknown',
    lastCheck: null,
    message: null,
    loading: false,
    checks: {}
  });

  // Comprehensive backend check function
  const checkBackendHealth = async () => {
    setHealthStatus(prev => ({ ...prev, loading: true }));
    
    const checks = {
      serverReachable: { status: 'checking', message: '', timestamp: null },
      healthEndpoint: { status: 'checking', message: '', timestamp: null },
      socketConnection: { status: 'checking', message: '', timestamp: null },
      apiEndpoints: { status: 'checking', message: '', timestamp: null }
    };

    let overallStatus = 'healthy';
    const startTime = Date.now();

    // 1. Check if server is reachable
    try {
      const reachableResponse = await Promise.race([
        fetch(SERVER_URL, { method: 'HEAD' }),
        new Promise((_, reject) => 
          setTimeout(() => reject(new Error('Timeout')), 5000)
        )
      ]);
      checks.serverReachable = {
        status: 'success',
        message: 'Server is reachable',
        timestamp: Date.now() - startTime
      };
    } catch (error) {
      checks.serverReachable = {
        status: 'failed',
        message: `Server unreachable: ${error.message}`,
        timestamp: Date.now() - startTime
      };
      overallStatus = 'error';
    }

    // 2. Check /health endpoint
    try {
      const healthResponse = await Promise.race([
        fetch(`${SERVER_URL}/health`, {
          method: 'GET',
          headers: { 'Content-Type': 'application/json' }
        }),
        new Promise((_, reject) => 
          setTimeout(() => reject(new Error('Timeout')), 5000)
        )
      ]);

      if (healthResponse.ok) {
        const healthData = await healthResponse.json();
        checks.healthEndpoint = {
          status: 'success',
          message: healthData.message || 'Health endpoint OK',
          data: healthData,
          timestamp: Date.now() - startTime
        };
      } else {
        checks.healthEndpoint = {
          status: 'warning',
          message: `Health endpoint returned ${healthResponse.status}`,
          timestamp: Date.now() - startTime
        };
        overallStatus = 'unhealthy';
      }
    } catch (error) {
      checks.healthEndpoint = {
        status: 'failed',
        message: `Health endpoint error: ${error.message}`,
        timestamp: Date.now() - startTime
      };
      overallStatus = 'error';
    }

    // 3. Check Socket.IO connectivity
    try {
      const socketCheckPromise = new Promise((resolve, reject) => {
        const testSocket = io(SERVER_URL, {
          path: SOCKET_PATH,
          transports: ['websocket', 'polling'],
          timeout: 5000,
          reconnection: false
        });

        const timeout = setTimeout(() => {
          testSocket.disconnect();
          reject(new Error('Socket connection timeout'));
        }, 8000);

        testSocket.on('connect', () => {
          clearTimeout(timeout);
          testSocket.disconnect();
          resolve({ success: true, transport: testSocket.io.engine.transport.name });
        });

        testSocket.on('connect_error', (error) => {
          clearTimeout(timeout);
          testSocket.disconnect();
          reject(error);
        });
      });

      const socketResult = await socketCheckPromise;
      checks.socketConnection = {
        status: 'success',
        message: `Socket.IO connected via ${socketResult.transport}`,
        timestamp: Date.now() - startTime
      };
    } catch (error) {
      checks.socketConnection = {
        status: 'failed',
        message: `Socket.IO error: ${error.message}`,
        timestamp: Date.now() - startTime
      };
      if (overallStatus === 'healthy') overallStatus = 'unhealthy';
    }

    // 4. Check API endpoints (test common endpoints)
    const apiTests = [];
    const endpoints = ['/api/status', '/api/gas-data', '/'];
    
    for (const endpoint of endpoints) {
      try {
        const apiResponse = await Promise.race([
          fetch(`${SERVER_URL}${endpoint}`, {
            method: 'GET',
            headers: { 'Content-Type': 'application/json' }
          }),
          new Promise((_, reject) => 
            setTimeout(() => reject(new Error('Timeout')), 3000)
          )
        ]);

        apiTests.push({
          endpoint,
          status: apiResponse.status,
          ok: apiResponse.ok,
          statusText: apiResponse.statusText
        });
      } catch (error) {
        apiTests.push({
          endpoint,
          status: 'error',
          ok: false,
          error: error.message
        });
      }
    }

    const successfulApis = apiTests.filter(t => t.ok).length;
    checks.apiEndpoints = {
      status: successfulApis > 0 ? 'success' : 'warning',
      message: `${successfulApis}/${apiTests.length} API endpoints responsive`,
      details: apiTests,
      timestamp: Date.now() - startTime
    };

    // Set final status
    setHealthStatus({
      status: overallStatus,
      lastCheck: new Date().toISOString(),
      message: `Backend check complete: ${overallStatus}`,
      loading: false,
      checks: checks,
      totalTime: Date.now() - startTime
    });

    return { status: overallStatus, checks };
  };

  // Simple health check function
  const checkHealth = async () => {
    setHealthStatus(prev => ({ ...prev, loading: true }));
    
    try {
      const response = await fetch(`${SERVER_URL}/health`, {
        method: 'GET',
        headers: {
          'Content-Type': 'application/json',
        }
      });

      const data = await response.json();

      if (response.ok) {
        setHealthStatus({
          status: 'healthy',
          lastCheck: new Date().toISOString(),
          message: data.message || 'Server is healthy',
          loading: false,
          data: data,
          checks: {}
        });
      } else {
        setHealthStatus({
          status: 'unhealthy',
          lastCheck: new Date().toISOString(),
          message: data.message || 'Server returned an error',
          loading: false,
          data: data,
          checks: {}
        });
      }
    } catch (error) {
      setHealthStatus({
        status: 'error',
        lastCheck: new Date().toISOString(),
        message: error.message || 'Failed to reach server',
        loading: false,
        error: error.toString(),
        checks: {}
      });
    }
  };

  useEffect(() => {
    if (!isAuthenticated) {
      // Disconnect socket if user logs out
      if (socket) {
        socket.disconnect();
        setSocket(null);
        setConnected(false);
      }
      return;
    }

    // Initialize socket connection
    const newSocket = io(SERVER_URL, {
      path: SOCKET_PATH,
      transports: ['websocket', 'polling'],
      timeout: 15000,
      reconnection: true,
      reconnectionDelay: 1000,
      reconnectionDelayMax: 5000,
      reconnectionAttempts: Infinity
    });

    newSocket.on('connect', () => {
      console.log('Socket connected');
      setConnected(true);
      setConnectionIssue(null);
    });

    newSocket.on('disconnect', (reason) => {
      console.log('Socket disconnected:', reason);
      setConnected(false);
      setConnectionIssue(`Disconnected: ${reason}`);
    });

    newSocket.on('connect_error', (error) => {
      console.error('Socket connect error:', error.message);
      setConnected(false);
      setConnectionIssue(`Connection error: ${error.message}`);
    });

    newSocket.io.on('reconnect_attempt', (attempt) => {
      setConnectionIssue(`Reconnecting... attempt ${attempt}`);
    });

    newSocket.io.on('reconnect_failed', () => {
      setConnectionIssue('Reconnect failed. Waiting before retry.');
    });

    newSocket.on('connected', (data) => {
      console.log('Server confirmed connection:', data);
    });

    newSocket.on('gas-data-update', (data) => {
      console.log('Gas data update:', data);
      setGasData(data);
      setEventCount((prev) => prev + 1);
    });

    newSocket.on('fetch-success', (data) => {
      console.log('Fetch success:', data);
    });

    newSocket.on('fetch-error', (data) => {
      console.error('Fetch error:', data);
    });

    setSocket(newSocket);

    // Cleanup on unmount
    return () => {
      newSocket.off('connect');
      newSocket.off('disconnect');
      newSocket.off('connect_error');
      newSocket.off('connected');
      newSocket.off('gas-data-update');
      newSocket.off('fetch-success');
      newSocket.off('fetch-error');
      newSocket.io.off('reconnect_attempt');
      newSocket.io.off('reconnect_failed');
      newSocket.disconnect();
    };
  }, [isAuthenticated]);

  const fetchGasData = (apiUrl) => {
    if (socket && connected) {
      socket.emit('fetch-gas-data', { apiUrl });
    }
  };

  const value = {
    socket,
    connected,
    gasData,
    eventCount,
    connectionIssue,
    fetchGasData,
    healthStatus,
    checkHealth,
    checkBackendHealth
  };

  return <SocketContext.Provider value={value}>{children}</SocketContext.Provider>;
};

export const useSocket = () => {
  const context = useContext(SocketContext);
  if (!context) {
    throw new Error('useSocket must be used within a SocketProvider');
  }
  return context;
};
