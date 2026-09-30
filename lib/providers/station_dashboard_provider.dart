import 'dart:async';
import 'package:flutter/foundation.dart';
import '../core/services/firebase_service.dart';
import '../models/train_model.dart';

/// Provider for Station Master Live Checkpoint Dashboard (Member 4).
/// Reuses Member 3's Realtime Database listener pattern to monitor live checkpoint
/// hits for ONE specific station only.
///
/// NOTE: Strictly read-only per project requirements.
/// Proactive alerting and "UNKNOWN" train flagging are intentionally out of scope.
class StationDashboardProvider extends ChangeNotifier {
  String _stationId = 'colombo_fort';
  String _stationName = 'Colombo Fort';
  List<TrainModel> _stationTrains = [];
  StreamSubscription? _telemetrySubscription;
  bool _isLoading = false;
  String? _errorMessage;
  DateTime? _lastSyncTime;

  /// Assigned station ID
  String get stationId => _stationId;

  /// Assigned station display name
  String get stationName => _stationName;

  /// List of trains currently checked in or passing through this station
  List<TrainModel> get stationTrains => List.unmodifiable(_stationTrains);

  /// Whether active listening is currently loading or connected
  bool get isLoading => _isLoading;

  /// Error message if telemetry fails
  String? get errorMessage => _errorMessage;

  /// Last sync timestamp
  DateTime? get lastSyncTime => _lastSyncTime;

  /// Predefined stations list for Station Master switcher
  static const List<Map<String, String>> availableStations = [
    {'id': 'colombo_fort', 'name': 'Colombo Fort'},
    {'id': 'gampaha', 'name': 'Gampaha'},
    {'id': 'veyangoda', 'name': 'Veyangoda'},
    {'id': 'polgahawela', 'name': 'Polgahawela Junction'},
    {'id': 'kurunegala', 'name': 'Kurunegala'},
    {'id': 'peradeniya', 'name': 'Peradeniya Junction'},
    {'id': 'kandy', 'name': 'Kandy'},
    {'id': 'galle', 'name': 'Galle'},
  ];

  /// Starts listening to Firebase Realtime Database live tracking node,
  /// filtered strictly to checkpoint hits for [targetStationId] / [targetStationName].
  void startListening(String targetStationId, {String? targetStationName}) {
    stopListening();

    _stationId = targetStationId;
    _stationName = targetStationName ??
        availableStations.firstWhere(
          (s) => s['id'] == targetStationId,
          orElse: () => {'name': targetStationId},
        )['name']!;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _telemetrySubscription = FirebaseService.instance.liveTrackingRef.onValue.listen(
        (event) {
          final snapshotValue = event.snapshot.value;
          if (snapshotValue == null) {
            _stationTrains = [];
            _isLoading = false;
            _lastSyncTime = DateTime.now();
            notifyListeners();
            return;
          }

          final List<TrainModel> matchedTrains = [];

          if (snapshotValue is Map) {
            snapshotValue.forEach((key, value) {
              if (value is Map) {
                final train = TrainModel.fromRealtimeDb(value, id: key.toString());
                // Filter strictly to this station's checkpoint hits only
                if (_isTrainAtThisStation(train)) {
                  matchedTrains.add(train);
                }
              }
            });
          }

          _stationTrains = matchedTrains;
          _isLoading = false;
          _lastSyncTime = DateTime.now();
          notifyListeners();
        },
        onError: (error) {
          _errorMessage = 'Live connection error: $error';
          _isLoading = false;
          notifyListeners();
        },
      );
    } catch (e) {
      _errorMessage = 'Failed to connect to station checkpoint stream: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Helper to determine if a train's current checkpoint matches this station
  bool _isTrainAtThisStation(TrainModel train) {
    final current = train.currentStation.trim().toLowerCase();
    final targetName = _stationName.trim().toLowerCase();
    final targetId = _stationId.trim().toLowerCase();

    return current == targetName ||
        current == targetId ||
        current.contains(targetName) ||
        targetName.contains(current);
  }

  /// Injects simulated mock checkpoint updates for testing or offline demonstration
  void setMockCheckpointData(List<TrainModel> trains) {
    _stationTrains = trains.where(_isTrainAtThisStation).toList();
    _lastSyncTime = DateTime.now();
    _isLoading = false;
    notifyListeners();
  }

  /// Stops Realtime Database subscription
  void stopListening() {
    _telemetrySubscription?.cancel();
    _telemetrySubscription = null;
    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    stopListening();
    super.dispose();
  }
}
