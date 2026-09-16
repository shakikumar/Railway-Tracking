import 'package:flutter/foundation.dart';
import '../models/train_model.dart';

/// Provider for Journey Planning and Train Search (Member 2).
/// Manages search parameters, queried train schedules, and filter state.
class JourneyProvider extends ChangeNotifier {
  List<TrainModel> _results = [];
  bool _isLoading = false;
  String? _errorMessage;

  /// Current search results
  List<TrainModel> get results => List.unmodifiable(_results);

  /// Whether a search operation is currently running
  bool get isLoading => _isLoading;

  /// Error message from search if any
  String? get errorMessage => _errorMessage;

  /// Executes train search based on origin, destination, and optional date.
  /// TODO (Member 2): Query Firestore `routes` and `trains` collections
  /// to find matching trains between [originStation] and [destinationStation].
  Future<void> search({
    required String originStation,
    required String destinationStation,
    DateTime? travelDate,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // TODO (Member 2): Implement Firestore query & route validation logic
      // e.g.,
      // final trains = await FirebaseService.instance.trainsCollection.where(...).get();
      _results = [];
    } catch (e) {
      _errorMessage = 'Failed to search trains: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clears the current search results and errors
  void clearResults() {
    _results = [];
    _errorMessage = null;
    notifyListeners();
  }
}
