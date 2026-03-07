import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import Button from '../components/UI/Button';
import Input from '../components/UI/Input';
import styles from './Login.module.css';

const Login = () => {
  const navigate = useNavigate();
  const { login } = useAuth();
  const [formData, setFormData] = useState({
    serialNumber: '',
    password: ''
  });
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  const handleChange = (e) => {
    setFormData({
      ...formData,
      [e.target.name]: e.target.value
    });
    setError('');
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    setLoading(true);

    if (!formData.serialNumber || !formData.password) {
      setError('Please fill in all fields');
      setLoading(false);
      return;
    }

    const result = login(formData.serialNumber, formData.password);

    if (result.success) {
      navigate('/', { replace: true });
    } else {
      setError(result.error);
    }

    setLoading(false);
  };

  return (
    <div className={styles.loginContainer}>
      <div className={styles.loginBox}>
        <div className={styles.logoSection}>
          <div className={styles.logo}>
            <svg width="60" height="60" viewBox="0 0 60 60" fill="none">
              <circle cx="30" cy="30" r="28" stroke="#4c6ef5" strokeWidth="3" />
              <path
                d="M30 15 L30 35 M22 30 L38 30"
                stroke="#4c6ef5"
                strokeWidth="3"
                strokeLinecap="round"
              />
              <circle cx="30" cy="30" r="5" fill="#4c6ef5" />
            </svg>
          </div>
          <h1 className={styles.title}>AGAS</h1>
          <p className={styles.subtitle}>Advanced Gas Alert System</p>
        </div>

        <form className={styles.loginForm} onSubmit={handleSubmit}>
          <div className={styles.formGroup}>
            <label htmlFor="serialNumber" className={styles.label}>
              Serial Number
            </label>
            <Input
              type="text"
              id="serialNumber"
              name="serialNumber"
              placeholder="Enter your serial number"
              value={formData.serialNumber}
              onChange={handleChange}
              disabled={loading}
            />
          </div>

          <div className={styles.formGroup}>
            <label htmlFor="password" className={styles.label}>
              Password
            </label>
            <Input
              type="password"
              id="password"
              name="password"
              placeholder="Enter your password"
              value={formData.password}
              onChange={handleChange}
              disabled={loading}
            />
          </div>

          {error && <div className={styles.error}>{error}</div>}

          <Button type="submit" fullWidth loading={loading}>
            {loading ? 'Signing in...' : 'Sign In'}
          </Button>

          <div className={styles.defaultCredentials}>
            <p className={styles.infoText}>Default Credentials:</p>
            <p className={styles.credText}>Serial: AGAS-2026-001</p>
            <p className={styles.credText}>Password: admin123</p>
          </div>
        </form>

        <div className={styles.footer}>
          <p>&copy; 2026 AGAS. All rights reserved.</p>
        </div>
      </div>
    </div>
  );
};

export default Login;
