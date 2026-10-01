import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../models/train_model.dart';
import '../../../../providers/station_dashboard_provider.dart';
import 'widgets/checkpoint_hit_card.dart';
import 'widgets/station_selector_bar.dart';

/// Station Master Dashboard Screen (Member 4).
/// Provides a read-only live window into checkpoint hits for ONE assigned station.
/// Reuses Member 3's Realtime Database listener pattern.
///
/// SCOPE PROTECTION:
/// Strictly read-only; no manual mutations, no interactive controls,
/// and no anomalous/unknown train alerting logic.
class StationMasterDashboardScreen extends StatefulWidget {
  final String? initialStationId;

  const StationMasterDashboardScreen({
    super.key,
    this.initialStationId,
  });

  @override
  State<StationMasterDashboardScreen> createState() =>
      _StationMasterDashboardScreenState();
}

class _StationMasterDashboardScreenState
    extends State<StationMasterDashboardScreen> {
  // Fallback demo trains representing live checkpoint arrivals at the selected station
  final List<TrainModel> _fallbackCheckpointHits = [
    const TrainModel(
      id: 'train_1001',
      trainNumber: '1001',
      name: 'Rajarata Rejina',
      routeId: 'route_colombo_anuradhapura',
      currentStation: 'Colombo Fort',
      nextStation: 'Ragama Junction',
      scheduledDeparture: '05:45 AM',
      actualDeparture: '06:10 AM',
      delayMinutes: 25,
      status: 'delayed',
      speedKmH: 0.0,
      lastUpdated: '06:10 AM',
    ),
    const TrainModel(
      id: 'train_1015',
      trainNumber: '1015',
      name: 'Udarata Menike',
      routeId: 'route_colombo_badulla',
      currentStation: 'Colombo Fort',
      nextStation: 'Gampaha',
      scheduledDeparture: '08:30 AM',
      actualDeparture: '08:30 AM',
      delayMinutes: 0,
      status: 'on-time',
      speedKmH: 0.0,
      lastUpdated: '08:30 AM',
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<StationDashboardProvider>();
      final stationId = widget.initialStationId ?? provider.stationId;
      provider.startListening(stationId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<StationDashboardProvider>(
      builder: (context, provider, child) {
        final currentStationName = provider.stationName;
        final liveHits = provider.stationTrains;

        // Use live Realtime Database hits, or fallback data if no live simulator is broadcasting
        final hits = liveHits.isNotEmpty ? liveHits : _fallbackCheckpointHits;

        final onTimeCount = hits.where((t) => t.isOnTime).length;
        final delayedCount = hits.where((t) => t.isDelayed).length;

        return Scaffold(
          backgroundColor:
              isDark ? AppColors.darkBackground : AppColors.lightBackground,
          appBar: AppBar(
            title: const Text('Station Master Dashboard'),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh_rounded),
                tooltip: 'Refresh Feed',
                onPressed: () {
                  provider.startListening(provider.stationId);
                },
              ),
            ],
          ),
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                provider.startListening(provider.stationId);
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. Station Selector & Realtime Connectivity Bar
                    StationSelectorBar(
                      currentStationId: provider.stationId,
                      currentStationName: currentStationName,
                      stations: StationDashboardProvider.availableStations,
                      isLive: provider.errorMessage == null,
                      onStationChanged: (newStationId) {
                        provider.startListening(newStationId);
                      },
                    ),

                    const SizedBox(height: 16),

                    // 2. Summary Statistics Card (Read-only)
                    _buildStatsRow(
                      total: hits.length,
                      onTime: onTimeCount,
                      delayed: delayedCount,
                      isDark: isDark,
                    ),

                    const SizedBox(height: 20),

                    // 3. Section Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'LIVE CHECKPOINT HITS — $currentStationName'
                              .toUpperCase(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.7,
                            color: isDark
                                ? AppColors.darkTextMuted
                                : AppColors.lightTextMuted,
                          ),
                        ),
                        if (provider.isLoading)
                          const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // 4. Checkpoint Hits List (Filtered to this station only)
                    if (hits.isEmpty)
                      _buildEmptyState(currentStationName, isDark)
                    else
                      ...hits.map(
                        (train) => CheckpointHitCard(
                          train: train,
                          stationName: currentStationName,
                        ),
                      ),

                    const SizedBox(height: 20),

                    // Scope & Read-only Compliance Footer Notice
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkSurfaceElevated
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark
                              ? AppColors.darkBorder
                              : AppColors.lightBorder,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.lock_clock_outlined,
                            size: 16,
                            color: isDark
                                ? AppColors.darkTextMuted
                                : AppColors.lightTextMuted,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Station Master view is strictly read-only. Checkpoint arrivals update automatically via Firebase Realtime Database telemetry.',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark
                                    ? AppColors.darkTextMuted
                                    : AppColors.lightTextMuted,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatsRow({
    required int total,
    required int onTime,
    required int delayed,
    required bool isDark,
  }) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricTile(
            title: 'At Station',
            count: total.toString(),
            color: AppColors.brandBlue,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildMetricTile(
            title: 'On-Time',
            count: onTime.toString(),
            color: AppColors.statusOnTime,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildMetricTile(
            title: 'Delayed',
            count: delayed.toString(),
            color: AppColors.statusDelayed,
            isDark: isDark,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricTile({
    required String title,
    required String count,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            count,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String stationName, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.train_outlined,
              size: 44,
              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
            ),
            const SizedBox(height: 12),
            Text(
              'No Trains Currently at $stationName',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Checkpoint hits will automatically appear when trains reach this station.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
