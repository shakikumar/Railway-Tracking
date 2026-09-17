import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/train_model.dart';

/// Vertical timeline representing the railway route checkpoints,
/// indicating passed, current, and upcoming stations.
class RouteTimelineView extends StatelessWidget {
  final TrainModel train;
  final List<String>? routeStations;

  const RouteTimelineView({
    super.key,
    required this.train,
    this.routeStations,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Determine the list of stations to display
    final List<String> stations = _resolveStations();
    final int currentIndex = _resolveCurrentStationIndex(stations);

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.alt_route_rounded,
                      size: 20,
                      color: isDark ? AppColors.brandBlueLight : AppColors.brandBlue,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'ROUTE PROGRESS & STOPS',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                  ],
                ),
                if (train.routeId.isNotEmpty)
                  Text(
                    'Route: ${train.routeId}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 16),
            Divider(
              height: 1,
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
            const SizedBox(height: 16),

            // Timeline Items List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: stations.length,
              itemBuilder: (context, index) {
                final stationName = stations[index];
                final isFirst = index == 0;
                final isLast = index == stations.length - 1;
                final isCurrent = index == currentIndex;
                final isPassed = currentIndex != -1 && index < currentIndex;
                final isUpcoming = currentIndex != -1 && index > currentIndex;

                return _TimelineTile(
                  stationName: stationName,
                  isFirst: isFirst,
                  isLast: isLast,
                  isCurrent: isCurrent,
                  isPassed: isPassed,
                  isUpcoming: isUpcoming,
                  isDark: isDark,
                  trainStatus: train.status,
                  delayMinutes: train.delayMinutes,
                  departureTime: isFirst ? train.scheduledDeparture : null,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Derives station checkpoint list from provided routeStations or train metadata
  List<String> _resolveStations() {
    if (routeStations != null && routeStations!.isNotEmpty) {
      return routeStations!;
    }

    final List<String> fallbackList = [];
    if (train.currentStation.isNotEmpty) {
      fallbackList.add(train.currentStation);
    }
    if (train.nextStation != null &&
        train.nextStation!.isNotEmpty &&
        !fallbackList.contains(train.nextStation)) {
      fallbackList.add(train.nextStation!);
    }

    if (fallbackList.isEmpty) {
      return ['Current Station (N/A)', 'Next Station (N/A)'];
    }

    return fallbackList;
  }

  int _resolveCurrentStationIndex(List<String> stations) {
    if (train.currentStation.isEmpty) return 0;
    final idx = stations.indexWhere(
      (s) => s.trim().toLowerCase() == train.currentStation.trim().toLowerCase(),
    );
    return idx != -1 ? idx : 0;
  }
}

class _TimelineTile extends StatelessWidget {
  final String stationName;
  final bool isFirst;
  final bool isLast;
  final bool isCurrent;
  final bool isPassed;
  final bool isUpcoming;
  final bool isDark;
  final String trainStatus;
  final int delayMinutes;
  final String? departureTime;

  const _TimelineTile({
    required this.stationName,
    required this.isFirst,
    required this.isLast,
    required this.isCurrent,
    required this.isPassed,
    required this.isUpcoming,
    required this.isDark,
    required this.trainStatus,
    required this.delayMinutes,
    this.departureTime,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left: Indicator and connecting line
          SizedBox(
            width: 36,
            child: Column(
              children: [
                // Top line segment
                Container(
                  width: 3,
                  height: 12,
                  color: isFirst
                      ? Colors.transparent
                      : (isPassed || isCurrent
                          ? AppColors.brandBlue
                          : (isDark ? AppColors.darkBorder : AppColors.lightBorder)),
                ),

                // Station Node Indicator
                _buildIndicator(),

                // Bottom line segment
                Expanded(
                  child: Container(
                    width: 3,
                    color: isLast
                        ? Colors.transparent
                        : (isPassed
                            ? AppColors.brandBlue
                            : (isDark ? AppColors.darkBorder : AppColors.lightBorder)),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Right: Station Name and Status
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20.0, top: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stationName,
                          style: TextStyle(
                            fontSize: isCurrent ? 16 : 14,
                            fontWeight: isCurrent
                                ? FontWeight.w800
                                : (isPassed ? FontWeight.w600 : FontWeight.w500),
                            color: isCurrent
                                ? (isDark ? AppColors.brandBlueLight : AppColors.brandBlue)
                                : (isPassed
                                    ? (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)
                                    : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
                          ),
                        ),
                        if (isCurrent)
                          Padding(
                            padding: const EdgeInsets.only(top: 2.0),
                            child: Text(
                              'Current location • ${trainStatus.toUpperCase()}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppColors.statusOnTime : AppColors.statusOnTime,
                              ),
                            ),
                          ),
                        if (isFirst && departureTime != null && !isCurrent)
                          Padding(
                            padding: const EdgeInsets.only(top: 2.0),
                            child: Text(
                              'Departs: $departureTime',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Status Tag on the right
                  if (isCurrent)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.brandBlue.withValues(alpha: 0.2) : AppColors.brandBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isDark ? AppColors.brandBlueLight.withValues(alpha: 0.4) : AppColors.brandBlue.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        'ACTIVE',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.brandBlueLight : AppColors.brandBlue,
                          letterSpacing: 0.5,
                        ),
                      ),
                    )
                  else if (isPassed)
                    Icon(
                      Icons.check_circle_rounded,
                      size: 16,
                      color: isDark ? AppColors.statusOnTime : AppColors.statusOnTime,
                    )
                  else
                    Text(
                      'Upcoming',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicator() {
    if (isCurrent) {
      return Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          color: AppColors.brandBlue,
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white,
            width: 2.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.brandBlue.withValues(alpha: 0.4),
              blurRadius: 6,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Center(
          child: Icon(
            Icons.train_rounded,
            size: 12,
            color: Colors.white,
          ),
        ),
      );
    }

    if (isPassed) {
      return Container(
        width: 14,
        height: 14,
        decoration: const BoxDecoration(
          color: AppColors.brandBlue,
          shape: BoxShape.circle,
        ),
      );
    }

    // Upcoming
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        shape: BoxShape.circle,
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 2.5,
        ),
      ),
    );
  }
}
