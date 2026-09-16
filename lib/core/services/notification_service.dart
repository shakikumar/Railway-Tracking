import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_service.dart';

/// Notification Service wrapper around Firebase Cloud Messaging (Member 4).
/// Manages push notification permissions, FCM device tokens, and message streams
/// for delay alerts, platform changes, and trip notifications.
class NotificationService {
  NotificationService._internal();
  static final NotificationService _instance = NotificationService._internal();

  /// Singleton instance
  static NotificationService get instance => _instance;

  final FirebaseMessaging _messaging = FirebaseService.instance.messaging;

  /// Requests user permission for notifications (alerts, badges, sound).
  /// TODO (Member 4): Call during onboarding or when the user enables train delay alerts.
  Future<NotificationSettings> requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    return settings;
  }

  /// Retrieves the unique FCM registration token for this device.
  /// Used to register the device with the backend or Firestore user profile.
  Future<String?> getToken() async {
    try {
      return await _messaging.getToken();
    } catch (_) {
      return null;
    }
  }

  /// Registers a foreground message handler.
  /// TODO (Member 4): Display an in-app banner/snackbar or trigger local notifications.
  void registerOnMessageListener(void Function(RemoteMessage message) onMessage) {
    FirebaseMessaging.onMessage.listen(onMessage);
  }

  /// Subscribes to a specific train or station notification topic (e.g. `train_1001_delays`)
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
    } catch (_) {
      // TODO (Member 4): Add logging or error handling
    }
  }

  /// Unsubscribes from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
    } catch (_) {
      // TODO (Member 4): Add logging or error handling
    }
  }
}
