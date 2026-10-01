import 'package:flutter_test/flutter_test.dart';
import 'package:railway_tracker/models/notification_model.dart';

void main() {
  group('NotificationModel Tests', () {
    test('NotificationModel serializes to Map and deserializes correctly', () {
      final now = DateTime(2026, 10, 1, 10, 30);
      final model = NotificationModel(
        id: 'notif_123',
        title: 'Train Delayed',
        body: 'Express 1001 running 25 min late',
        type: NotificationType.delay,
        timestamp: now,
        trainId: 'train_1001',
        trainNumber: '1001',
        stationName: 'Colombo Fort',
        delayMinutes: 25,
        isRead: false,
      );

      final map = model.toMap();
      expect(map['id'], 'notif_123');
      expect(map['title'], 'Train Delayed');
      expect(map['type'], 'delay');
      expect(map['trainNumber'], '1001');
      expect(map['delayMinutes'], 25);
      expect(map['isRead'], false);

      final deserialized = NotificationModel.fromMap({
        'id': 'notif_123',
        'title': 'Train Delayed',
        'body': 'Express 1001 running 25 min late',
        'type': 'delay',
        'timestamp': now.toIso8601String(),
        'trainId': 'train_1001',
        'trainNumber': '1001',
        'stationName': 'Colombo Fort',
        'delayMinutes': 25,
        'isRead': false,
      });

      expect(deserialized.id, model.id);
      expect(deserialized.title, model.title);
      expect(deserialized.type, NotificationType.delay);
      expect(deserialized.delayMinutes, 25);
      expect(deserialized.isRead, false);
    });

    test('NotificationType.fromString handles unknown types gracefully', () {
      expect(NotificationType.fromString('delay'), NotificationType.delay);
      expect(NotificationType.fromString('arrival'), NotificationType.arrival);
      expect(NotificationType.fromString('platform'), NotificationType.platform);
      expect(NotificationType.fromString('unknown_type'), NotificationType.general);
      expect(NotificationType.fromString(null), NotificationType.general);
    });

    test('copyWith updates fields correctly', () {
      final model = NotificationModel(
        id: '1',
        title: 'Title',
        body: 'Body',
        type: NotificationType.general,
        timestamp: DateTime.now(),
        isRead: false,
      );

      final updated = model.copyWith(isRead: true, title: 'Updated Title');
      expect(updated.isRead, true);
      expect(updated.title, 'Updated Title');
      expect(updated.body, 'Body');
    });
  });
}
