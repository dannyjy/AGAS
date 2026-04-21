import React from 'react';
import { NavLink } from 'react-router-dom';
import { useAuth } from '../../context/AuthContext';
import { useSocket } from '../../context/SocketContext';
import { useNotifications } from '../../context/NotificationContext';
import styles from './Sidebar.module.css';

const Sidebar = ({ isOpen, onClose }) => {
  const { user, logout } = useAuth();
  const { connected } = useSocket();
  const { unreadCount } = useNotifications();

  const menuItems = [
    {
      path: '/',
      icon: '📊',
      label: 'Dashboard',
      exact: true
    },
    {
      path: '/profile',
      icon: '👤',
      label: 'Profile',
      exact: false
    },
    {
      path: '/notifications',
      icon: '🔔',
      label: 'Notifications',
      exact: false,
      badge: unreadCount
    },
    {
      path: '/overview',
      icon: '📈',
      label: 'Overview',
      exact: false
    },
    {
      path: '/health',
      icon: '🏥',
      label: 'Health Check',
      exact: false
    }
  ];

  return (
    <>
      {isOpen && <div className={styles.overlay} onClick={onClose} />}
      <aside className={`${styles.sidebar} ${isOpen ? styles.open : ''}`}>
        <div className={styles.sidebarHeader}>
          <div className={styles.logo}>
            <svg width="40" height="40" viewBox="0 0 60 60" fill="none">
              <circle cx="30" cy="30" r="28" stroke="#4c6ef5" strokeWidth="3" />
              <circle cx="30" cy="30" r="5" fill="#4c6ef5" />
            </svg>
            <span className={styles.logoText}>AGAS</span>
          </div>
          <button className={styles.closeBtn} onClick={onClose}>✕</button>
        </div>

        <div className={styles.connectionStatus}>
          <div className={`${styles.statusDot} ${connected ? styles.connected : ''}`}></div>
          <span className={styles.statusText}>
            {connected ? 'Connected' : 'Disconnected'}
          </span>
        </div>

        <nav className={styles.nav}>
          {menuItems.map((item) => (
            <NavLink
              key={item.path}
              to={item.path}
              end={item.exact}
              className={({ isActive }) => 
                `${styles.navItem} ${isActive ? styles.active : ''}`
              }
              onClick={onClose}
            >
              <span className={styles.navIcon}>{item.icon}</span>
              <span className={styles.navLabel}>{item.label}</span>
              {item.badge > 0 && (
                <span className={styles.badge}>{item.badge}</span>
              )}
            </NavLink>
          ))}
        </nav>

        <div className={styles.userSection}>
          <div className={styles.userInfo}>
            <div className={styles.userAvatar}>
              {user?.name?.charAt(0) || 'U'}
            </div>
            <div className={styles.userDetails}>
              <div className={styles.userName}>{user?.name || 'User'}</div>
              <div className={styles.userSerial}>{user?.serialNumber || 'N/A'}</div>
            </div>
          </div>
          <button className={styles.logoutBtn} onClick={logout} title="Logout">
            🚪
          </button>
        </div>
      </aside>
    </>
  );
};

export default Sidebar;
