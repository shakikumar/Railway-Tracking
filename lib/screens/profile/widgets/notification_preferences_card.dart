import 'package:flutter/material.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/theme/app_colors.dart';

/// Card allowing users to configure push notification preferences and view FCM status
class NotificationPreferencesCard extends StatefulWidget {
  final bool isAuthenticated;

  const NotificationPreferencesCard({
    super.key,
    required this.isAuthenticated,
  });

  @override
  State<NotificationPreferencesCard> createState() => _NotificationPreferencesCardState();
}

class _NotificationPreferencesCardState extends State<NotificationPreferencesCard> {
  bool _delayAlertsEnabled = true;
  bool _arrivalAlertsEnabled = true;
  bool _platformChangesEnabled = true;
  String? _fcmToken;
  bool _isLoadingToken = false;

  @override
  void initState() {
    super.initState();
    if (widget.isAuthenticated) {
      _loadTokenInfo();
    }
  }

  Future<void> _loadTokenInfo() async {
    setState(() => _isLoadingToken = true);
    final token = await NotificationService.instance.getToken();
    if (mounted) {
      setState(() {
        _fcmToken = token;
        _isLoadingToken = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.brandBlue.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.notifications_active_outlined,
                  color: AppColors.brandBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Notification Preferences',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          _buildSwitchTile(
            title: 'Train Delay Alerts',
            subtitle: 'Real-time alerts when your favorite trains are delayed',
            value: _delayAlertsEnabled,
            enabled: widget.isAuthenticated,
            onChanged: (val) {
              setState(() => _delayAlertsEnabled = val);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(val ? 'Delay alerts enabled' : 'Delay alerts disabled'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
            isDark: isDark,
          ),
          const Divider(height: 20),
          _buildSwitchTile(
            title: 'Station Arrival Notifications',
            subtitle: 'Notifies you when trains approach checkpoint stations',
            value: _arrivalAlertsEnabled,
            enabled: widget.isAuthenticated,
            onChanged: (val) {
              setState(() => _arrivalAlertsEnabled = val);
            },
            isDark: isDark,
          ),
          const Divider(height: 20),
          _buildSwitchTile(
            title: 'Platform Reassignment Alerts',
            subtitle: 'Immediate alert when departure platform changes',
            value: _platformChangesEnabled,
            enabled: widget.isAuthenticated,
            onChanged: (val) {
              setState(() => _platformChangesEnabled = val);
            },
            isDark: isDark,
          ),

          const SizedBox(height: 14),

          // FCM Registration Token Indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurfaceElevated : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  widget.isAuthenticated ? Icons.cloud_done_rounded : Icons.cloud_off_rounded,
                  size: 18,
                  color: widget.isAuthenticated ? AppColors.statusOnTime : Colors.grey,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.isAuthenticated
                        ? (_isLoadingToken
                            ? 'Syncing FCM Token...'
                            : (_fcmToken != null
                                ? 'FCM Device Token Active'
                                : 'Token Registering...'))
                        : 'Sign in to register push device',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                ),
                if (widget.isAuthenticated && _fcmToken != null)
                  IconButton(
                    icon: const Icon(Icons.info_outline_rounded, size: 16),
                    tooltip: 'Token Details',
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('FCM Device Token'),
                          content: SelectableText(
                            _fcmToken!,
                            style: const TextStyle(fontSize: 12),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(),
                              child: const Text('Close'),
                            ),
                          ],
                        ),
                      );
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required bool enabled,
    required ValueChanged<bool> onChanged,
    required bool isDark,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: enabled
                      ? (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)
                      : (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                ),
              ),
            ],
          ),
        ),
        Switch.adaptive(
          value: enabled ? value : false,
          onChanged: enabled ? onChanged : null,
          activeColor: AppColors.brandBlue,
        ),
      ],
    );
  }
}
