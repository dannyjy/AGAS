import React from 'react';
import { useLocation } from 'react-router-dom';
import styles from './Header.module.css';

const Header = ({ onMenuClick }) => {
  const location = useLocation();

  const getPageTitle = () => {
    const path = location.pathname;
    if (path === '/') return 'Dashboard';
    if (path === '/profile') return 'Profile';
    if (path === '/notifications') return 'Notifications';
    if (path === '/overview') return 'Overview';
    return 'AGAS';
  };

  return (
    <header className={styles.header}>
      <div className={styles.leftSection}>
        <button className={styles.menuBtn} onClick={onMenuClick}>
          ☰
        </button>
        <h1 className={styles.title}>{getPageTitle()}</h1>
      </div>
      <div className={styles.rightSection}>
        <div className={styles.timestamp}>
          {new Date().toLocaleDateString('en-US', {
            weekday: 'short',
            year: 'numeric',
            month: 'short',
            day: 'numeric'
          })}
        </div>
      </div>
    </header>
  );
};

export default Header;
