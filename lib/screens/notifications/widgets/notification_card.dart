import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/notification_model.dart';

/// Card displaying an individual notification item with category badge,
/// timestamp, unread indicator, and tap/dismiss actions.
class NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;
  final VoidCallback? onDismiss;

  const NotificationCard({
    super.key,
    required this.notification,
    required this.onTap,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final (badgeColor, badgeBg, icon) = _getCategoryStyle(notification.type);

    return Dismissible(
      key: Key(notification.id),
      direction: onDismiss != null ? DismissDirection.endToStart : DismissDirection.none,
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 6.0),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 24),
      ),
      onDismissed: (_) => onDismiss?.call(),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6.0),
        decoration: BoxDecoration(
          color: notification.isRead
              ? (isDark ? AppColors.darkSurface : AppColors.lightSurface)
              : (isDark
                  ? AppColors.darkSurfaceElevated
                  : AppColors.brandBlue.withValues(alpha: 0.05)),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: notification.isRead
                ? (isDark ? AppColors.darkBorder : AppColors.lightBorder)
                : AppColors.brandBlue.withValues(alpha: 0.3),
            width: notification.isRead ? 1.0 : 1.5,
          ),
          boxShadow: notification.isRead
              ? null
              : [
                  BoxShadow(
                    color: AppColors.brandBlue.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon badge container
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: badgeBg,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: badgeColor, size: 22),
                  ),
                  const SizedBox(width: 14),

                  // Content column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            // Category Tag
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: badgeBg,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                notification.type.name.toUpperCase(),
                                style: TextStyle(
                                  color: badgeColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            if (notification.delayMinutes != null &&
                                notification.delayMinutes! > 0) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.statusDelayedBg,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '+${notification.delayMinutes}m delay',
                                  style: const TextStyle(
                                    color: AppColors.statusDelayed,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                            const Spacer(),
                            // Relative timestamp
                            Text(
                              _formatTime(notification.timestamp),
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark
                                    ? AppColors.darkTextMuted
                                    : AppColors.lightTextMuted,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),

                        // Title
                        Text(
                          notification.title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: notification.isRead ? FontWeight.w600 : FontWeight.w700,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                          ],
                        ),
                        const SizedBox(height: 4),

                        // Body description
                        Text(
                          notification.body,
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.3,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                        ),

                        // Metadata pills (Train #, Station)
                        if (notification.trainNumber != null ||
                            notification.stationName != null) ...[
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            children: [
                              if (notification.trainNumber != null)
                                _buildInfoChip(
                                  icon: Icons.train_outlined,
                                  label: 'Train #${notification.trainNumber}',
                                  isDark: isDark,
                                ),
                              if (notification.stationName != null)
                                _buildInfoChip(
                                  icon: Icons.location_on_outlined,
                                  label: notification.stationName!,
                                  isDark: isDark,
                                ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Unread dot indicator
                  if (!notification.isRead) ...[
                    const SizedBox(width: 8),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.brandBlue,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceElevated : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 13,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  (Color, Color, IconData) _getCategoryStyle(NotificationType type) {
    switch (type) {
      case NotificationType.delay:
        return (
          AppColors.statusDelayed,
          AppColors.statusDelayedBg,
          Icons.alarm_on_rounded,
        );
      case NotificationType.arrival:
        return (
          AppColors.statusOnTime,
          AppColors.statusOnTimeBg,
          Icons.near_me_rounded,
        );
      case NotificationType.platform:
        return (
          AppColors.brandBlue,
          AppColors.brandBlue.withValues(alpha: 0.1),
          Icons.alt_route_rounded,
        );
      case NotificationType.general:
        return (
          AppColors.tertiarySlate,
          Colors.grey.shade200,
          Icons.notifications_active_outlined,
        );
    }
  }

  String _formatTime(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dateTime.day}/${dateTime.month}';
  }
}
