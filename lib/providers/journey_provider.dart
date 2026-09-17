import 'package:flutter/foundation.dart';

import '../core/services/firebase_service.dart';
import '../models/route_model.dart';
import '../models/train_model.dart';

/// Provider for Journey Planning and Train Search (Member 2).
///
/// Manages search parameters, queried train schedules, and filter state.
class JourneyProvider extends ChangeNotifier {
  List<TrainModel> _results = [];

  bool _isLoading = false;

  String? _errorMessage;

  String? _originStation;

  String? _destinationStation;

  DateTime? _travelDate;

  /// Current search results
  List<TrainModel> get results => List.unmodifiable(_results);

  /// Whether a search operation is currently running
  bool get isLoading => _isLoading;

  /// Error message from search if any
  String? get errorMessage => _errorMessage;

  /// Current origin station search filter
  String? get originStation => _originStation;

  /// Current destination station search filter
  String? get destinationStation => _destinationStation;

  /// Current selected travel date/time
  DateTime? get travelDate => _travelDate;

  /// Executes train search based on origin, destination,
  /// and selected travel date/time.
  Future<void> search({
    required String originStation,
    required String destinationStation,
    DateTime? travelDate,
  }) async {
    final cleanOrigin = originStation.trim();
    final cleanDestination = destinationStation.trim();

    // Validate origin and destination.
    if (cleanOrigin.isEmpty || cleanDestination.isEmpty) {
      _errorMessage = 'Please select both origin and destination stations.';
      _results = [];
      notifyListeners();
      return;
    }

    // Prevent same station selection.
    if (cleanOrigin.toLowerCase() == cleanDestination.toLowerCase()) {
      _errorMessage = 'Origin and destination stations must be different.';
      _results = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;

    _originStation = cleanOrigin;
    _destinationStation = cleanDestination;

    // Store the selected date/time.
    _travelDate = travelDate;

    notifyListeners();

    try {
      // ------------------------------------------------------------
      // STEP 1: Get routes from Firestore
      // ------------------------------------------------------------

      final routesSnapshot =
          await FirebaseService.instance.routesCollection.get();

      final validRouteIds = <String>{};

      for (final doc in routesSnapshot.docs) {
        final data = doc.data();

        final route = RouteModel.fromMap(
          data,
          id: doc.id,
        );

        // Check whether the selected origin comes before
        // the selected destination on this route.
        if (route.isValidJourney(
          cleanOrigin,
          cleanDestination,
        )) {
          validRouteIds.add(route.id);
        }
      }

      // No route found.
      if (validRouteIds.isEmpty) {
        _results = [];
        _errorMessage = 'No route was found between the selected stations.';
        return;
      }

      // ------------------------------------------------------------
      // STEP 2: Get trains from Firestore
      // ------------------------------------------------------------

      final trainsSnapshot =
          await FirebaseService.instance.trainsCollection.get();

      final matchingTrains = <TrainModel>[];

      for (final doc in trainsSnapshot.docs) {
        final data = doc.data();

        final train = TrainModel.fromMap(
          data,
          id: doc.id,
        );

        // Check whether the train belongs to a valid route.
        if (validRouteIds.contains(train.routeId)) {
          matchingTrains.add(train);
        }
      }

      // Store final results.
      _results = matchingTrains;

      // Inform the UI if no trains were found.
      if (_results.isEmpty) {
        _errorMessage = 'No trains were found for the selected journey.';
      }
    } catch (e) {
      _errorMessage = 'Failed to search trains.';
      _results = [];

      if (kDebugMode) {
        debugPrint('JourneyProvider search error: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clears the current search results,
  /// parameters, and errors.
  void clearResults() {
    _results = [];

    _errorMessage = null;

    _originStation = null;

    _destinationStation = null;

    _travelDate = null;

    notifyListeners();
  }
}
