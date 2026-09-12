import 'package:go_router/go_router.dart';

import '../screens/clothing/clothing_item_edit_screen.dart';
import '../screens/clothing/clothing_list_screen.dart';
import '../screens/health/health_integration_screen.dart';
import '../screens/home/measurement_session_screen.dart';
import '../screens/measurements/measurement_history_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/root_shell.dart';
import '../screens/settings/data_privacy_screen.dart';
import '../screens/shoes/shoe_item_edit_screen.dart';
import '../screens/shoes/shoe_list_screen.dart';
import '../screens/startup_gate.dart';

/// MeasureMe uses a lightweight routing model: the five bottom-navigation
/// destinations are handled as local tab state inside [RootShell] (there's
/// no need for deep-linkable URLs per tab in a personal, offline-first
/// mobile app), while everything pushed *on top of* the shell — sessions,
/// detail/edit screens, settings sub-pages — is a real go_router route so
/// it participates in the system back gesture and can be reached from a
/// notification tap.
final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const StartupGate()),
    GoRoute(path: '/onboarding', builder: (context, state) => const OnboardingScreen()),
    GoRoute(path: '/home', builder: (context, state) => const RootShell()),
    GoRoute(
      path: '/session',
      builder: (context, state) => const MeasurementSessionScreen(),
    ),
    GoRoute(
      path: '/measurements/:typeId/history',
      builder: (context, state) =>
          MeasurementHistoryScreen(typeId: state.pathParameters['typeId']!),
    ),
    GoRoute(path: '/clothing', builder: (context, state) => const ClothingListScreen()),
    GoRoute(
      path: '/clothing/new',
      builder: (context, state) => const ClothingItemEditScreen(),
    ),
    GoRoute(
      path: '/clothing/:id/edit',
      builder: (context, state) => ClothingItemEditScreen(itemId: state.pathParameters['id']),
    ),
    GoRoute(path: '/shoes', builder: (context, state) => const ShoeListScreen()),
    GoRoute(path: '/shoes/new', builder: (context, state) => const ShoeItemEditScreen()),
    GoRoute(
      path: '/shoes/:id/edit',
      builder: (context, state) => ShoeItemEditScreen(itemId: state.pathParameters['id']),
    ),
    GoRoute(
      path: '/settings/health',
      builder: (context, state) => const HealthIntegrationScreen(),
    ),
    GoRoute(
      path: '/settings/data-privacy',
      builder: (context, state) => const DataPrivacyScreen(),
    ),
  ],
);
