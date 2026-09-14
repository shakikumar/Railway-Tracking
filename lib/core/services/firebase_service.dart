import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

/// Centralized singleton service providing access to Firebase instances.
/// Used across all team member features (Auth, Firestore, Realtime DB).
class FirebaseService {
  FirebaseService._internal();
  static final FirebaseService _instance = FirebaseService._internal();

  /// Singleton accessor
  static FirebaseService get instance => _instance;

  /// Authentication instance
  FirebaseAuth get auth => FirebaseAuth.instance;

  /// Cloud Firestore instance (schedules, persistent routes, user profiles)
  FirebaseFirestore get firestore => FirebaseFirestore.instance;

  /// Firebase Realtime Database instance (live telemetry, real-time GPS coordinates)
  FirebaseDatabase get realtimeDb => FirebaseDatabase.instance;

  // ---------------------------------------------------------------------------
  // Commonly Used Firestore Collections
  // ---------------------------------------------------------------------------

  /// Trains collection reference: `trains/{trainId}`
  CollectionReference<Map<String, dynamic>> get trainsCollection =>
      firestore.collection('trains');

  /// Routes collection reference: `routes/{routeId}`
  CollectionReference<Map<String, dynamic>> get routesCollection =>
      firestore.collection('routes');

  /// Users / Profiles collection reference: `users/{userId}`
  CollectionReference<Map<String, dynamic>> get usersCollection =>
      firestore.collection('users');

  /// Driver sessions collection reference: `driver_sessions/{sessionId}`
  CollectionReference<Map<String, dynamic>> get driverSessionsCollection =>
      firestore.collection('driver_sessions');

  // ---------------------------------------------------------------------------
  // Commonly Used Realtime Database References
  // ---------------------------------------------------------------------------

  /// Live train telemetry root: `live_tracking/{trainId}`
  DatabaseReference get liveTrackingRef => realtimeDb.ref('live_tracking');

  /// Specific train live tracking node
  DatabaseReference trainLiveRef(String trainId) =>
      realtimeDb.ref('live_tracking/$trainId');
}
