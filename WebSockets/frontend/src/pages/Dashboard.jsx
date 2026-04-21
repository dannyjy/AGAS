import React, { useState, useEffect } from 'react';
import { useSocket } from '../context/SocketContext';
import Card from '../components/UI/Card';
import Button from '../components/UI/Button';
import styles from './Dashboard.module.css';

const Dashboard = () => {
  const { gasData, connected, connectionIssue, fetchGasData } = useSocket();
  const [stats, setStats] = useState({
    safetyLevel: 0,
    dangerRate: 0,
    warningRate: 0
  });

  useEffect(() => {
    if (gasData && gasData.data) {
      const readings = gasData.data.readings || gasData.data;
      
      // Calculate safety metrics
      const co2Level = readings.co2 || 0;
      const tempLevel = readings.temperature || 0;
      const humidityLevel = readings.humidity || 0;

      // Calculate safety level (0-100)
      let safety = 100;
      if (co2Level > 500) safety -= (co2Level - 500) / 10;
      if (tempLevel > 30) safety -= (tempLevel - 30) * 2;
      if (humidityLevel > 70) safety -= (humidityLevel - 70) * 1.5;
      safety = Math.max(0, Math.min(100, safety));

      // Calculate danger and warning rates
      const dangerRate = co2Level > 1000 || tempLevel > 40 || humidityLevel > 85 ? 
        Math.min(100, ((co2Level / 1000) + (tempLevel / 40) + (humidityLevel / 85)) * 33) : 0;
      
      const warningRate = (co2Level > 500 && co2Level < 1000) || 
        (tempLevel > 30 && tempLevel < 40) || 
        (humidityLevel > 70 && humidityLevel < 85) ?
        Math.min(100, ((co2Level / 500) + (tempLevel / 30) + (humidityLevel / 70)) * 25) : 0;

      setStats({
        safetyLevel: Math.round(safety),
        dangerRate: Math.round(dangerRate),
        warningRate: Math.round(warningRate)
      });
    }
  }, [gasData]);

  const getStatusColor = (value) => {
    if (value > 70) return 'var(--danger)';
    if (value > 40) return 'var(--warning)';
    return 'var(--success)';
  };

  const getSafetyColor = (value) => {
    if (value > 80) return 'var(--success)';
    if (value > 50) return 'var(--warning)';
    return 'var(--danger)';
  };

  const readings = gasData?.data?.readings || gasData?.data || {};

  return (
    <div className={styles.dashboard}>
      {/* Connection Status */}
      <Card variant={connected ? 'success' : 'danger'} padding="small">
        <div className={styles.connectionBanner}>
          <span className={styles.connectionIcon}>
            {connected ? '✓' : '⚠'}
          </span>
          <span className={styles.connectionText}>
            {connected ? 'Real-time monitoring active' : 'Connection lost - Attempting to reconnect...'}
          </span>
          {!connected && connectionIssue && (
            <span className={styles.connectionText}>
              {connectionIssue}
            </span>
          )}
        </div>
      </Card>

      {/* Main Stats Grid */}
      <div className={styles.statsGrid}>
        <Card variant="success" padding="large">
          <div className={styles.statCard}>
            <div className={styles.statIcon}>🛡️</div>
            <div className={styles.statContent}>
              <div className={styles.statLabel}>Safety Level</div>
              <div className={styles.statValue} style={{ color: getSafetyColor(stats.safetyLevel) }}>
                {stats.safetyLevel}%
              </div>
              <div className={styles.progressBar}>
                <div 
                  className={styles.progressFill}
                  style={{ 
                    width: `${stats.safetyLevel}%`,
                    background: getSafetyColor(stats.safetyLevel)
                  }}
                ></div>
              </div>
            </div>
          </div>
        </Card>

        <Card variant="danger" padding="large">
          <div className={styles.statCard}>
            <div className={styles.statIcon}>🚨</div>
            <div className={styles.statContent}>
              <div className={styles.statLabel}>Danger Rate</div>
              <div className={styles.statValue} style={{ color: getStatusColor(stats.dangerRate) }}>
                {stats.dangerRate}%
              </div>
              <div className={styles.progressBar}>
                <div 
                  className={styles.progressFill}
                  style={{ 
                    width: `${stats.dangerRate}%`,
                    background: getStatusColor(stats.dangerRate)
                  }}
                ></div>
              </div>
            </div>
          </div>
        </Card>

        <Card variant="warning" padding="large">
          <div className={styles.statCard}>
            <div className={styles.statIcon}>⚠️</div>
            <div className={styles.statContent}>
              <div className={styles.statLabel}>Warning Rate</div>
              <div className={styles.statValue} style={{ color: getStatusColor(stats.warningRate) }}>
                {stats.warningRate}%
              </div>
              <div className={styles.progressBar}>
                <div 
                  className={styles.progressFill}
                  style={{ 
                    width: `${stats.warningRate}%`,
                    background: getStatusColor(stats.warningRate)
                  }}
                ></div>
              </div>
            </div>
          </div>
        </Card>
      </div>

      {/* Current Readings */}
      <Card title="Current Readings" subtitle="Real-time sensor data">
        {readings && Object.keys(readings).length > 0 ? (
          <div className={styles.readingsGrid}>
            {Object.entries(readings).map(([key, value]) => (
              <div key={key} className={styles.readingItem}>
                <div className={styles.readingLabel}>{formatLabel(key)}</div>
                <div className={styles.readingValue}>
                  {typeof value === 'number' ? value.toFixed(2) : value}
                  <span className={styles.readingUnit}>{getUnit(key)}</span>
                </div>
              </div>
            ))}
          </div>
        ) : (
          <div className={styles.emptyState}>
            <div className={styles.emptyIcon}>📊</div>
            <div className={styles.emptyText}>No data available</div>
            <div className={styles.emptySubtext}>Waiting for sensor readings...</div>
          </div>
        )}
      </Card>

      {/* Last Update */}
      {gasData && (
        <Card variant="info" padding="small">
          <div className={styles.updateInfo}>
            <span className={styles.updateLabel}>Last Update:</span>
            <span className={styles.updateTime}>
              {new Date(gasData.timestamp).toLocaleString()}
            </span>
            <span className={styles.updateSource}>
              from {gasData.source}
            </span>
          </div>
        </Card>
      )}
    </div>
  );
};

const formatLabel = (key) => {
  return key
    .replace(/_/g, ' ')
    .replace(/([a-z])([A-Z])/g, '$1 $2')
    .split(' ')
    .map(word => word.charAt(0).toUpperCase() + word.slice(1))
    .join(' ');
};

const getUnit = (key) => {
  const unitMap = {
    co2: 'ppm',
    temperature: '°C',
    humidity: '%',
    pressure: 'hPa',
    o2: '%'
  };
  return unitMap[key.toLowerCase()] || '';
};

export default Dashboard;