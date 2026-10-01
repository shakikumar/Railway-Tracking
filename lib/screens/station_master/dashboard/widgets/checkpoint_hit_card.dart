import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../models/train_model.dart';

/// Read-only Checkpoint Hit Card for Station Master Dashboard (Member 4).
/// Displays live recorded arrivals and platform presence for one station.
///
/// NOTE: Strictly read-only without mutation controls or anomalous train alerts.
class CheckpointHitCard extends StatelessWidget {
  final TrainModel train;
  final String stationName;

  const CheckpointHitCard({
    super.key,
    required this.train,
    required this.stationName,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final (statusColor, statusBg, statusText) = _getStatusStyle(train);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Train number, train name, and operational status badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.brandBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '#${train.trainNumber}',
                    style: const TextStyle(
                      color: AppColors.brandBlue,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        train.name.isNotEmpty ? train.name : 'Express Service',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Route: ${train.routeId.isNotEmpty ? train.routeId : 'Main Line'}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),
            Divider(height: 1, color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
            const SizedBox(height: 12),

            // Checkpoint Hit details grid
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    label: 'SCHEDULED DEPARTURE',
                    value: train.scheduledDeparture.isNotEmpty
                        ? train.scheduledDeparture
                        : '--:--',
                    isDark: isDark,
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    label: 'RECORDED AT STATION',
                    value: train.actualDeparture?.isNotEmpty == true
                        ? train.actualDeparture!
                        : (train.lastUpdated?.isNotEmpty == true
                            ? train.lastUpdated!
                            : 'Present'),
                    isDark: isDark,
                    valueColor: train.isDelayed
                        ? AppColors.statusDelayed
                        : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    label: 'BOUND FOR (NEXT)',
                    value: train.nextStation?.isNotEmpty == true
                        ? train.nextStation!
                        : 'Terminating / End of Line',
                    isDark: isDark,
                  ),
                ),
                if (train.speedKmH != null)
                  Expanded(
                    child: _buildInfoItem(
                      label: 'CURRENT SPEED',
                      value: '${train.speedKmH!.toStringAsFixed(1)} km/h',
                      isDark: isDark,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required String label,
    required String value,
    required bool isDark,
    Color? valueColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: valueColor ??
                (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  (Color, Color, String) _getStatusStyle(TrainModel train) {
    if (train.isDelayed) {
      return (
        AppColors.statusDelayed,
        AppColors.statusDelayedBg,
        '+${train.delayMinutes}m DELAY',
      );
    } else if (train.isStopped) {
      return (
        AppColors.statusStopped,
        AppColors.statusStoppedBg,
        'HALTED AT PLATFORM',
      );
    } else {
      return (
        AppColors.statusOnTime,
        AppColors.statusOnTimeBg,
        'ON-TIME',
      );
    }
  }
}
