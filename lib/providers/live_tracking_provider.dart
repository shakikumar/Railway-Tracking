import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/train_model.dart';
import '../core/services/firebase_service.dart';

/// Provider for Real-Time Train Telemetry & GPS Tracking (Member 3).
/// Listens to Firebase Realtime Database updates for train coordinates,
/// station checkpoints, delay status, and speed.
class LiveTrackingProvider extends ChangeNotifier {
  TrainModel? _activeTrain;
  StreamSubscription? _telemetrySubscription;
  bool _isTracking = false;
  String? _errorMessage;

  /// The train currently being tracked in real time
  TrainModel? get activeTrain => _activeTrain;

  /// Whether active telemetry listening is enabled
  bool get isTracking => _isTracking;

  /// Telemetry error message if any
  String? get errorMessage => _errorMessage;

  /// Begins listening to Firebase Realtime Database for live checkpoint and GPS updates.
  /// TODO (Member 3): Connect to `FirebaseService.instance.trainLiveRef(trainId)`
  /// and deserialize incoming snapshots with `TrainModel.fromRealtimeDb`.
  void startTracking(String trainId) {
    stopTracking();

    _isTracking = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // TODO (Member 3): Attach Realtime Database `.onValue` stream:
      // _telemetrySubscription = FirebaseService.instance
      //     .trainLiveRef(trainId)
      //     .onValue
      //     .listen((event) {
      //   if (event.snapshot.value != null) {
      //     final data = event.snapshot.value as Map<dynamic, dynamic>;
      //     _activeTrain = TrainModel.fromRealtimeDb(data, id: trainId);
      //     notifyListeners();
      //   }
      // });
    } catch (e) {
      _errorMessage = 'Failed to connect to train telemetry: $e';
      _isTracking = false;
      notifyListeners();
    }
  }

  /// Placeholder listener method invoked when a station checkpoint or coordinate arrives.
  /// Can be called directly by mock generators or tests.
  void onCheckpointUpdate(TrainModel updatedTrain) {
    _activeTrain = updatedTrain;
    notifyListeners();
  }

  /// Detaches the Realtime Database listener and stops tracking
  void stopTracking() {
    _telemetrySubscription?.cancel();
    _telemetrySubscription = null;
    _isTracking = false;
    notifyListeners();
  }

  @override
  void dispose() {
    stopTracking();
    super.dispose();
  }
}
