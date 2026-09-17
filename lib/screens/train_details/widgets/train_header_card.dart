import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/train_model.dart';

/// Header card displaying train identification, status badge, departure times,
/// and current segment status.
class TrainHeaderCard extends StatelessWidget {
  final TrainModel train;

  const TrainHeaderCard({
    super.key,
    required this.train,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusStyle = _getStatusStyle(train);

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
            // Row 1: Train Number Chip & Status Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Train number tag
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurfaceElevated : AppColors.brandBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDark ? AppColors.brandBlueLight.withValues(alpha: 0.4) : AppColors.brandBlue.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    train.trainNumber.isNotEmpty ? 'Train #${train.trainNumber}' : 'Train Details',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.brandBlueLight : AppColors.brandBlue,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),

                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusStyle.backgroundColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusStyle.borderColor),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        statusStyle.icon,
                        size: 14,
                        color: statusStyle.foregroundColor,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        statusStyle.label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: statusStyle.foregroundColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Row 2: Train Name
            Text(
              train.name.isNotEmpty ? train.name : 'Express Train',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),

            const SizedBox(height: 14),
            Divider(
              height: 1,
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
            const SizedBox(height: 14),

            // Row 3: Current & Next Station overview
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CURRENT STATION',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        train.currentStation.isNotEmpty ? train.currentStation : 'Not Available',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 20,
                  color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'NEXT STATION',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        (train.nextStation != null && train.nextStation!.isNotEmpty)
                            ? train.nextStation!
                            : 'Terminal / N/A',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.end,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Row 4: Departure Time & Delay Details
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceElevated : AppColors.lightBackground,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.schedule_rounded,
                        size: 16,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Scheduled: ${train.scheduledDeparture.isNotEmpty ? train.scheduledDeparture : 'N/A'}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                  if (train.actualDeparture != null && train.actualDeparture!.isNotEmpty)
                    Row(
                      children: [
                        Icon(
                          Icons.departure_board_rounded,
                          size: 16,
                          color: train.isDelayed ? AppColors.statusDelayed : AppColors.statusOnTime,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Actual: ${train.actualDeparture}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: train.isDelayed ? AppColors.statusDelayed : AppColors.statusOnTime,
                          ),
                        ),
                      ],
                    )
                  else if (train.delayMinutes > 0)
                    Text(
                      '+${train.delayMinutes} min delay',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.statusDelayed,
                      ),
                    ),
                ],
              ),
            ),

            if (train.lastUpdated != null && train.lastUpdated!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Last updated: ${train.lastUpdated}',
                  style: TextStyle(
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                    color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  _StatusBadgeStyle _getStatusStyle(TrainModel train) {
    final status = train.status.toLowerCase().trim();

    if (train.isDelayed || status == 'delayed') {
      final delayText = train.delayMinutes > 0 ? 'Delayed (${train.delayMinutes}m)' : 'Delayed';
      return _StatusBadgeStyle(
        label: delayText,
        icon: Icons.warning_amber_rounded,
        foregroundColor: AppColors.statusDelayed,
        backgroundColor: AppColors.statusDelayedBg,
        borderColor: AppColors.statusDelayed.withValues(alpha: 0.3),
      );
    }

    if (status == 'stopped' || train.isStopped) {
      return _StatusBadgeStyle(
        label: 'Stopped',
        icon: Icons.pause_circle_outline_rounded,
        foregroundColor: AppColors.statusStopped,
        backgroundColor: AppColors.statusStoppedBg,
        borderColor: AppColors.statusStopped.withValues(alpha: 0.3),
      );
    }

    if (status == 'cancelled') {
      return _StatusBadgeStyle(
        label: 'Cancelled',
        icon: Icons.cancel_outlined,
        foregroundColor: AppColors.statusStopped,
        backgroundColor: AppColors.statusStoppedBg,
        borderColor: AppColors.statusStopped.withValues(alpha: 0.3),
      );
    }

    if (status == 'scheduled') {
      return _StatusBadgeStyle(
        label: 'Scheduled',
        icon: Icons.calendar_today_outlined,
        foregroundColor: AppColors.statusScheduled,
        backgroundColor: AppColors.statusScheduledBg,
        borderColor: AppColors.statusScheduled.withValues(alpha: 0.3),
      );
    }

    if (train.isOnTime || status == 'on-time') {
      return _StatusBadgeStyle(
        label: 'On-Time',
        icon: Icons.check_circle_outline_rounded,
        foregroundColor: AppColors.statusOnTime,
        backgroundColor: AppColors.statusOnTimeBg,
        borderColor: AppColors.statusOnTime.withValues(alpha: 0.3),
      );
    }

    // Default / Unknown
    return _StatusBadgeStyle(
      label: status.isNotEmpty ? status[0].toUpperCase() + status.substring(1) : 'Scheduled',
      icon: Icons.info_outline_rounded,
      foregroundColor: AppColors.statusScheduled,
      backgroundColor: AppColors.statusScheduledBg,
      borderColor: AppColors.statusScheduled.withValues(alpha: 0.3),
    );
  }
}

class _StatusBadgeStyle {
  final String label;
  final IconData icon;
  final Color foregroundColor;
  final Color backgroundColor;
  final Color borderColor;

  const _StatusBadgeStyle({
    required this.label,
    required this.icon,
    required this.foregroundColor,
    required this.backgroundColor,
    required this.borderColor,
  });
}
