import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/alerts_screen.dart';
import 'screens/control_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/splash_screen.dart';
import 'state/app_state.dart';

void main() {
  runApp(const AgasApp());
}

class AgasApp extends StatelessWidget {
  const AgasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: MaterialApp(
        title: 'AGAS Mobile',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor: const Color(0xFF070D27),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF00E58F),
            brightness: Brightness.dark,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF070D27),
            elevation: 0,
            foregroundColor: Colors.white,
          ),
          cardTheme: CardThemeData(
            color: const Color(0xFF181F3D),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: const BorderSide(color: Color(0xFF2E3A66), width: 1),
            ),
          ),
          textTheme: const TextTheme(
            bodyMedium: TextStyle(color: Color(0xFFB6C1E3)),
          ),
          useMaterial3: true,
        ),
        routes: {'/home': (_) => const HomeScreen()},
        home: const SplashScreen(),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _screens = [
    DashboardScreen(),
    AlertsScreen(),
    ControlScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1A213F),
          border: Border(top: BorderSide(color: Color(0xFF2B3764))),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          backgroundColor: const Color(0xFF1A213F),
          selectedItemColor: const Color(0xFF00F38D),
          unselectedItemColor: const Color(0xFF93A0C4),
          type: BottomNavigationBarType.fixed,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.warning_amber_outlined),
              activeIcon: Icon(Icons.warning_amber_rounded),
              label: 'Alerts',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.dns_outlined),
              activeIcon: Icon(Icons.dns),
              label: 'Devices',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
