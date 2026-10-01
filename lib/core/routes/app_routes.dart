import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../screens/home/home_screen.dart';
import '../../screens/journey_planner/journey_planner_screen.dart';
import '../../screens/search_results/search_results_screen.dart';
import '../../screens/train_details/train_details_screen.dart';
import '../../screens/live_tracking/live_tracking_screen.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/notifications/notifications_screen.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/driver/qr_scan/qr_scan_screen.dart';
import '../../screens/driver/trip_setup/trip_setup_screen.dart';
import '../../screens/driver/trip_status/trip_status_screen.dart';
import '../../screens/station_master/ble_config/ble_config_screen.dart';
import '../../screens/station_master/dashboard/station_master_dashboard_screen.dart';

/// Centralized route definitions and GoRouter configuration for Railway Tracker.
/// Contains canonical route paths for all 13 core screens across team members
/// plus standalone authentication routes.
class AppRoutes {
  AppRoutes._();

  // Route Path Constants
  static const String home = '/';
  static const String journeyPlanner = '/journey-planner';
  static const String searchResults = '/search-results';
  static const String trainDetails = '/train-details';
  static const String liveTracking = '/live-tracking';
  static const String login = '/login';
  static const String notifications = '/notifications';
  static const String profile = '/profile';

  // Driver Routes (Member 5)
  static const String driverQrScan = '/driver/qr-scan';
  static const String driverTripSetup = '/driver/trip-setup';
  static const String driverTripStatus = '/driver/trip-status';

  // Station Master Routes (Member 5)
  static const String stationBleConfig = '/station-master/ble-config';
  static const String stationDashboard = '/station-master/dashboard';

  /// GoRouter configuration with all 13 route definitions + standalone login route
  static final GoRouter router = GoRouter(
    initialLocation: home,
    routes: [
      GoRoute(
        path: home,
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: journeyPlanner,
        name: 'journeyPlanner',
        builder: (context, state) => const JourneyPlannerScreen(),
      ),
      GoRoute(
        path: searchResults,
        name: 'searchResults',
        builder: (context, state) => const SearchResultsScreen(),
      ),
      GoRoute(
        path: trainDetails,
        name: 'trainDetails',
        builder: (context, state) => const TrainDetailsScreen(),
      ),
      GoRoute(
        path: liveTracking,
        name: 'liveTracking',
        builder: (context, state) => const LiveTrackingScreen(),
      ),
      GoRoute(
        path: login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: notifications,
        name: 'notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: profile,
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: driverQrScan,
        name: 'driverQrScan',
        builder: (context, state) => const QrScanScreen(),
      ),
      GoRoute(
        path: driverTripSetup,
        name: 'driverTripSetup',
        builder: (context, state) => const TripSetupScreen(),
      ),
      GoRoute(
        path: driverTripStatus,
        name: 'driverTripStatus',
        builder: (context, state) => const TripStatusScreen(),
      ),
      GoRoute(
        path: stationBleConfig,
        name: 'stationBleConfig',
        builder: (context, state) => const BleConfigScreen(),
      ),
      GoRoute(
        path: stationDashboard,
        name: 'stationDashboard',
        builder: (context, state) => const StationMasterDashboardScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('No route defined for ${state.uri}'),
      ),
    ),
  );
}
