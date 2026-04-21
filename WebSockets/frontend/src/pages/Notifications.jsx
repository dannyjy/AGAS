import React from 'react';
import { useNotifications } from '../context/NotificationContext';
import Card from '../components/UI/Card';
import Button from '../components/UI/Button';
import styles from './Notifications.module.css';

const Notifications = () => {
  const { 
    notifications, 
    unreadCount, 
    markAsRead, 
    markAllAsRead, 
    clearNotification,
    clearAllNotifications
  } = useNotifications();

  const getNotificationIcon = (type) => {
    switch (type) {
      case 'danger':
        return '🚨';
      case 'warning':
        return '⚠️';
      case 'success':
        return '✅';
      default:
        return 'ℹ️';
    }
  };

  const getNotificationVariant = (type) => {
    switch (type) {
      case 'danger':
        return 'danger';
      case 'warning':
        return 'warning';
      case 'success':
        return 'success';
      default:
        return 'info';
    }
  };

  // Separate notifications by type
  const dangerNotifications = notifications.filter(n => n.type === 'danger');
  const warningNotifications = notifications.filter(n => n.type === 'warning');
  const otherNotifications = notifications.filter(n => n.type !== 'danger' && n.type !== 'warning');

  return (
    <div className={styles.notifications}>
      <Card variant="default" padding="large">
        <div className={styles.header}>
          <div className={styles.headerInfo}>
            <h2 className={styles.title}>Notifications</h2>
            <p className={styles.subtitle}>
              {unreadCount > 0 ? `${unreadCount} unread notification${unreadCount > 1 ? 's' : ''}` : 'All caught up!'}
            </p>
          </div>
          <div className={styles.actions}>
            {notifications.length > 0 && (
              <>
                {unreadCount > 0 && (
                  <Button size="small" variant="secondary" onClick={markAllAsRead}>
                    Mark All Read
                  </Button>
                )}
                <Button size="small" variant="danger" onClick={clearAllNotifications}>
                  Clear All
                </Button>
              </>
            )}
          </div>
        </div>
      </Card>

      {notifications.length === 0 ? (
        <Card padding="large">
          <div className={styles.emptyState}>
            <div className={styles.emptyIcon}>🔔</div>
            <div className={styles.emptyText}>No notifications yet</div>
            <div className={styles.emptySubtext}>You'll see alerts and warnings here</div>
          </div>
        </Card>
      ) : (
        <>
          {/* Danger Alerts */}
          {dangerNotifications.length > 0 && (
            <div className={styles.section}>
              <h3 className={styles.sectionTitle}>
                🚨 Danger Alerts ({dangerNotifications.length})
              </h3>
              <div className={styles.notificationsList}>
                {dangerNotifications.map((notification) => (
                  <Card
                    key={notification.id}
                    variant={getNotificationVariant(notification.type)}
                    padding="large"
                    className={notification.read ? styles.read : ''}
                  >
                    <div className={styles.notificationItem}>
                      <div className={styles.notificationIcon}>
                        {getNotificationIcon(notification.type)}
                      </div>
                      <div className={styles.notificationContent}>
                        <div className={styles.notificationHeader}>
                          <h4 className={styles.notificationTitle}>
                            {notification.title}
                          </h4>
                          {!notification.read && (
                            <span className={styles.unreadBadge}>New</span>
                          )}
                        </div>
                        <p className={styles.notificationMessage}>
                          {notification.message}
                        </p>
                        <div className={styles.notificationFooter}>
                          <span className={styles.timestamp}>
                            {new Date(notification.timestamp).toLocaleString()}
                          </span>
                        </div>
                      </div>
                      <div className={styles.notificationActions}>
                        {!notification.read && (
                          <button
                            className={styles.actionBtn}
                            onClick={() => markAsRead(notification.id)}
                            title="Mark as read"
                          >
                            ✓
                          </button>
                        )}
                        <button
                          className={styles.actionBtn}
                          onClick={() => clearNotification(notification.id)}
                          title="Remove"
                        >
                          ✕
                        </button>
                      </div>
                    </div>
                  </Card>
                ))}
              </div>
            </div>
          )}

          {/* Warnings */}
          {warningNotifications.length > 0 && (
            <div className={styles.section}>
              <h3 className={styles.sectionTitle}>
                ⚠️ Warnings ({warningNotifications.length})
              </h3>
              <div className={styles.notificationsList}>
                {warningNotifications.map((notification) => (
                  <Card
                    key={notification.id}
                    variant={getNotificationVariant(notification.type)}
                    padding="large"
                    className={notification.read ? styles.read : ''}
                  >
                    <div className={styles.notificationItem}>
                      <div className={styles.notificationIcon}>
                        {getNotificationIcon(notification.type)}
                      </div>
                      <div className={styles.notificationContent}>
                        <div className={styles.notificationHeader}>
                          <h4 className={styles.notificationTitle}>
                            {notification.title}
                          </h4>
                          {!notification.read && (
                            <span className={styles.unreadBadge}>New</span>
                          )}
                        </div>
                        <p className={styles.notificationMessage}>
                          {notification.message}
                        </p>
                        <div className={styles.notificationFooter}>
                          <span className={styles.timestamp}>
                            {new Date(notification.timestamp).toLocaleString()}
                          </span>
                        </div>
                      </div>
                      <div className={styles.notificationActions}>
                        {!notification.read && (
                          <button
                            className={styles.actionBtn}
                            onClick={() => markAsRead(notification.id)}
                            title="Mark as read"
                          >
                            ✓
                          </button>
                        )}
                        <button
                          className={styles.actionBtn}
                          onClick={() => clearNotification(notification.id)}
                          title="Remove"
                        >
                          ✕
                        </button>
                      </div>
                    </div>
                  </Card>
                ))}
              </div>
            </div>
          )}

          {/* Other Notifications */}
          {otherNotifications.length > 0 && (
            <div className={styles.section}>
              <h3 className={styles.sectionTitle}>
                ℹ️ General ({otherNotifications.length})
              </h3>
              <div className={styles.notificationsList}>
                {otherNotifications.map((notification) => (
                  <Card
                    key={notification.id}
                    variant={getNotificationVariant(notification.type)}
                    padding="large"
                    className={notification.read ? styles.read : ''}
                  >
                    <div className={styles.notificationItem}>
                      <div className={styles.notificationIcon}>
                        {getNotificationIcon(notification.type)}
                      </div>
                      <div className={styles.notificationContent}>
                        <div className={styles.notificationHeader}>
                          <h4 className={styles.notificationTitle}>
                            {notification.title}
                          </h4>
                          {!notification.read && (
                            <span className={styles.unreadBadge}>New</span>
                          )}
                        </div>
                        <p className={styles.notificationMessage}>
                          {notification.message}
                        </p>
                        <div className={styles.notificationFooter}>
                          <span className={styles.timestamp}>
                            {new Date(notification.timestamp).toLocaleString()}
                          </span>
                        </div>
                      </div>
                      <div className={styles.notificationActions}>
                        {!notification.read && (
                          <button
                            className={styles.actionBtn}
                            onClick={() => markAsRead(notification.id)}
                            title="Mark as read"
                          >
                            ✓
                          </button>
                        )}
                        <button
                          className={styles.actionBtn}
                          onClick={() => clearNotification(notification.id)}
                          title="Remove"
                        >
                          ✕
                        </button>
                      </div>
                    </div>
                  </Card>
                ))}
              </div>
            </div>
          )}
        </>
      )}
    </div>
  );
};

export default Notifications;
