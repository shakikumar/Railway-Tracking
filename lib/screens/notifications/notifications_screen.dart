import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/routes/app_routes.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/notification_service.dart';
import '../../core/theme/app_colors.dart';
import '../../models/notification_model.dart';
import 'widgets/notification_card.dart';
import 'widgets/notification_filter_tabs.dart';

/// Notifications screen displaying live delay alerts, arrival alerts,
/// and complete history for registered users (Member 4).
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  NotificationFilter _activeFilter = NotificationFilter.all;

  // Fallback demo notifications for guest preview or newly created accounts
  final List<NotificationModel> _mockNotifications = [
    NotificationModel(
      id: 'mock_1',
      title: 'Train #1001 Delay Notice',
      body: 'Rajarata Rejina is running 25 minutes behind schedule due to track maintenance near Polgahawela.',
      type: NotificationType.delay,
      timestamp: DateTime.now().subtract(const Duration(minutes: 8)),
      trainId: 'train_1001',
      trainNumber: '1001',
      stationName: 'Polgahawela Junction',
      delayMinutes: 25,
      isRead: false,
    ),
    NotificationModel(
      id: 'mock_2',
      title: 'Approaching Station Checkpoint',
      body: 'Udarata Menike #1015 has departed Gampaha Station and is approaching Veyangoda checkpoint.',
      type: NotificationType.arrival,
      timestamp: DateTime.now().subtract(const Duration(minutes: 32)),
      trainId: 'train_1015',
      trainNumber: '1015',
      stationName: 'Veyangoda',
      isRead: false,
    ),
    NotificationModel(
      id: 'mock_3',
      title: 'Platform Change Announcement',
      body: 'Express #1005 will now depart from Platform 3 instead of Platform 1 at Colombo Fort.',
      type: NotificationType.platform,
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      trainId: 'train_1005',
      trainNumber: '1005',
      stationName: 'Colombo Fort',
      isRead: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentUser = AuthService.instance.currentUser;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Alerts & Notifications'),
        actions: [
          if (currentUser != null)
            IconButton(
              icon: const Icon(Icons.done_all_rounded),
              tooltip: 'Mark all as read',
              onPressed: () => _handleMarkAllAsRead(currentUser.uid),
            ),
        ],
      ),
      body: currentUser == null
          ? _buildGuestView(context, isDark)
          : _buildAuthenticatedView(currentUser.uid, isDark),
    );
  }

  Widget _buildGuestView(BuildContext context, bool isDark) {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkSurfaceElevated
                      : AppColors.brandBlue.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.notifications_active_outlined,
                  size: 44,
                  color: AppColors.brandBlue,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Personalized Alerts',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Sign in to receive real-time push notifications for train delays, platform changes, and arrival alerts for your favorite routes.',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.login_rounded, size: 20),
                  label: const Text(
                    'Sign In to Enable Alerts',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brandBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    final loggedIn = await AuthService.showContextualLogin(
                      context,
                      reason: 'Sign in to access personalized delay and arrival notifications',
                    );
                    if (loggedIn && mounted) {
                      final uid = AuthService.instance.currentUser?.uid;
                      if (uid != null) {
                        NotificationService.instance.registerUserToken(uid);
                      }
                      setState(() {});
                    }
                  },
                ),
              ),
              const SizedBox(height: 36),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'SAMPLE NOTIFICATIONS PREVIEW',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ..._mockNotifications.map((notif) => NotificationCard(
                    notification: notif,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Sign in to interact with live alerts'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAuthenticatedView(String userId, bool isDark) {
    return StreamBuilder<List<NotificationModel>>(
      stream: NotificationService.instance.streamUserNotifications(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final liveList = snapshot.data ?? [];
        final displayList = liveList.isNotEmpty ? liveList : _mockNotifications;
        final filteredList = _applyFilter(displayList);
        final unreadCount = displayList.where((n) => !n.isRead).length;

        return RefreshIndicator(
          onRefresh: () async {
            setState(() {});
          },
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: NotificationFilterTabs(
                  currentFilter: _activeFilter,
                  unreadCount: unreadCount,
                  onFilterChanged: (filter) {
                    setState(() => _activeFilter = filter);
                  },
                ),
              ),
              Expanded(
                child: filteredList.isEmpty
                    ? _buildEmptyState(isDark)
                    : ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: filteredList.length,
                        itemBuilder: (context, index) {
                          final item = filteredList[index];
                          return NotificationCard(
                            notification: item,
                            onTap: () => _handleNotificationTap(item, userId),
                            onDismiss: () => _handleDismiss(item, userId),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceElevated : Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_none_rounded,
                size: 48,
                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _getEmptyTitle(),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _getEmptySubtitle(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getEmptyTitle() {
    switch (_activeFilter) {
      case NotificationFilter.delays:
        return 'No Delay Alerts';
      case NotificationFilter.arrivals:
        return 'No Arrival Alerts';
      case NotificationFilter.all:
        return 'All Caught Up!';
    }
  }

  String _getEmptySubtitle() {
    switch (_activeFilter) {
      case NotificationFilter.delays:
        return 'None of your tracked trains are experiencing delays right now.';
      case NotificationFilter.arrivals:
        return 'You will see checkpoint arrival and departure updates here.';
      case NotificationFilter.all:
        return 'New delay alerts and journey notifications will appear here in real time.';
    }
  }

  List<NotificationModel> _applyFilter(List<NotificationModel> items) {
    switch (_activeFilter) {
      case NotificationFilter.all:
        return items;
      case NotificationFilter.delays:
        return items.where((n) => n.type == NotificationType.delay).toList();
      case NotificationFilter.arrivals:
        return items.where((n) => n.type == NotificationType.arrival).toList();
    }
  }

  void _handleNotificationTap(NotificationModel item, String userId) async {
    if (!item.isRead) {
      await NotificationService.instance.markAsRead(userId, item.id);
    }

    if (!mounted) return;

    if (item.trainNumber != null || item.trainId != null) {
      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (ctx) => _buildDetailBottomSheet(item),
      );
    }
  }

  Widget _buildDetailBottomSheet(NotificationModel item) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                item.type == NotificationType.delay
                    ? Icons.warning_amber_rounded
                    : Icons.info_outline_rounded,
                color: item.type == NotificationType.delay
                    ? AppColors.statusDelayed
                    : AppColors.brandBlue,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            item.body,
            style: const TextStyle(fontSize: 14, height: 1.4),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.train_rounded),
            label: Text('View Train #${item.trainNumber ?? ''} Details'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brandBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.of(context).pop();
              context.push(AppRoutes.trainDetails);
            },
          ),
        ],
      ),
    );
  }

  void _handleDismiss(NotificationModel item, String userId) {
    NotificationService.instance.markAsRead(userId, item.id);
  }

  void _handleMarkAllAsRead(String userId) {
    NotificationService.instance.markAllAsRead(userId);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All notifications marked as read'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
