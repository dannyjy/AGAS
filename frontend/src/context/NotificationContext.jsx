import React, { createContext, useContext, useState, useEffect, useCallback, useRef } from 'react';
import { useSocket } from './SocketContext';

const NotificationContext = createContext(null);

// Audio files (using data URLs for embedded sounds)
const SOUNDS = {
  danger: new Audio('data:audio/wav;base64,UklGRhIAAABXQVZFZm10IBAAAAABAAEAQB8AAEAfAAABAAgAZGF0Yf4AAAC/v7+/v7+/v7+/'),
  warning: new Audio('data:audio/wav;base64,UklGRhIAAABXQVZFZm10IBAAAAABAAEAQB8AAEAfAAABAAgAZGF0Yf4AAAB/f39/f39/f39/')
};

export const NotificationProvider = ({ children }) => {
  const { gasData } = useSocket();
  const [notifications, setNotifications] = useState([]);
  const [unreadCount, setUnreadCount] = useState(0);
  const lastAlertRef = useRef({ key: null, timestamp: 0 });

  const ALERT_COOLDOWN_MS = 15000;
  const MAX_NOTIFICATIONS = 100;

  // Danger thresholds
  const DANGER_THRESHOLDS = {
    co2: { warning: 500, danger: 1000 },
    temperature: { warning: 30, danger: 40 },
    humidity: { warning: 70, danger: 85 }
  };

  const analyzeGasData = useCallback((data) => {
    if (!data || !data.data) return null;

    const readings = data.data.readings || data.data;
    let level = 'safe';
    let messages = [];

    // Check CO2
    if (readings.co2) {
      if (readings.co2 >= DANGER_THRESHOLDS.co2.danger) {
        level = 'danger';
        messages.push(`CO2 critically high: ${readings.co2} ppm`);
      } else if (readings.co2 >= DANGER_THRESHOLDS.co2.warning) {
        if (level !== 'danger') level = 'warning';
        messages.push(`CO2 elevated: ${readings.co2} ppm`);
      }
    }

    // Check Temperature
    if (readings.temperature) {
      if (readings.temperature >= DANGER_THRESHOLDS.temperature.danger) {
        level = 'danger';
        messages.push(`Temperature critically high: ${readings.temperature}°C`);
      } else if (readings.temperature >= DANGER_THRESHOLDS.temperature.warning) {
        if (level !== 'danger') level = 'warning';
        messages.push(`Temperature elevated: ${readings.temperature}°C`);
      }
    }

    // Check Humidity
    if (readings.humidity) {
      if (readings.humidity >= DANGER_THRESHOLDS.humidity.danger) {
        level = 'danger';
        messages.push(`Humidity critically high: ${readings.humidity}%`);
      } else if (readings.humidity >= DANGER_THRESHOLDS.humidity.warning) {
        if (level !== 'danger') level = 'warning';
        messages.push(`Humidity elevated: ${readings.humidity}%`);
      }
    }

    return { level, messages, readings };
  }, []);

  const addNotification = useCallback((type, title, message, data = null) => {
    const notification = {
      id: Date.now() + Math.random(),
      type, // 'danger', 'warning', 'info', 'success'
      title,
      message,
      data,
      timestamp: new Date(),
      read: false
    };

    setNotifications((prev) => {
      const next = [notification, ...prev].slice(0, MAX_NOTIFICATIONS);
      setUnreadCount(next.reduce((count, item) => count + (item.read ? 0 : 1), 0));
      return next;
    });

    // Play sound
    if (type === 'danger') {
      SOUNDS.danger.play().catch(err => console.log('Audio play failed:', err));
    } else if (type === 'warning') {
      SOUNDS.warning.play().catch(err => console.log('Audio play failed:', err));
    }

    // Request notification permission and send system notification
    if ('Notification' in window && Notification.permission === 'granted') {
      new Notification(title, {
        body: message,
        icon: '/favicon.ico',
        tag: notification.id,
        requireInteraction: type === 'danger'
      });
    }

    return notification.id;
  }, []);

  const markAsRead = useCallback((notificationId) => {
    setNotifications((prev) => {
      const next = prev.map((notif) =>
        notif.id === notificationId ? { ...notif, read: true } : notif
      );
      setUnreadCount(next.reduce((count, item) => count + (item.read ? 0 : 1), 0));
      return next;
    });
  }, []);

  const markAllAsRead = useCallback(() => {
    setNotifications((prev) => prev.map((notif) => ({ ...notif, read: true })));
    setUnreadCount(0);
  }, []);

  const clearNotification = useCallback((notificationId) => {
    setNotifications((prev) => {
      const next = prev.filter((notif) => notif.id !== notificationId);
      setUnreadCount(next.reduce((count, item) => count + (item.read ? 0 : 1), 0));
      return next;
    });
  }, []);

  const clearAllNotifications = useCallback(() => {
    setNotifications([]);
    setUnreadCount(0);
  }, []);

  // Request notification permission on mount
  useEffect(() => {
    if ('Notification' in window && Notification.permission === 'default') {
      Notification.requestPermission();
    }
  }, []);

  // Monitor gas data for alerts
  useEffect(() => {
    if (gasData) {
      const analysis = analyzeGasData(gasData);
      
      if (analysis && analysis.level !== 'safe') {
        const alertKey = `${analysis.level}:${analysis.messages.join('|')}`;
        const now = Date.now();

        // Prevent repeated identical alerts from flooding the UI and browser.
        if (
          lastAlertRef.current.key === alertKey &&
          now - lastAlertRef.current.timestamp < ALERT_COOLDOWN_MS
        ) {
          return;
        }

        lastAlertRef.current = { key: alertKey, timestamp: now };

        const title = analysis.level === 'danger' ? '🚨 DANGER ALERT' : '⚠️ WARNING';
        const message = analysis.messages.join(', ');
        
        addNotification(
          analysis.level,
          title,
          message,
          gasData
        );
      }
    }
  }, [gasData, analyzeGasData, addNotification]);

  const value = {
    notifications,
    unreadCount,
    addNotification,
    markAsRead,
    markAllAsRead,
    clearNotification,
    clearAllNotifications
  };

  return (
    <NotificationContext.Provider value={value}>
      {children}
    </NotificationContext.Provider>
  );
};

export const useNotifications = () => {
  const context = useContext(NotificationContext);
  if (!context) {
    throw new Error('useNotifications must be used within a NotificationProvider');
  }
  return context;
};
