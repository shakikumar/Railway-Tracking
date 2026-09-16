import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'providers/journey_provider.dart';
import 'providers/live_tracking_provider.dart';
import 'providers/driver_trip_provider.dart';

class RailwayTrackerApp extends StatelessWidget {
  const RailwayTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => JourneyProvider()),
        ChangeNotifierProvider(create: (_) => LiveTrackingProvider()),
        ChangeNotifierProvider(create: (_) => DriverTripProvider()),
      ],
      child: MaterialApp.router(
        title: 'Railway Tracker',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        routerConfig: AppRoutes.router,
      ),
    );
  }
}