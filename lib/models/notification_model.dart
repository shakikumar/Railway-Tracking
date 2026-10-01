import 'package:cloud_firestore/cloud_firestore.dart';

/// Notification Type classification
enum NotificationType {
  delay,
  arrival,
  platform,
  general;

  static NotificationType fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'delay':
        return NotificationType.delay;
      case 'arrival':
        return NotificationType.arrival;
      case 'platform':
        return NotificationType.platform;
      default:
        return NotificationType.general;
    }
  }

  String toValue() => name;
}

/// Model representing a user notification (delay alerts, arrival alerts, announcements).
/// Owned by Member 4.
class NotificationModel {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final DateTime timestamp;
  final String? trainId;
  final String? trainNumber;
  final String? stationName;
  final int? delayMinutes;
  final bool isRead;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.timestamp,
    this.trainId,
    this.trainNumber,
    this.stationName,
    this.delayMinutes,
    this.isRead = false,
  });

  /// Factory constructor to deserialize from Firestore document or Map
  factory NotificationModel.fromMap(Map<String, dynamic> map, {String? id}) {
    DateTime parsedTime;
    final rawTimestamp = map['timestamp'];
    if (rawTimestamp is Timestamp) {
      parsedTime = rawTimestamp.toDate();
    } else if (rawTimestamp is String) {
      parsedTime = DateTime.tryParse(rawTimestamp) ?? DateTime.now();
    } else if (rawTimestamp is int) {
      parsedTime = DateTime.fromMillisecondsSinceEpoch(rawTimestamp);
    } else {
      parsedTime = DateTime.now();
    }

    return NotificationModel(
      id: id ?? map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? 'Notification',
      body: map['body']?.toString() ?? '',
      type: NotificationType.fromString(map['type']?.toString()),
      timestamp: parsedTime,
      trainId: map['trainId']?.toString(),
      trainNumber: map['trainNumber']?.toString(),
      stationName: map['stationName']?.toString(),
      delayMinutes: map['delayMinutes'] is int
          ? map['delayMinutes'] as int
          : int.tryParse(map['delayMinutes']?.toString() ?? ''),
      isRead: map['isRead'] == true,
    );
  }

  /// Convert to Map for Firestore writes
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'type': type.toValue(),
      'timestamp': Timestamp.fromDate(timestamp),
      if (trainId != null) 'trainId': trainId,
      if (trainNumber != null) 'trainNumber': trainNumber,
      if (stationName != null) 'stationName': stationName,
      if (delayMinutes != null) 'delayMinutes': delayMinutes,
      'isRead': isRead,
    };
  }

  NotificationModel copyWith({
    String? id,
    String? title,
    String? body,
    NotificationType? type,
    DateTime? timestamp,
    String? trainId,
    String? trainNumber,
    String? stationName,
    int? delayMinutes,
    bool? isRead,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      trainId: trainId ?? this.trainId,
      trainNumber: trainNumber ?? this.trainNumber,
      stationName: stationName ?? this.stationName,
      delayMinutes: delayMinutes ?? this.delayMinutes,
      isRead: isRead ?? this.isRead,
    );
  }
}
