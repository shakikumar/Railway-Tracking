import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/train_model.dart';

/// Telemetry display widget showing live GPS coordinates, speed, and real-time status.
class LiveTelemetryChip extends StatelessWidget {
  final TrainModel train;

  const LiveTelemetryChip({
    super.key,
    required this.train,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasTelemetry = train.speedKmH != null || (train.latitude != null && train.longitude != null);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Row(
        children: [
          // Live pulse icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: hasTelemetry
                  ? AppColors.statusOnTime.withValues(alpha: 0.12)
                  : (isDark ? AppColors.darkSurfaceElevated : AppColors.lightBackground),
              shape: BoxShape.circle,
            ),
            child: Icon(
              hasTelemetry ? Icons.sensors_rounded : Icons.sensors_off_rounded,
              size: 20,
              color: hasTelemetry ? AppColors.statusOnTime : (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
            ),
          ),
          const SizedBox(width: 12),

          // Telemetry Information
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      hasTelemetry ? 'LIVE TELEMETRY' : 'TELEMETRY STATUS',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: hasTelemetry ? AppColors.brandBlue : (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
                      ),
                    ),
                    if (hasTelemetry) ...[
                      const SizedBox(width: 6),
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: AppColors.statusOnTime,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                if (hasTelemetry) ...[
                  Row(
                    children: [
                      if (train.speedKmH != null)
                        Text(
                          '${train.speedKmH!.toStringAsFixed(1)} km/h',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          ),
                        ),
                      if (train.speedKmH != null && train.latitude != null && train.longitude != null)
                        Text(
                          ' • ',
                          style: TextStyle(
                            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                          ),
                        ),
                      if (train.latitude != null && train.longitude != null)
                        Expanded(
                          child: Text(
                            '${train.latitude!.toStringAsFixed(4)}, ${train.longitude!.toStringAsFixed(4)}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ] else ...[
                  Text(
                    'No active GPS or speed telemetry stream',
                    style: TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
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
