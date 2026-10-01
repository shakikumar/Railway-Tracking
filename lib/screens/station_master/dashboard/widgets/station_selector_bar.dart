import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Top bar for Station Master Dashboard with live status badge and station selector
class StationSelectorBar extends StatelessWidget {
  final String currentStationId;
  final String currentStationName;
  final List<Map<String, String>> stations;
  final ValueChanged<String> onStationChanged;
  final bool isLive;

  const StationSelectorBar({
    super.key,
    required this.currentStationId,
    required this.currentStationName,
    required this.stations,
    required this.onStationChanged,
    this.isLive = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Live pulsing telemetry pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isLive ? AppColors.statusOnTimeBg : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: isLive ? AppColors.statusOnTime : Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isLive ? 'LIVE RTDB FEED' : 'OFFLINE',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: isLive ? AppColors.statusOnTime : Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                'SINGLE STATION VIEW',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Station dropdown selector
          Row(
            children: [
              const Icon(
                Icons.account_balance_rounded,
                color: AppColors.brandBlue,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: currentStationId,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded),
                    dropdownColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                    items: stations.map((station) {
                      return DropdownMenuItem<String>(
                        value: station['id'],
                        child: Text(
                          station['name'] ?? '',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) onStationChanged(val);
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
