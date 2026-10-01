import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/train_model.dart';

/// Action bar for Train Details with Live Map Tracking, Favorite toggle,
/// and Delay Notification subscription.
class TrainActionsBar extends StatefulWidget {
  final TrainModel train;

  const TrainActionsBar({
    super.key,
    required this.train,
  });

  @override
  State<TrainActionsBar> createState() => _TrainActionsBarState();
}

class _TrainActionsBarState extends State<TrainActionsBar> {
  bool _isFavorite = false;
  bool _isNotificationEnabled = false;

  Future<void> _handleFavoriteToggle() async {
    // Check if user is authenticated or trigger contextual login for guest
    if (!AuthService.instance.isAuthenticated) {
      final loggedIn = await AuthService.showContextualLogin(
        context,
        reason: 'Sign in to save ${widget.train.name} to your favorites',
      );
      if (!loggedIn) {
        // User dismissed the login modal; do nothing
        return;
      }
    }

    if (!mounted) return;

    setState(() {
      _isFavorite = !_isFavorite;
    });

    // TODO (Member 3 / Member 4): Persist favorite to Firestore users/{uid}/favorites collection
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isFavorite
              ? 'Train #${widget.train.trainNumber} saved to favorites'
              : 'Removed from favorites',
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _handleNotificationToggle() async {
    // Check if user is authenticated or trigger contextual login for guest
    if (!AuthService.instance.isAuthenticated) {
      final loggedIn = await AuthService.showContextualLogin(
        context,
        reason: 'Sign in to receive real-time delay notifications for ${widget.train.name}',
      );
      if (!loggedIn) {
        // User dismissed the login modal; do nothing
        return;
      }
    }

    if (!mounted) return;

    setState(() {
      _isNotificationEnabled = !_isNotificationEnabled;
    });

    // TODO (Member 4): Subscribe to Firebase Cloud Messaging topic for trainId
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isNotificationEnabled
              ? 'Delay alerts enabled for Train #${widget.train.trainNumber}'
              : 'Alerts disabled for Train #${widget.train.trainNumber}',
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _navigateToLiveTracking() {
    context.push(AppRoutes.liveTracking, extra: widget.train);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Primary Action: Live Map Tracking Button
        ElevatedButton.icon(
          onPressed: _navigateToLiveTracking,
          icon: const Icon(Icons.map_outlined, size: 20),
          label: const Text(
            'Live Map Tracking',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.brandBlue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 2,
          ),
        ),

        const SizedBox(height: 12),

        // Secondary Actions: Favorite & Notification Toggle Buttons
        Row(
          children: [
            // Favorite Button
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _handleFavoriteToggle,
                icon: Icon(
                  _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  size: 18,
                  color: _isFavorite ? Colors.redAccent : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                ),
                label: Text(
                  _isFavorite ? 'Saved' : 'Favorite',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  backgroundColor: _isFavorite
                      ? Colors.redAccent.withValues(alpha: 0.1)
                      : (isDark ? AppColors.darkSurface : AppColors.lightSurface),
                  side: BorderSide(
                    color: _isFavorite
                        ? Colors.redAccent.withValues(alpha: 0.4)
                        : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Notification Button
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _handleNotificationToggle,
                icon: Icon(
                  _isNotificationEnabled ? Icons.notifications_active_rounded : Icons.notifications_none_rounded,
                  size: 18,
                  color: _isNotificationEnabled ? AppColors.brandBlue : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                ),
                label: Text(
                  _isNotificationEnabled ? 'Alerts On' : 'Notify',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  backgroundColor: _isNotificationEnabled
                      ? AppColors.brandBlue.withValues(alpha: 0.1)
                      : (isDark ? AppColors.darkSurface : AppColors.lightSurface),
                  side: BorderSide(
                    color: _isNotificationEnabled
                        ? AppColors.brandBlue.withValues(alpha: 0.4)
                        : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
