/// Canonical Train Model for the Railway Tracker application.
/// Shared across Journey Planner (Member 2), Live Tracking (Member 3),
/// Notifications (Member 4), and Driver Check-in (Member 5).
class TrainModel {
  final String id;
  final String trainNumber;
  final String name;
  final String routeId;
  final String currentStation;
  final String? nextStation;
  final String scheduledDeparture;
  final String? actualDeparture;
  final int delayMinutes;
  final String status; // 'on-time', 'delayed', 'stopped', 'cancelled'
  final double? latitude;
  final double? longitude;
  final double? speedKmH;
  final String? lastUpdated;

  const TrainModel({
    required this.id,
    required this.trainNumber,
    required this.name,
    required this.routeId,
    required this.currentStation,
    this.nextStation,
    required this.scheduledDeparture,
    this.actualDeparture,
    this.delayMinutes = 0,
    required this.status,
    this.latitude,
    this.longitude,
    this.speedKmH,
    this.lastUpdated,
  });

  /// Check if the train is currently running late
  bool get isDelayed => delayMinutes > 0 || status.toLowerCase() == 'delayed';

  /// Check if the train is operating on schedule
  bool get isOnTime => delayMinutes == 0 && status.toLowerCase() == 'on-time';

  /// Check if the train is stopped at a station or halted on tracks
  bool get isStopped => status.toLowerCase() == 'stopped';

  /// Create a [TrainModel] from a standard Map or Firestore document data
  factory TrainModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return TrainModel(
      id: id ?? map['id']?.toString() ?? '',
      trainNumber: map['trainNumber']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      routeId: map['routeId']?.toString() ?? '',
      currentStation: map['currentStation']?.toString() ?? '',
      nextStation: map['nextStation']?.toString(),
      scheduledDeparture: map['scheduledDeparture']?.toString() ?? '',
      actualDeparture: map['actualDeparture']?.toString(),
      delayMinutes: _parseInt(map['delayMinutes']),
      status: map['status']?.toString().toLowerCase() ?? 'on-time',
      latitude: _parseDouble(map['latitude']),
      longitude: _parseDouble(map['longitude']),
      speedKmH: _parseDouble(map['speedKmH']),
      lastUpdated: map['lastUpdated']?.toString(),
    );
  }

  /// Create a [TrainModel] from Firebase Realtime Database telemetry
  factory TrainModel.fromRealtimeDb(Map<dynamic, dynamic> map, {String? id}) {
    final converted = map.map(
      (key, value) => MapEntry(key.toString(), value),
    );
    return TrainModel.fromMap(converted, id: id);
  }

  /// Convert to standard Map for Firestore or Realtime Database writes
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'trainNumber': trainNumber,
      'name': name,
      'routeId': routeId,
      'currentStation': currentStation,
      if (nextStation != null) 'nextStation': nextStation,
      'scheduledDeparture': scheduledDeparture,
      if (actualDeparture != null) 'actualDeparture': actualDeparture,
      'delayMinutes': delayMinutes,
      'status': status,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (speedKmH != null) 'speedKmH': speedKmH,
      if (lastUpdated != null) 'lastUpdated': lastUpdated,
    };
  }

  TrainModel copyWith({
    String? id,
    String? trainNumber,
    String? name,
    String? routeId,
    String? currentStation,
    String? nextStation,
    String? scheduledDeparture,
    String? actualDeparture,
    int? delayMinutes,
    String? status,
    double? latitude,
    double? longitude,
    double? speedKmH,
    String? lastUpdated,
  }) {
    return TrainModel(
      id: id ?? this.id,
      trainNumber: trainNumber ?? this.trainNumber,
      name: name ?? this.name,
      routeId: routeId ?? this.routeId,
      currentStation: currentStation ?? this.currentStation,
      nextStation: nextStation ?? this.nextStation,
      scheduledDeparture: scheduledDeparture ?? this.scheduledDeparture,
      actualDeparture: actualDeparture ?? this.actualDeparture,
      delayMinutes: delayMinutes ?? this.delayMinutes,
      status: status ?? this.status,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      speedKmH: speedKmH ?? this.speedKmH,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString());
  }

  @override
  String toString() =>
      'TrainModel(id: $id, trainNumber: $trainNumber, name: $name, currentStation: $currentStation, delay: $delayMinutes min, status: $status)';
}
