import React from 'react';
import styles from './Input.module.css';

const Input = ({
  type = 'text',
  id,
  name,
  value,
  onChange,
  placeholder,
  disabled = false,
  error = null,
  icon = null
}) => {
  return (
    <div className={styles.inputWrapper}>
      {icon && <span className={styles.icon}>{icon}</span>}
      <input
        type={type}
        id={id}
        name={name}
        value={value}
        onChange={onChange}
        placeholder={placeholder}
        disabled={disabled}
        className={`${styles.input} ${icon ? styles.withIcon : ''} ${error ? styles.error : ''}`}
      />
      {error && <span className={styles.errorText}>{error}</span>}
    </div>
  );
};

export default Input;
