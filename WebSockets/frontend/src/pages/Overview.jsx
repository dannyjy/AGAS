import React, { useState, useEffect } from 'react';
import { useSocket } from '../context/SocketContext';
import Card from '../components/UI/Card';
import styles from './Overview.module.css';

const Overview = () => {
  const { gasData } = useSocket();
  const [dailyStats, setDailyStats] = useState({ avg: 0, max: 0, min: 0, count: 0 });
  const [monthlyStats, setMonthlyStats] = useState({ avg: 0, max: 0, min: 0, count: 0 });
  const [yearlyStats, setYearlyStats] = useState({ avg: 0, max: 0, min: 0, count: 0 });

  useEffect(() => {
    // Simulate data aggregation (in production, this would come from backend)
    if (gasData && gasData.data) {
      const readings = gasData.data.readings || gasData.data;
      const co2 = readings.co2 || 0;
      
      // Daily stats
      setDailyStats({
        avg: co2,
        max: Math.max(co2, dailyStats.max || 0),
        min: dailyStats.min === 0 ? co2 : Math.min(co2, dailyStats.min),
        count: dailyStats.count + 1
      });

      // Monthly stats (simulated)
      setMonthlyStats({
        avg: (monthlyStats.avg * monthlyStats.count + co2) / (monthlyStats.count + 1),
        max: Math.max(co2, monthlyStats.max || 0),
        min: monthlyStats.min === 0 ? co2 : Math.min(co2, monthlyStats.min),
        count: monthlyStats.count + 1
      });

      // Yearly stats (simulated)
      setYearlyStats({
        avg: (yearlyStats.avg * yearlyStats.count + co2) / (yearlyStats.count + 1),
        max: Math.max(co2, yearlyStats.max || 0),
        min: yearlyStats.min === 0 ? co2 : Math.min(co2, yearlyStats.min),
        count: yearlyStats.count + 1
      });
    }
  }, [gasData]);

  const StatCard = ({ title, value, unit, subtitle, variant = 'default' }) => (
    <div className={styles.statCard}>
      <div className={styles.statHeader}>
        <h4 className={styles.statTitle}>{title}</h4>
      </div>
      <div className={styles.statValue}>
        {typeof value === 'number' ? value.toFixed(2) : value}
        <span className={styles.statUnit}>{unit}</span>
      </div>
      {subtitle && <div className={styles.statSubtitle}>{subtitle}</div>}
    </div>
  );

  return (
    <div className={styles.overview}>
      {/* Yearly Overview (Large Card) */}
      <Card title="📅 Yearly Overview" subtitle="January 2026 - December 2026" padding="large">
        <div className={styles.yearlyGrid}>
          <div className={styles.yearlyMain}>
            <div className={styles.yearlyValue}>
              {yearlyStats.avg.toFixed(2)}
              <span className={styles.yearlyUnit}>ppm</span>
            </div>
            <div className={styles.yearlyLabel}>Average CO2 Level</div>
            <div className={styles.yearlyMeta}>
              Based on {yearlyStats.count} readings this year
            </div>
          </div>
          <div className={styles.yearlyStats}>
            <StatCard
              title="Peak Level"
              value={yearlyStats.max}
              unit="ppm"
              subtitle="Highest reading"
            />
            <StatCard
              title="Lowest Level"
              value={yearlyStats.min || 0}
              unit="ppm"
              subtitle="Minimum reading"
            />
            <StatCard
              title="Total Readings"
              value={yearlyStats.count}
              unit=""
              subtitle="Data points"
            />
          </div>
        </div>
      </Card>

      {/* Monthly and Daily Stats (Small Cards) */}
      <div className={styles.smallCardsGrid}>
        <Card title="📊 Monthly Overview" subtitle={new Date().toLocaleDateString('en-US', { month: 'long', year: 'numeric' })} padding="medium">
          <div className={styles.monthlyStats}>
            <div className={styles.mainStat}>
              <div className={styles.mainStatValue}>
                {monthlyStats.avg.toFixed(2)}
                <span className={styles.mainStatUnit}>ppm</span>
              </div>
              <div className={styles.mainStatLabel}>Avg CO2</div>
            </div>
            <div className={styles.subStats}>
              <div className={styles.subStat}>
                <div className={styles.subStatLabel}>Max</div>
                <div className={styles.subStatValue}>{monthlyStats.max.toFixed(2)}</div>
              </div>
              <div className={styles.subStat}>
                <div className={styles.subStatLabel}>Min</div>
                <div className={styles.subStatValue}>{(monthlyStats.min || 0).toFixed(2)}</div>
              </div>
              <div className={styles.subStat}>
                <div className={styles.subStatLabel}>Readings</div>
                <div className={styles.subStatValue}>{monthlyStats.count}</div>
              </div>
            </div>
          </div>
        </Card>

        <Card title="📈 Daily Summary" subtitle={new Date().toLocaleDateString('en-US', { weekday: 'long', month: 'short', day: 'numeric' })} padding="medium">
          <div className={styles.dailyStats}>
            <div className={styles.mainStat}>
              <div className={styles.mainStatValue}>
                {dailyStats.avg.toFixed(2)}
                <span className={styles.mainStatUnit}>ppm</span>
              </div>
              <div className={styles.mainStatLabel}>Avg CO2</div>
            </div>
            <div className={styles.subStats}>
              <div className={styles.subStat}>
                <div className={styles.subStatLabel}>Max</div>
                <div className={styles.subStatValue}>{dailyStats.max.toFixed(2)}</div>
              </div>
              <div className={styles.subStat}>
                <div className={styles.subStatLabel}>Min</div>
                <div className={styles.subStatValue}>{(dailyStats.min || 0).toFixed(2)}</div>
              </div>
              <div className={styles.subStat}>
                <div className={styles.subStatLabel}>Readings</div>
                <div className={styles.subStatValue}>{dailyStats.count}</div>
              </div>
            </div>
          </div>
        </Card>

        <Card title="🎯 Safety Score" padding="medium">
          <div className={styles.safetyScore}>
            <div className={styles.scoreCircle}>
              <svg viewBox="0 0 100 100" className={styles.scoreChart}>
                <circle cx="50" cy="50" r="45" className={styles.scoreBackground} />
                <circle 
                  cx="50" 
                  cy="50" 
                  r="45" 
                  className={styles.scoreProgress}
                  style={{
                    strokeDashoffset: 283 - (283 * (Math.max(0, 100 - dailyStats.avg / 5))) / 100
                  }}
                />
              </svg>
              <div className={styles.scoreText}>
                <div className={styles.scoreValue}>
                  {Math.max(0, 100 - Math.round(dailyStats.avg / 5))}
                </div>
                <div className={styles.scoreLabel}>Score</div>
              </div>
            </div>
            <div className={styles.scoreDescription}>
              Based on current air quality metrics
            </div>
          </div>
        </Card>

        <Card title="⚡ Status" padding="medium">
          <div className={styles.statusCard}>
            <div className={styles.statusItem}>
              <div className={styles.statusIcon}>✅</div>
              <div className={styles.statusContent}>
                <div className={styles.statusLabel}>System</div>
                <div className={styles.statusValue}>Operational</div>
              </div>
            </div>
            <div className={styles.statusItem}>
              <div className={styles.statusIcon}>🔔</div>
              <div className={styles.statusContent}>
                <div className={styles.statusLabel}>Alerts</div>
                <div className={styles.statusValue}>Active</div>
              </div>
            </div>
            <div className={styles.statusItem}>
              <div className={styles.statusIcon}>📡</div>
              <div className={styles.statusContent}>
                <div className={styles.statusLabel}>Monitoring</div>
                <div className={styles.statusValue}>Real-time</div>
              </div>
            </div>
          </div>
        </Card>
      </div>
    </div>
  );
};

export default Overview;
