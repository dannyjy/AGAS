# AGAS Frontend - Advanced Gas Alert System

A modern, responsive React application for real-time gas monitoring and alerting.

## 🚀 Features

### ✅ Authentication
- Secure login with serial number and password
- Protected routes with automatic redirects
- Persistent authentication via localStorage

### 📊 Real-time Dashboard
- Live gas sensor data display
- Safety level monitoring (0-100%)
- Danger rate tracking
- Warning rate calculation
- Real-time connection status

### 👤 Profile Management
- User information display
- Device details
- Gas leak monitoring status
- Account activity tracking

### 🔔 Smart Notifications
- **Prioritized Alerts**: Danger alerts appear first, followed by warnings
- **System Notifications**: Desktop notifications even when not on the platform
- **Audio Alerts**: Different sounds for danger vs. warning
- **Categorization**: Notifications organized by severity (Danger, Warning, General)
- **Interactive**: Mark as read or clear individual/all notifications

### 📈 Overview & Analytics
- **Yearly Overview**: Annual trends and statistics (large card)
- **Monthly Summary**: Current month metrics (small card)
- **Daily Summary**: Today's readings (small card)
- **Safety Score**: Visual circular progress indicator
- **System Status**: Real-time monitoring status

### 🎨 Design Features
- **Dark Sidebar**: Primary navigation with dark gray (#1a1d29)
- **Clean Layout**: White/light gray content areas
- **Responsive**: Mobile-first design, works on all screen sizes
- **Minimal Animations**: Only essential transitions for performance
- **Reusable Components**: Modular architecture for maintainability

## 📁 Project Structure

```
frontend/
├── public/
├── src/
│   ├── components/
│   │   ├── Layout/
│   │   │   ├── DashboardLayout.jsx
│   │   │   ├── Header.jsx
│   │   │   └── Sidebar.jsx
│   │   └── UI/
│   │       ├── Button.jsx
│   │       ├── Card.jsx
│   │       └── Input.jsx
│   ├── context/
│   │   ├── AuthContext.jsx
│   │   ├── NotificationContext.jsx
│   │   └── SocketContext.jsx
│   ├── pages/
│   │   ├── Dashboard.jsx
│   │   ├── Login.jsx
│   │   ├── Notifications.jsx
│   │   ├── Overview.jsx
│   │   └── Profile.jsx
│   ├── App.jsx
│   ├── index.css
│   └── main.jsx
├── index.html
├── package.json
└── vite.config.js
```

## 🛠️ Installation

1. **Navigate to the frontend folder:**
```bash
cd frontend
```

2. **Install dependencies:**
```bash
npm install
```

3. **Start the development server:**
```bash
npm run dev
```

The app will open at `http://localhost:5173`

## 🔐 Default Credentials

For testing purposes, use these credentials:

- **Serial Number**: `AGAS-2026-001`
- **Password**: `admin123`

## 🌐 Backend Connection

The frontend connects to the Socket.IO server at `http://localhost:3000`. Make sure the backend server is running before starting the frontend.

## 📱 Responsive Breakpoints

- **Desktop**: > 1024px
- **Tablet**: 768px - 1024px
- **Mobile**: < 768px

## 🎨 Color Scheme

### Primary Colors
- **Dark Gray**: `#1a1d29` (Sidebar background)
- **Medium Gray**: `#2d3142` (Sidebar elements)
- **Light Gray**: `#f5f7fa` (Content background)

### Accent Colors
- **Blue**: `#4c6ef5` (Primary actions)
- **Danger**: `#f03e3e` (Critical alerts)
- **Warning**: `#fab005` (Warning alerts)
- **Success**: `#37b24d` (Success states)
- **Safe**: `#20c997` (Safe indicators)

## 🔔 Notification System

### How It Works

1. **Real-time Monitoring**: Gas data is analyzed in real-time
2. **Threshold Detection**: Compares readings against danger/warning thresholds
3. **Automatic Alerts**: 
   - CO2 > 1000 ppm = Danger
   - CO2 > 500 ppm = Warning
   - Similar logic for temperature and humidity
4. **Audio Feedback**: Plays distinct sounds for each alert type
5. **System Notifications**: Requests permission for desktop notifications
6. **Persistent Storage**: Notifications stored in state until cleared

### Thresholds

```javascript
CO2:
  - Warning: 500 ppm
  - Danger: 1000 ppm

Temperature:
  - Warning: 30°C
  - Danger: 40°C

Humidity:
  - Warning: 70%
  - Danger: 85%
```

## 🔌 Real-time Features

### Socket.IO Integration

The app uses Socket.IO for real-time bidirectional communication:

- **Auto-connect**: Connects automatically when user logs in
- **Auto-reconnect**: Attempts to reconnect if connection is lost
- **Event Listeners**:
  - `connect`: Connection established
  - `disconnect`: Connection lost
  - `gas-data-update`: New sensor data received
  - `fetch-success`: API fetch completed
  - `fetch-error`: API fetch failed

## 🧩 Reusable Components

### Button
```jsx
<Button 
  variant="primary" 
  size="medium" 
  onClick={handleClick}
  loading={isLoading}
>
  Click Me
</Button>
```

### Input
```jsx
<Input
  type="text"
  name="fieldName"
  value={value}
  onChange={handleChange}
  placeholder="Enter text..."
/>
```

### Card
```jsx
<Card 
  title="Card Title" 
  subtitle="Subtitle" 
  variant="info"
  padding="large"
>
  {children}
</Card>
```

## 📊 Dashboard Features

### Safety Level
- Calculated based on CO2, temperature, and humidity
- 100% = Optimal conditions
- Updates in real-time

### Danger Rate
- Percentage showing how close readings are to danger thresholds
- 0% = All safe
- 100% = Critical danger

### Warning Rate
- Percentage showing elevated but not critical levels
- Helps prevent dangerous situations

## 🚀 Production Build

```bash
npm run build
```

Build output will be in the `dist/` folder.

Preview production build:
```bash
npm run preview
```

## 🔧 Configuration

### API Endpoint

To change the backend URL, edit `src/context/SocketContext.jsx`:

```javascript
const SERVER_URL = 'http://your-backend-url:3000';
```

### Default Credentials

To change default login credentials, edit `src/context/AuthContext.jsx`:

```javascript
const DEFAULT_CREDENTIALS = {
  serialNumber: 'YOUR-SERIAL',
  password: 'YOUR-PASSWORD'
};
```

## 📝 Pages

### Login (`/login`)
- Serial number and password authentication
- Shows default credentials for easy testing
- Redirects to dashboard on success

### Dashboard (`/`)
- Main overview with safety metrics
- Real-time sensor readings
- Connection status
- Last update information

### Profile (`/profile`)
- User information
- Device details
- Gas monitoring status
- Account activity

### Notifications (`/notifications`)
- Categorized by severity
- Mark as read/unread
- Clear individual or all notifications
- Shows timestamp and details

### Overview (`/overview`)
- Yearly statistics (large card)
- Monthly summary (small card)
- Daily summary (small card)
- Safety score visualization
- System status

## 🎯 Best Practices

1. **Component Modularity**: Each component has a single responsibility
2. **CSS Modules**: Scoped styles prevent conflicts
3. **Context API**: Centralized state management
4. **Protected Routes**: Authentication required for dashboard access
5. **Error Handling**: Graceful fallbacks for missing data
6. **Responsive Design**: Mobile-first approach
7. **Performance**: Minimal re-renders with proper memoization

## 🐛 Troubleshooting

### Connection Issues
- Ensure backend server is running on port 3000
- Check CORS configuration on backend
- Verify Socket.IO client version matches server

### Notification Permission
- Grant notification permission when prompted
- Check browser notification settings if not working

### Build Errors
- Clear node_modules and reinstall: `rm -rf node_modules && npm install`
- Clear Vite cache: `rm -rf node_modules/.vite`

## 📚 Dependencies

- **react**: ^18.2.0
- **react-dom**: ^18.2.0
- **react-router-dom**: ^6.22.0
- **socket.io-client**: ^4.8.3
- **vite**: ^5.1.0
- **@vitejs/plugin-react**: ^4.2.1

## 🤝 Contributing

This is a gas monitoring system. When adding features:
1. Follow the existing component structure
2. Use CSS modules for styling
3. Maintain responsive design
4. Test on mobile devices
5. Keep animations minimal
6. Update this README

## 📄 License

ISC

---

**Built with ❤️ for Advanced Gas Alert System (AGAS)**
