import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../models/train_model.dart';
import 'firebase_service.dart';

/// Service managing user favorite trains stored in Firestore under `users/{userId}/favorites/{trainId}`.
/// Connects Member 3's Train Details actions with Member 4's Profile screen.
class FavoritesService {
  FavoritesService._internal();
  static final FavoritesService _instance = FavoritesService._internal();
  static FavoritesService get instance => _instance;

  final FirebaseFirestore _firestore = FirebaseService.instance.firestore;

  /// Stream of user favorite trains from Firestore
  Stream<List<TrainModel>> streamFavorites(String userId) {
    if (userId.isEmpty) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return TrainModel.fromMap(doc.data(), id: doc.id);
      }).toList();
    });
  }

  /// Check if a train is in the user's favorites
  Future<bool> isFavorite(String userId, String trainId) async {
    if (userId.isEmpty || trainId.isEmpty) return false;
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .doc(trainId)
          .get();
      return doc.exists;
    } catch (e) {
      debugPrint('[FavoritesService] Error checking favorite: $e');
      return false;
    }
  }

  /// Toggles favorite status for a train. Returns true if now favorite, false if removed.
  Future<bool> toggleFavorite(String userId, TrainModel train) async {
    if (userId.isEmpty || train.id.isEmpty) return false;

    try {
      final docRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .doc(train.id);

      final doc = await docRef.get();
      if (doc.exists) {
        await docRef.delete();
        return false;
      } else {
        await docRef.set({
          ...train.toMap(),
          'savedAt': FieldValue.serverTimestamp(),
        });
        return true;
      }
    } catch (e) {
      debugPrint('[FavoritesService] Error toggling favorite: $e');
      return false;
    }
  }

  /// Removes a train from user favorites
  Future<void> removeFavorite(String userId, String trainId) async {
    if (userId.isEmpty || trainId.isEmpty) return;
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .doc(trainId)
          .delete();
    } catch (e) {
      debugPrint('[FavoritesService] Error removing favorite: $e');
    }
  }
}
