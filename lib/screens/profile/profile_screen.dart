import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/routes/app_routes.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/favorites_service.dart';
import '../../core/services/notification_service.dart';
import '../../core/theme/app_colors.dart';
import '../../models/train_model.dart';
import 'widgets/profile_header_card.dart';
import 'widgets/favorite_train_item.dart';
import 'widgets/notification_preferences_card.dart';

/// Profile & Settings Screen for Registered Users and Station Master Portal (Member 4).
/// Manages user favorites, FCM notification preferences, session management, and logout.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Mock favorites for demo & preview when newly registered or offline
  final List<TrainModel> _mockFavorites = [
    const TrainModel(
      id: 'train_1001',
      trainNumber: '1001',
      name: 'Rajarata Rejina',
      routeId: 'route_colombo_anuradhapura',
      currentStation: 'Polgahawela Junction',
      nextStation: 'Kurunegala',
      scheduledDeparture: '05:45 AM',
      actualDeparture: '06:10 AM',
      delayMinutes: 25,
      status: 'delayed',
    ),
    const TrainModel(
      id: 'train_1015',
      trainNumber: '1015',
      name: 'Udarata Menike',
      routeId: 'route_colombo_badulla',
      currentStation: 'Gampaha',
      nextStation: 'Veyangoda',
      scheduledDeparture: '08:30 AM',
      delayMinutes: 0,
      status: 'on-time',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentUser = AuthService.instance.currentUser;
    final isAuthenticated = currentUser != null;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Profile & Settings'),
        actions: [
          if (isAuthenticated)
            IconButton(
              icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
              tooltip: 'Sign Out',
              onPressed: () => _showSignOutDialog(currentUser.uid),
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. User Profile Header Card
              ProfileHeaderCard(
                email: currentUser?.email,
                displayName: currentUser?.displayName,
                isAuthenticated: isAuthenticated,
                onSignInTap: _handleSignIn,
              ),

              const SizedBox(height: 20),

              // 2. Notification Preferences Section
              NotificationPreferencesCard(isAuthenticated: isAuthenticated),

              const SizedBox(height: 24),

              // 3. Saved Favorites Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'FAVORITE TRAINS',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                    ),
                  ),
                  if (isAuthenticated)
                    Text(
                      'Synced with account',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              _buildFavoritesContent(isAuthenticated, currentUser?.uid, isDark),

              const SizedBox(height: 24),

              // 4. Station Master Portal Quick Access Card
              _buildStationMasterAccessCard(isDark),

              const SizedBox(height: 24),

              // 5. App Version Information
              Center(
                child: Text(
                  'Railway Tracker v1.0.0 (Member 4 - Build 2026)',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFavoritesContent(bool isAuthenticated, String? userId, bool isDark) {
    if (!isAuthenticated || userId == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.bookmark_border_rounded,
              size: 40,
              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
            ),
            const SizedBox(height: 10),
            Text(
              'No Saved Favorites Yet',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Sign in to bookmark regular trains and view real-time delay telemetry here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 14),
            OutlinedButton(
              onPressed: _handleSignIn,
              child: const Text('Sign In to Sync Favorites'),
            ),
          ],
        ),
      );
    }

    return StreamBuilder<List<TrainModel>>(
      stream: FavoritesService.instance.streamFavorites(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final liveFavorites = snapshot.data ?? [];
        final displayFavorites =
            liveFavorites.isNotEmpty ? liveFavorites : _mockFavorites;

        if (displayFavorites.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: const Center(
              child: Text(
                'No favorite trains added yet. Tap Favorite on any train details screen to add one.',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        return Column(
          children: displayFavorites.map((train) {
            return FavoriteTrainItem(
              train: train,
              onTap: () {
                context.push(AppRoutes.trainDetails, extra: train);
              },
              onRemove: () async {
                await FavoritesService.instance.removeFavorite(userId, train.id);
                setState(() {
                  _mockFavorites.removeWhere((item) => item.id == train.id);
                });
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Removed ${train.name} from favorites'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildStationMasterAccessCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceElevated : AppColors.primaryNavy,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.dashboard_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Station Master Portal',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'View live checkpoint hits for your station',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              context.push(AppRoutes.stationDashboard);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primaryNavy,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Open',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSignIn() async {
    final loggedIn = await AuthService.showContextualLogin(
      context,
      reason: 'Sign in to access your profile, sync favorites, and manage notifications',
    );
    if (loggedIn && mounted) {
      final user = AuthService.instance.currentUser;
      if (user != null) {
        await NotificationService.instance.registerUserToken(user.uid);
      }
      setState(() {});
    }
  }

  Future<void> _showSignOutDialog(String userId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text(
          'Are you sure you want to sign out? Your device will be unregistered from real-time push alerts.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await NotificationService.instance.clearUserToken(userId);
      await AuthService.instance.signOut();
      if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Logged out successfully. Returned to guest mode.'),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
