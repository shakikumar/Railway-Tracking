import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import '../../models/notification_model.dart';
import 'firebase_service.dart';

/// Notification Service wrapper around Firebase Cloud Messaging (Member 4).
/// Manages push notification permissions, FCM device tokens, topic subscriptions,
/// and message streams for delay alerts, arrival alerts, and user notifications.
class NotificationService {
  NotificationService._internal();
  static final NotificationService _instance = NotificationService._internal();

  /// Singleton instance
  static NotificationService get instance => _instance;

  final FirebaseMessaging _messaging = FirebaseService.instance.messaging;
  final FirebaseFirestore _firestore = FirebaseService.instance.firestore;

  final StreamController<NotificationModel> _foregroundNotificationController =
      StreamController<NotificationModel>.broadcast();

  /// Broadcast stream of notifications received while the app is in the foreground
  Stream<NotificationModel> get onForegroundNotification =>
      _foregroundNotificationController.stream;

  bool _isInitialized = false;

  /// Initializes FCM configurations, sets foreground presentation,
  /// and listens for incoming messages and token refreshes.
  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;

    try {
      // Set foreground presentation options for iOS / supported platforms
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // Listen to incoming messages in foreground
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        final notification = _parseRemoteMessage(message);
        _foregroundNotificationController.add(notification);
      });

      // Listen to token refresh events
      _messaging.onTokenRefresh.listen((newToken) {
        final currentUser = FirebaseService.instance.auth.currentUser;
        if (currentUser != null) {
          registerUserToken(currentUser.uid, tokenOverride: newToken);
        }
      });
    } catch (e) {
      debugPrint('[NotificationService] Initialization note: $e');
    }
  }

  /// Requests user permission for notifications (alerts, badges, sound).
  Future<NotificationSettings> requestPermission() async {
    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      return settings;
    } catch (e) {
      debugPrint('[NotificationService] Error requesting permission: $e');
      rethrow;
    }
  }

  /// Retrieves the unique FCM registration token for this device.
  Future<String?> getToken() async {
    try {
      return await _messaging.getToken();
    } catch (e) {
      debugPrint('[NotificationService] Error fetching FCM token: $e');
      return null;
    }
  }

  /// Registers the device's FCM token in Firestore under `users/{userId}`.
  /// Called upon user login as part of Member 1 / Member 4 integration.
  Future<void> registerUserToken(String userId, {String? tokenOverride}) async {
    if (userId.isEmpty) return;

    try {
      final token = tokenOverride ?? await getToken();
      if (token == null || token.isEmpty) return;

      final userDocRef = _firestore.collection('users').doc(userId);
      await userDocRef.set({
        'fcmToken': token,
        'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
        'platform': defaultTargetPlatform.name,
      }, SetOptions(merge: true));

      debugPrint('[NotificationService] Registered FCM token for user: $userId');
    } catch (e) {
      debugPrint('[NotificationService] Error registering user token: $e');
    }
  }

  /// Clears the FCM token from the user profile upon logout.
  Future<void> clearUserToken(String userId) async {
    if (userId.isEmpty) return;

    try {
      final userDocRef = _firestore.collection('users').doc(userId);
      await userDocRef.set({
        'fcmToken': null,
        'fcmTokenClearedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      debugPrint('[NotificationService] Cleared FCM token for user: $userId');
    } catch (e) {
      debugPrint('[NotificationService] Error clearing user token: $e');
    }
  }

  /// Subscribes to delay alerts for a specific train service
  Future<void> subscribeToTrainDelays(String trainId) async {
    if (trainId.isEmpty) return;
    try {
      final topic = 'train_${trainId.replaceAll(RegExp(r'[^a-zA-Z0-9-_.~%]'), '_')}_delays';
      await _messaging.subscribeToTopic(topic);
      debugPrint('[NotificationService] Subscribed to topic: $topic');
    } catch (e) {
      debugPrint('[NotificationService] Error subscribing to train delays: $e');
    }
  }

  /// Unsubscribes from delay alerts for a specific train service
  Future<void> unsubscribeFromTrainDelays(String trainId) async {
    if (trainId.isEmpty) return;
    try {
      final topic = 'train_${trainId.replaceAll(RegExp(r'[^a-zA-Z0-9-_.~%]'), '_')}_delays';
      await _messaging.unsubscribeFromTopic(topic);
      debugPrint('[NotificationService] Unsubscribed from topic: $topic');
    } catch (e) {
      debugPrint('[NotificationService] Error unsubscribing from train delays: $e');
    }
  }

  /// Subscribes to arrival alerts or station events for a specific station
  Future<void> subscribeToStationAlerts(String stationId) async {
    if (stationId.isEmpty) return;
    try {
      final topic = 'station_${stationId.replaceAll(RegExp(r'[^a-zA-Z0-9-_.~%]'), '_')}';
      await _messaging.subscribeToTopic(topic);
      debugPrint('[NotificationService] Subscribed to station topic: $topic');
    } catch (e) {
      debugPrint('[NotificationService] Error subscribing to station alerts: $e');
    }
  }

  /// Unsubscribes from station alerts
  Future<void> unsubscribeFromStationAlerts(String stationId) async {
    if (stationId.isEmpty) return;
    try {
      final topic = 'station_${stationId.replaceAll(RegExp(r'[^a-zA-Z0-9-_.~%]'), '_')}';
      await _messaging.unsubscribeFromTopic(topic);
      debugPrint('[NotificationService] Unsubscribed from station topic: $topic');
    } catch (e) {
      debugPrint('[NotificationService] Error unsubscribing from station alerts: $e');
    }
  }

  /// Subscribes to a generic notification topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
    } catch (e) {
      debugPrint('[NotificationService] Error subscribing to topic $topic: $e');
    }
  }

  /// Unsubscribes from a generic notification topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
    } catch (e) {
      debugPrint('[NotificationService] Error unsubscribing from topic $topic: $e');
    }
  }

  /// Streams notifications history for a logged-in user from Firestore `users/{userId}/notifications`
  Stream<List<NotificationModel>> streamUserNotifications(String userId) {
    if (userId.isEmpty) {
      return Stream.value([]);
    }

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => NotificationModel.fromMap(doc.data(), id: doc.id))
          .toList();
    });
  }

  /// Marks a specific notification as read in Firestore
  Future<void> markAsRead(String userId, String notificationId) async {
    if (userId.isEmpty || notificationId.isEmpty) return;
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});
    } catch (e) {
      debugPrint('[NotificationService] Error marking notification as read: $e');
    }
  }

  /// Marks all notifications for a user as read
  Future<void> markAllAsRead(String userId) async {
    if (userId.isEmpty) return;
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .where('isRead', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (final doc in querySnapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
    } catch (e) {
      debugPrint('[NotificationService] Error marking all as read: $e');
    }
  }

  /// Adds a notification record to the user's notification history in Firestore
  Future<void> addNotificationForUser(
    String userId,
    NotificationModel notification,
  ) async {
    if (userId.isEmpty) return;
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .doc(notification.id.isNotEmpty ? notification.id : null)
          .set(notification.toMap(), SetOptions(merge: true));
    } catch (e) {
      debugPrint('[NotificationService] Error adding notification: $e');
    }
  }

  /// Helper to convert a Firebase [RemoteMessage] to [NotificationModel]
  NotificationModel _parseRemoteMessage(RemoteMessage message) {
    final data = message.data;
    final notification = message.notification;

    return NotificationModel(
      id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: notification?.title ?? data['title']?.toString() ?? 'Train Alert',
      body: notification?.body ?? data['body']?.toString() ?? '',
      type: NotificationType.fromString(data['type']?.toString()),
      timestamp: message.sentTime ?? DateTime.now(),
      trainId: data['trainId']?.toString(),
      trainNumber: data['trainNumber']?.toString(),
      stationName: data['stationName']?.toString(),
      delayMinutes: data['delayMinutes'] != null
          ? int.tryParse(data['delayMinutes'].toString())
          : null,
      isRead: false,
    );
  }

  void dispose() {
    _foregroundNotificationController.close();
  }
}
