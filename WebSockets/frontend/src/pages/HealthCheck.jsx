import React, { useEffect } from 'react';
import { useSocket } from '../context/SocketContext';
import Card from '../components/UI/Card';
import Button from '../components/UI/Button';
import styles from './HealthCheck.module.css';

const HealthCheck = () => {
  const { healthStatus, checkBackendHealth, checkHealth } = useSocket();

  // Run comprehensive check on mount
  useEffect(() => {
    checkBackendHealth();
  }, []);

  const getStatusIcon = (status) => {
    switch (status) {
      case 'success':
        return '✅';
      case 'failed':
        return '❌';
      case 'warning':
        return '⚠️';
      case 'checking':
        return '🔄';
      default:
        return '❓';
    }
  };

  const getStatusColor = (status) => {
    switch (status) {
      case 'healthy':
      case 'success':
        return '#22c55e';
      case 'unhealthy':
      case 'warning':
        return '#f59e0b';
      case 'error':
      case 'failed':
        return '#ef4444';
      default:
        return '#6b7280';
    }
  };

  return (
    <div className={styles.container}>
      <div className={styles.header}>
        <h1>Backend Health Check</h1>
        <div className={styles.actions}>
          <Button onClick={checkHealth} disabled={healthStatus.loading}>
            Quick Health Check
          </Button>
          <Button onClick={checkBackendHealth} disabled={healthStatus.loading}>
            Full Backend Check
          </Button>
        </div>
      </div>

      {healthStatus.loading && (
        <Card>
          <div className={styles.loading}>
            <div className={styles.spinner}></div>
            <p>Running comprehensive backend checks...</p>
          </div>
        </Card>
      )}

      {!healthStatus.loading && healthStatus.status !== 'unknown' && (
        <div className={styles.results}>
          <Card>
            <div className={styles.summary}>
              <h2>Overall Status</h2>
              <div 
                className={styles.statusBadge}
                style={{ backgroundColor: getStatusColor(healthStatus.status) }}
              >
                {healthStatus.status.toUpperCase()}
              </div>
              <p className={styles.message}>{healthStatus.message}</p>
              <div className={styles.meta}>
                <span>Last Check: {new Date(healthStatus.lastCheck).toLocaleString()}</span>
                {healthStatus.totalTime && (
                  <span>Total Time: {healthStatus.totalTime}ms</span>
                )}
              </div>
            </div>
          </Card>

          {healthStatus.checks && Object.keys(healthStatus.checks).length > 0 && (
            <div className={styles.checks}>
              <h2>Detailed Checks</h2>
              
              {Object.entries(healthStatus.checks).map(([key, check]) => (
                <Card key={key}>
                  <div className={styles.check}>
                    <div className={styles.checkHeader}>
                      <span className={styles.checkIcon}>
                        {getStatusIcon(check.status)}
                      </span>
                      <h3>{key.replace(/([A-Z])/g, ' $1').trim()}</h3>
                      {check.timestamp && (
                        <span className={styles.timing}>{check.timestamp}ms</span>
                      )}
                    </div>
                    <p className={styles.checkMessage}>{check.message}</p>
                    
                    {check.data && (
                      <details className={styles.details}>
                        <summary>View Response Data</summary>
                        <pre>{JSON.stringify(check.data, null, 2)}</pre>
                      </details>
                    )}
                    
                    {check.details && Array.isArray(check.details) && (
                      <div className={styles.apiTests}>
                        <h4>API Endpoints Tested:</h4>
                        <table>
                          <thead>
                            <tr>
                              <th>Endpoint</th>
                              <th>Status</th>
                              <th>Result</th>
                            </tr>
                          </thead>
                          <tbody>
                            {check.details.map((api, idx) => (
                              <tr key={idx}>
                                <td><code>{api.endpoint}</code></td>
                                <td>
                                  <span 
                                    className={styles.statusCode}
                                    style={{ 
                                      color: api.ok ? '#22c55e' : '#ef4444' 
                                    }}
                                  >
                                    {api.status}
                                  </span>
                                </td>
                                <td>{api.statusText || api.error || 'N/A'}</td>
                              </tr>
                            ))}
                          </tbody>
                        </table>
                      </div>
                    )}
                  </div>
                </Card>
              ))}
            </div>
          )}

          {healthStatus.data && !healthStatus.checks && (
            <Card>
              <div className={styles.rawData}>
                <h3>Health Response</h3>
                <pre>{JSON.stringify(healthStatus.data, null, 2)}</pre>
              </div>
            </Card>
          )}
        </div>
      )}

      {healthStatus.status === 'unknown' && !healthStatus.loading && (
        <Card>
          <div className={styles.empty}>
            <p>Click a button above to check backend health</p>
          </div>
        </Card>
      )}
    </div>
  );
};

export default HealthCheck;
