import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

enum NotificationFilter { all, delays, arrivals }

/// Segmented tab selector for switching between notification categories
class NotificationFilterTabs extends StatelessWidget {
  final NotificationFilter currentFilter;
  final ValueChanged<NotificationFilter> onFilterChanged;
  final int unreadCount;

  const NotificationFilterTabs({
    super.key,
    required this.currentFilter,
    required this.onFilterChanged,
    this.unreadCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Row(
        children: [
          _buildTab(
            filter: NotificationFilter.all,
            title: 'All Alerts',
            badgeCount: unreadCount,
            isDark: isDark,
          ),
          _buildTab(
            filter: NotificationFilter.delays,
            title: 'Delays',
            icon: Icons.access_time_rounded,
            isDark: isDark,
          ),
          _buildTab(
            filter: NotificationFilter.arrivals,
            title: 'Arrivals',
            icon: Icons.near_me_rounded,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildTab({
    required NotificationFilter filter,
    required String title,
    IconData? icon,
    int? badgeCount,
    required bool isDark,
  }) {
    final isSelected = currentFilter == filter;

    return Expanded(
      child: GestureDetector(
        onTap: () => onFilterChanged(filter),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.brandBlue
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 14,
                  color: isSelected
                      ? Colors.white
                      : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                ),
                const SizedBox(width: 4),
              ],
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? Colors.white
                      : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                ),
              ),
              if (badgeCount != null && badgeCount > 0 && !isSelected) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: AppColors.brandBlue.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    badgeCount.toString(),
                    style: const TextStyle(
                      color: AppColors.brandBlue,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
