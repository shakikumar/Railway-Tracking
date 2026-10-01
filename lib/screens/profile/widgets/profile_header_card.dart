import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Profile Header displaying user information, avatar, and role status badge
class ProfileHeaderCard extends StatelessWidget {
  final String? email;
  final String? displayName;
  final bool isAuthenticated;
  final VoidCallback onSignInTap;

  const ProfileHeaderCard({
    super.key,
    required this.email,
    required this.displayName,
    required this.isAuthenticated,
    required this.onSignInTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final initial = (displayName?.isNotEmpty == true
            ? displayName![0]
            : (email?.isNotEmpty == true ? email![0] : 'G'))
        .toUpperCase();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar circle
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isAuthenticated
                    ? [AppColors.brandBlue, AppColors.brandBlueLight]
                    : [Colors.grey.shade400, Colors.grey.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                initial,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // User details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        isAuthenticated
                            ? (displayName?.isNotEmpty == true
                                ? displayName!
                                : email?.split('@').first ?? 'Passenger')
                            : 'Guest Passenger',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isAuthenticated
                            ? AppColors.statusOnTimeBg
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isAuthenticated ? 'REGISTERED' : 'GUEST',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: isAuthenticated
                              ? AppColors.statusOnTime
                              : Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  isAuthenticated
                      ? (email ?? 'No email associated')
                      : 'Sign in to sync favorites & delay alerts',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (!isAuthenticated) ...[
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: onSignInTap,
                    child: const Text(
                      'Sign In / Register →',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.brandBlue,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
