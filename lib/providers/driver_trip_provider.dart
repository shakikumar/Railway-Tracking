import 'package:flutter/foundation.dart';

/// Provider for Driver Trip Lifecycle & BLE Configuration State (Member 5).
/// Holds the driver's active trip configuration parameters per the TRAIN_PAIRING_SERVICE spec.
class DriverTripProvider extends ChangeNotifier {
  // BLE Pairing & Trip Parameters (null when unconfigured)
  String? _trainNo;
  String? _routeId;
  String? _direction;
  String? _driverId;
  DateTime? _shiftStartTs;

  bool _isTripActive = false;

  /// Assigned train number (e.g., '1001')
  String? get trainNo => _trainNo;

  /// Route identifier (e.g., 'route_coastal_01')
  String? get routeId => _routeId;

  /// Journey direction (e.g., 'up' or 'down')
  String? get direction => _direction;

  /// Authenticated driver identifier
  String? get driverId => _driverId;

  /// Shift start timestamp
  DateTime? get shiftStartTs => _shiftStartTs;

  /// Whether the driver currently has an initialized/configured trip
  bool get isConfigured =>
      _trainNo != null && _routeId != null && _driverId != null;

  /// Whether the trip has actively started and telemetry is broadcasting
  bool get isTripActive => _isTripActive;

  /// Configures driver trip parameters from QR code or manual setup screen.
  /// TODO (Member 5): Validate against Firestore driver profile and prepare
  /// payload for [BleService.writeTripConfig].
  void configureTrip({
    required String trainNo,
    required String routeId,
    required String direction,
    required String driverId,
    DateTime? shiftStartTs,
  }) {
    _trainNo = trainNo;
    _routeId = routeId;
    _direction = direction;
    _driverId = driverId;
    _shiftStartTs = shiftStartTs ?? DateTime.now();
    notifyListeners();
  }

  /// Sets trip status to running
  void startTrip() {
    if (!isConfigured) return;
    _isTripActive = true;
    notifyListeners();
  }

  /// Ends the trip and clears active parameters
  void endTrip() {
    _isTripActive = false;
    clearTrip();
  }

  /// Clears active trip configuration
  void clearTrip() {
    _trainNo = null;
    _routeId = null;
    _direction = null;
    _driverId = null;
    _shiftStartTs = null;
    _isTripActive = false;
    notifyListeners();
  }

  /// Generates the byte/map payload for BLE pairing transmission
  Map<String, dynamic> toGattPayload() {
    return {
      'train_no': _trainNo ?? '',
      'route_id': _routeId ?? '',
      'direction': _direction ?? '',
      'driver_id': _driverId ?? '',
      'shift_start_ts': _shiftStartTs?.millisecondsSinceEpoch ?? 0,
    };
  }
}
