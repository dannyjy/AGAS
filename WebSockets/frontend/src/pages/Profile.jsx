import React from 'react';
import { useAuth } from '../context/AuthContext';
import Card from '../components/UI/Card';
import styles from './Profile.module.css';

const Profile = () => {
  const { user } = useAuth();

  const profileSections = [
    {
      title: 'Personal Information',
      icon: '👤',
      items: [
        { label: 'Name', value: user?.name || 'N/A' },
        { label: 'Email', value: user?.email || 'N/A' },
        { label: 'Serial Number', value: user?.serialNumber || 'N/A' }
      ]
    },
    {
      title: 'Device Information',
      icon: '🔬',
      items: [
        { label: 'Device Type', value: user?.deviceType || 'N/A' },
        { label: 'Location', value: user?.location || 'N/A' },
        { label: 'Registered Date', value: user?.registeredDate || 'N/A' }
      ]
    },
    {
      title: 'Gas Leak Monitoring Details',
      icon: '⚠️',
      items: [
        { label: 'Monitoring Status', value: 'Active' },
        { label: 'Alert System', value: 'Enabled' },
        { label: 'Notification Method', value: 'Real-time & System' },
        { label: 'Last Sync', value: new Date().toLocaleString() }
      ]
    }
  ];

  return (
    <div className={styles.profile}>
      <Card variant="info" padding="large">
        <div className={styles.profileHeader}>
          <div className={styles.avatar}>
            {user?.name?.charAt(0) || 'U'}
          </div>
          <div className={styles.headerInfo}>
            <h2 className={styles.userName}>{user?.name || 'User'}</h2>
            <p className={styles.userSerial}>{user?.serialNumber || 'N/A'}</p>
            <p className={styles.userRole}>Gas Monitoring User</p>
          </div>
        </div>
      </Card>

      <div className={styles.sectionsGrid}>
        {profileSections.map((section, index) => (
          <Card key={index} title={section.title} padding="large">
            <div className={styles.sectionIcon}>{section.icon}</div>
            <div className={styles.itemsList}>
              {section.items.map((item, idx) => (
                <div key={idx} className={styles.item}>
                  <div className={styles.itemLabel}>{item.label}</div>
                  <div className={styles.itemValue}>{item.value}</div>
                </div>
              ))}
            </div>
          </Card>
        ))}
      </div>

      <Card title="Account Activity" variant="default" padding="large">
        <div className={styles.activityList}>
          <div className={styles.activityItem}>
            <div className={styles.activityIcon}>🔐</div>
            <div className={styles.activityContent}>
              <div className={styles.activityTitle}>Last Login</div>
              <div className={styles.activityTime}>
                {user?.lastLogin ? new Date(user.lastLogin).toLocaleString() : 'N/A'}
              </div>
            </div>
          </div>
          <div className={styles.activityItem}>
            <div className={styles.activityIcon}>📍</div>
            <div className={styles.activityContent}>
              <div className={styles.activityTitle}>Current Location</div>
              <div className={styles.activityTime}>{user?.location || 'N/A'}</div>
            </div>
          </div>
          <div className={styles.activityItem}>
            <div className={styles.activityIcon}>✅</div>
            <div className={styles.activityContent}>
              <div className={styles.activityTitle}>Account Status</div>
              <div className={styles.activityTime}>
                <span className={styles.statusBadge}>Active</span>
              </div>
            </div>
          </div>
        </div>
      </Card>
    </div>
  );
};

export default Profile;
