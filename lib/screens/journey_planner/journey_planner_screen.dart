import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/routes/app_routes.dart';
import '../../core/services/firebase_service.dart';
import '../../core/theme/app_colors.dart';
import '../../models/route_model.dart';
import '../../providers/journey_provider.dart';

class JourneyPlannerScreen extends StatefulWidget {
  const JourneyPlannerScreen({super.key});

  @override
  State<JourneyPlannerScreen> createState() => _JourneyPlannerScreenState();
}

class _JourneyPlannerScreenState extends State<JourneyPlannerScreen> {
  String? _selectedOrigin;
  String? _selectedDestination;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay? _selectedTime;

  List<String> _stations = [];
  bool _isLoadingStations = true;

  // Default station list for Sri Lanka Railway network as a resilient fallback
  static const List<String> _defaultStations = [
    'Anuradhapura',
    'Badulla',
    'Batticaloa',
    'Colombo Fort',
    'Galle',
    'Gampaha',
    'Jaffna',
    'Kalutara South',
    'Kandy',
    'Matara',
    'Moratuwa',
    'Mount Lavinia',
    'Nanu Oya',
    'Negombo',
    'Peradeniya',
    'Polgahawela',
    'Trincomalee',
  ];

  @override
  void initState() {
    super.initState();
    _fetchStations();
  }

  Future<void> _fetchStations() async {
    setState(() {
      _isLoadingStations = true;
    });

    try {
      final routesSnapshot =
          await FirebaseService.instance.routesCollection.get();

      final Set<String> stationSet = {};

      for (final doc in routesSnapshot.docs) {
        final route = RouteModel.fromMap(doc.data(), id: doc.id);
        for (final station in route.stationCheckpoints) {
          final trimmed = station.trim();
          if (trimmed.isNotEmpty) {
            stationSet.add(trimmed);
          }
        }
      }

      final sortedList = stationSet.isNotEmpty
          ? (stationSet.toList()..sort())
          : List<String>.from(_defaultStations);

      if (mounted) {
        setState(() {
          _stations = sortedList;
          _isLoadingStations = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _stations = List<String>.from(_defaultStations);
          _isLoadingStations = false;
        });
      }
    }
  }

  void _swapStations() {
    setState(() {
      final temp = _selectedOrigin;
      _selectedOrigin = _selectedDestination;
      _selectedDestination = temp;
    });
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryNavy,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.lightTextPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryNavy,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.lightTextPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _openStationPicker({required bool isOrigin}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return _StationSearchSheet(
          title: isOrigin
              ? 'Select Departure Station'
              : 'Select Destination Station',
          stations: _stations,
          excludedStation: isOrigin ? _selectedDestination : _selectedOrigin,
          onSelected: (station) {
            setState(() {
              if (isOrigin) {
                _selectedOrigin = station;
              } else {
                _selectedDestination = station;
              }
            });
            Navigator.pop(ctx);
          },
        );
      },
    );
  }

  Future<void> _handleSearch() async {
    final journeyProvider = context.read<JourneyProvider>();

    if (_selectedOrigin == null || _selectedOrigin!.isEmpty) {
      _showSnackbar('Please select a departure station.');
      return;
    }

    if (_selectedDestination == null || _selectedDestination!.isEmpty) {
      _showSnackbar('Please select a destination station.');
      return;
    }

    if (_selectedOrigin!.toLowerCase() == _selectedDestination!.toLowerCase()) {
      _showSnackbar('Departure and destination stations must be different.');
      return;
    }

    // Combine date and time into a single DateTime
    final travelDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime?.hour ?? 0,
      _selectedTime?.minute ?? 0,
    );

    await journeyProvider.search(
      originStation: _selectedOrigin!,
      destinationStation: _selectedDestination!,
      travelDate: travelDateTime,
    );

    if (!mounted) return;

    if (journeyProvider.errorMessage != null &&
        journeyProvider.results.isEmpty) {
      _showSnackbar(journeyProvider.errorMessage!);
    } else {
      context.push(AppRoutes.searchResults);
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.primaryNavy,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    final now = DateTime.now();
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return 'Today, ${date.day} ${months[date.month - 1]}';
    }
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatTime(TimeOfDay? time) {
    if (time == null) return 'Any Time';
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final journeyProvider = context.watch<JourneyProvider>();
    final isSearching = journeyProvider.isLoading;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardBg = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Plan Your Journey'),
        elevation: 0,
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      AppColors.primaryNavy,
                      AppColors.secondarySlate,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.directions_railway_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Plan Your Journey',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Find available trains for your route',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Main Journey Selection Card
              Container(
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: borderColor, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.alt_route_rounded,
                          color: AppColors.brandBlue,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Journey Details',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    if (_isLoadingStations)
                      Container(
                        padding: const EdgeInsets.all(24),
                        alignment: Alignment.center,
                        child: Column(
                          children: const [
                            SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Loading stations...',
                              style:
                                  TextStyle(fontSize: 13, color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    else ...[
                      // From Selector
                      _buildSelectorTile(
                        label: 'FROM',
                        value: _selectedOrigin ?? 'Select departure station',
                        icon: Icons.trip_origin_rounded,
                        iconColor: AppColors.brandBlue,
                        isSelected: _selectedOrigin != null,
                        onTap: () => _openStationPicker(isOrigin: true),
                        isDark: isDark,
                      ),

                      // Swap Control Button
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            const Expanded(child: Divider()),
                            Material(
                              color: isDark
                                  ? AppColors.darkSurfaceElevated
                                  : AppColors.lightBackground,
                              shape: const CircleBorder(),
                              elevation: 1,
                              child: InkWell(
                                onTap: _swapStations,
                                customBorder: const CircleBorder(),
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color:
                                          AppColors.brandBlue.withOpacity(0.3),
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.swap_vert_rounded,
                                    color: AppColors.brandBlue,
                                    size: 22,
                                  ),
                                ),
                              ),
                            ),
                            const Expanded(child: Divider()),
                          ],
                        ),
                      ),

                      // To Selector
                      _buildSelectorTile(
                        label: 'TO',
                        value: _selectedDestination ??
                            'Select destination station',
                        icon: Icons.place_rounded,
                        iconColor: AppColors.statusStopped,
                        isSelected: _selectedDestination != null,
                        onTap: () => _openStationPicker(isOrigin: false),
                        isDark: isDark,
                      ),

                      const SizedBox(height: 20),
                      const Divider(),
                      const SizedBox(height: 16),

                      // Date & Time Selectors Row
                      Row(
                        children: [
                          Expanded(
                            child: _buildSelectorTile(
                              label: 'TRAVEL DATE',
                              value: _formatDate(_selectedDate),
                              icon: Icons.calendar_today_rounded,
                              iconColor: AppColors.brandBlue,
                              isSelected: true,
                              onTap: _pickDate,
                              isDark: isDark,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildSelectorTile(
                              label: 'PREFERRED TIME',
                              value: _formatTime(_selectedTime),
                              icon: Icons.access_time_rounded,
                              iconColor: AppColors.brandBlue,
                              isSelected: _selectedTime != null,
                              onTap: _pickTime,
                              isDark: isDark,
                            ),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 24),

                    // Search Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: isSearching ? null : _handleSearch,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryNavy,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 2,
                        ),
                        child: isSearching
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    'Searching Trains...',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.search_rounded, size: 22),
                                  SizedBox(width: 8),
                                  Text(
                                    'Search Trains',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Popular Route Shortcuts
              Text(
                'Popular Routes',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: textSecondary,
                ),
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildShortcutChip(
                      origin: 'Colombo Fort',
                      destination: 'Kandy',
                      isDark: isDark,
                    ),
                    const SizedBox(width: 8),
                    _buildShortcutChip(
                      origin: 'Colombo Fort',
                      destination: 'Galle',
                      isDark: isDark,
                    ),
                    const SizedBox(width: 8),
                    _buildShortcutChip(
                      origin: 'Kandy',
                      destination: 'Badulla',
                      isDark: isDark,
                    ),
                    const SizedBox(width: 8),
                    _buildShortcutChip(
                      origin: 'Colombo Fort',
                      destination: 'Jaffna',
                      isDark: isDark,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Supporting Text Footer
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 15,
                      color: textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Live GPS telemetry available on search results',
                      style: TextStyle(
                        fontSize: 12,
                        color: textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectorTile({
    required String label,
    required String value,
    required IconData icon,
    required Color iconColor,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    final tileBg =
        isDark ? AppColors.darkSurfaceElevated : AppColors.lightBackground;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textMuted =
        isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: tileBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: textMuted,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(icon, size: 18, color: iconColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected ? textPrimary : textMuted,
                    ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 18,
                  color: textMuted,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShortcutChip({
    required String origin,
    required String destination,
    required bool isDark,
  }) {
    return ActionChip(
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      side: BorderSide(
        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      avatar: const Icon(
        Icons.flash_on_rounded,
        size: 14,
        color: AppColors.brandBlue,
      ),
      label: Text(
        '$origin → $destination',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color:
              isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
        ),
      ),
      onPressed: () {
        setState(() {
          _selectedOrigin = origin;
          _selectedDestination = destination;
        });
      },
    );
  }
}

class _StationSearchSheet extends StatefulWidget {
  final String title;
  final List<String> stations;
  final String? excludedStation;
  final ValueChanged<String> onSelected;

  const _StationSearchSheet({
    required this.title,
    required this.stations,
    this.excludedStation,
    required this.onSelected,
  });

  @override
  State<_StationSearchSheet> createState() => _StationSearchSheetState();
}

class _StationSearchSheetState extends State<_StationSearchSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkSurface : Colors.white;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    final filtered = widget.stations.where((station) {
      if (widget.excludedStation != null &&
          station.toLowerCase() == widget.excludedStation!.toLowerCase()) {
        return false;
      }
      if (_query.trim().isEmpty) return true;
      return station.toLowerCase().contains(_query.trim().toLowerCase());
    }).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _searchController,
            onChanged: (val) => setState(() => _query = val),
            decoration: InputDecoration(
              hintText: 'Search station...',
              prefixIcon: const Icon(Icons.search_rounded),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: filtered.isEmpty
                ? const Center(
                    child: Text(
                      'No matching stations found',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final station = filtered[index];
                      return ListTile(
                        leading: const Icon(
                          Icons.location_on_outlined,
                          color: AppColors.brandBlue,
                          size: 20,
                        ),
                        title: Text(
                          station,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: textPrimary,
                          ),
                        ),
                        onTap: () => widget.onSelected(station),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
