import React from 'react';
import styles from './Card.module.css';

const Card = ({ 
  children, 
  title = null, 
  subtitle = null,
  variant = 'default',
  padding = 'medium',
  className = '',
  onClick = null
}) => {
  const cardClass = `
    ${styles.card}
    ${styles[variant]}
    ${styles[`padding-${padding}`]}
    ${onClick ? styles.clickable : ''}
    ${className}
  `.trim();

  return (
    <div className={cardClass} onClick={onClick}>
      {(title || subtitle) && (
        <div className={styles.header}>
          {title && <h3 className={styles.title}>{title}</h3>}
          {subtitle && <p className={styles.subtitle}>{subtitle}</p>}
        </div>
      )}
      <div className={styles.content}>
        {children}
      </div>
    </div>
  );
};

export default Card;
