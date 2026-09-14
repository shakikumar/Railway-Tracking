/// Canonical Railway Route Model.
/// Defines railway routes, terminal stations, and ordered station checkpoints.
/// Used by Member 2 (Journey Search) and Member 3 (Live Progress Bar / Stops).
class RouteModel {
  final String id;
  final String routeName;
  final String originStation;
  final String destinationStation;
  final List<String> stationCheckpoints;
  final List<int> stopDurationsMinutes;

  const RouteModel({
    required this.id,
    required this.routeName,
    required this.originStation,
    required this.destinationStation,
    required this.stationCheckpoints,
    this.stopDurationsMinutes = const [],
  });

  /// Total number of station checkpoints along the route
  int get totalStops => stationCheckpoints.length;

  /// Check whether a given station is served by this route (case-insensitive)
  bool containsStation(String stationName) {
    final target = stationName.trim().toLowerCase();
    return stationCheckpoints.any((s) => s.trim().toLowerCase() == target);
  }

  /// Get the 0-indexed position of a station along the route (-1 if not found)
  int stationIndex(String stationName) {
    final target = stationName.trim().toLowerCase();
    return stationCheckpoints.indexWhere((s) => s.trim().toLowerCase() == target);
  }

  /// Returns true if origin comes before destination along this route
  bool isValidJourney(String origin, String destination) {
    final fromIdx = stationIndex(origin);
    final toIdx = stationIndex(destination);
    return fromIdx != -1 && toIdx != -1 && fromIdx < toIdx;
  }

  /// Create a [RouteModel] from a Map or Firestore document data
  factory RouteModel.fromMap(Map<String, dynamic> map, {String? id}) {
    final checkpointsRaw = map['stationCheckpoints'];
    List<String> checkpoints = [];
    if (checkpointsRaw is List) {
      checkpoints = checkpointsRaw.map((e) => e.toString()).toList();
    }

    final durationsRaw = map['stopDurationsMinutes'];
    List<int> durations = [];
    if (durationsRaw is List) {
      durations = durationsRaw.map((e) {
        if (e is int) return e;
        return int.tryParse(e.toString()) ?? 0;
      }).toList();
    }

    final origin = map['originStation']?.toString() ??
        (checkpoints.isNotEmpty ? checkpoints.first : '');
    final dest = map['destinationStation']?.toString() ??
        (checkpoints.isNotEmpty ? checkpoints.last : '');

    return RouteModel(
      id: id ?? map['id']?.toString() ?? '',
      routeName: map['routeName']?.toString() ?? '',
      originStation: origin,
      destinationStation: dest,
      stationCheckpoints: checkpoints,
      stopDurationsMinutes: durations,
    );
  }

  /// Convert to standard Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'routeName': routeName,
      'originStation': originStation,
      'destinationStation': destinationStation,
      'stationCheckpoints': stationCheckpoints,
      'stopDurationsMinutes': stopDurationsMinutes,
    };
  }

  RouteModel copyWith({
    String? id,
    String? routeName,
    String? originStation,
    String? destinationStation,
    List<String>? stationCheckpoints,
    List<int>? stopDurationsMinutes,
  }) {
    return RouteModel(
      id: id ?? this.id,
      routeName: routeName ?? this.routeName,
      originStation: originStation ?? this.originStation,
      destinationStation: destinationStation ?? this.destinationStation,
      stationCheckpoints: stationCheckpoints ?? this.stationCheckpoints,
      stopDurationsMinutes: stopDurationsMinutes ?? this.stopDurationsMinutes,
    );
  }

  @override
  String toString() =>
      'RouteModel(id: $id, routeName: $routeName, origin: $originStation, destination: $destinationStation, stops: ${stationCheckpoints.length})';
}
