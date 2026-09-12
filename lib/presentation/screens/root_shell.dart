import 'package:flutter/material.dart';

import 'home/home_dashboard_screen.dart';
import 'measurements/measurements_hub_screen.dart';
import 'progress/progress_screen.dart';
import 'reminders/reminders_screen.dart';
import 'settings/settings_screen.dart';

/// The persistent bottom-navigation shell (§3): Home, Measurements,
/// Progress, Reminders, Profile/Settings.
class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 0;

  void _goToTab(int index) => setState(() => _index = index);

  late final _screens = [
    HomeDashboardScreen(onGoToTab: _goToTab),
    const MeasurementsHubScreen(),
    const ProgressScreen(),
    const RemindersScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(
            icon: Icon(Icons.straighten_outlined),
            selectedIcon: Icon(Icons.straighten),
            label: 'Measure',
          ),
          NavigationDestination(
            icon: Icon(Icons.show_chart_outlined),
            selectedIcon: Icon(Icons.show_chart),
            label: 'Progress',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_outlined),
            selectedIcon: Icon(Icons.notifications),
            label: 'Reminders',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
