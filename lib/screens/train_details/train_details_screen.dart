import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../models/train_model.dart';
import 'widgets/train_header_card.dart';
import 'widgets/live_telemetry_chip.dart';
import 'widgets/train_actions_bar.dart';
import 'widgets/route_timeline_view.dart';

/// Screen displaying complete schedule, live delay status, route timeline,
/// and live telemetry actions for a specific train service.
class TrainDetailsScreen extends StatelessWidget {
  /// Optional train model passed directly (e.g. for testing or widget previews)
  final TrainModel? train;

  const TrainDetailsScreen({
    super.key,
    this.train,
  });

  @override
  Widget build(BuildContext context) {
    // Extract TrainModel from constructor or GoRouter extra state
    final selectedTrain = train ?? (GoRouterState.of(context).extra as TrainModel?);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text(
          selectedTrain != null && selectedTrain.trainNumber.isNotEmpty
              ? 'Train #${selectedTrain.trainNumber}'
              : 'Train Details',
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
        actions: [
          if (selectedTrain != null)
            IconButton(
              icon: const Icon(Icons.share_outlined, size: 20),
              tooltip: 'Share Train Status',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Train #${selectedTrain.trainNumber} status: ${selectedTrain.status.toUpperCase()} (${selectedTrain.isDelayed ? '+${selectedTrain.delayMinutes}m delay' : 'On-time'})',
                    ),
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
        ],
      ),
      body: selectedTrain == null
          ? _buildEmptyState(context, isDark)
          : _buildDetailsContent(context, selectedTrain, isDark),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceElevated : AppColors.brandBlue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.train_outlined,
                size: 56,
                color: isDark ? AppColors.brandBlueLight : AppColors.brandBlue,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No Train Selected',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please select a train from Search Results or Journey Planner to view live schedule details and route progress.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/');
                }
              },
              icon: const Icon(Icons.arrow_back_rounded, size: 18),
              label: const Text('Go Back'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brandBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsContent(BuildContext context, TrainModel train, bool isDark) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Train Header Card (Identification, Status, Departure, Overview)
            TrainHeaderCard(train: train),

            const SizedBox(height: 14),

            // 2. Live Telemetry Information Chip
            LiveTelemetryChip(train: train),

            const SizedBox(height: 14),

            // 3. Action Buttons (Live Map, Favorite, Notifications)
            TrainActionsBar(train: train),

            const SizedBox(height: 16),

            // 4. Visual Station Checkpoint Timeline
            RouteTimelineView(train: train),

            const SizedBox(height: 16),

            // 5. Additional Service Information Card
            _buildServiceMetadataCard(train, isDark),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceMetadataCard(TrainModel train, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
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
          Text(
            'SERVICE SPECIFICATIONS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
            ),
          ),
          const SizedBox(height: 12),
          _buildMetaRow('Train ID', train.id.isNotEmpty ? train.id : 'N/A', isDark),
          _buildMetaRow('Route Code', train.routeId.isNotEmpty ? train.routeId : 'N/A', isDark),
          _buildMetaRow(
            'Operational Status',
            train.status.toUpperCase(),
            isDark,
            valueColor: train.isDelayed
                ? AppColors.statusDelayed
                : (train.isOnTime ? AppColors.statusOnTime : null),
          ),
          if (train.actualDeparture != null && train.actualDeparture!.isNotEmpty)
            _buildMetaRow('Recorded Departure', train.actualDeparture!, isDark),
        ],
      ),
    );
  }

  Widget _buildMetaRow(String label, String value, bool isDark, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: valueColor ?? (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
