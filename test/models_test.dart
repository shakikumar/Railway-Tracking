import 'package:flutter_test/flutter_test.dart';
import 'package:railway_tracker/models/train_model.dart';
import 'package:railway_tracker/models/route_model.dart';

void main() {
  group('TrainModel Tests', () {
    test('Correctly serializes to Map and deserializes from Map', () {
      final train = TrainModel(
        id: 'train_1001',
        trainNumber: '1001',
        name: 'Galu Kumari',
        routeId: 'route_coastal_01',
        currentStation: 'Colombo Fort',
        nextStation: 'Mount Lavinia',
        scheduledDeparture: '06:30 AM',
        actualDeparture: '06:35 AM',
        delayMinutes: 5,
        status: 'delayed',
        latitude: 6.9344,
        longitude: 79.8428,
        speedKmH: 45.5,
        lastUpdated: '2026-09-14T06:35:00Z',
      );

      final map = train.toMap();
      final restored = TrainModel.fromMap(map);

      expect(restored.id, 'train_1001');
      expect(restored.trainNumber, '1001');
      expect(restored.name, 'Galu Kumari');
      expect(restored.isDelayed, isTrue);
      expect(restored.delayMinutes, 5);
      expect(restored.latitude, 6.9344);
      expect(restored.speedKmH, 45.5);
    });

    test('Correctly deserializes from Firebase Realtime Database map', () {
      final rtdbMap = {
        'id': 'train_1002',
        'trainNumber': 1002, // number type in dynamic map
        'name': 'Rajarata Rejini',
        'routeId': 'route_northern_01',
        'currentStation': 'Polgahawela',
        'scheduledDeparture': '05:45 AM',
        'delayMinutes': 0,
        'status': 'on-time',
        'latitude': 7.3328,
        'longitude': 80.3012,
      };

      final train = TrainModel.fromRealtimeDb(rtdbMap);
      expect(train.id, 'train_1002');
      expect(train.trainNumber, '1002');
      expect(train.isOnTime, isTrue);
      expect(train.isDelayed, isFalse);
      expect(train.latitude, 7.3328);
    });
  });

  group('RouteModel Tests', () {
    test('Validates station checkpoints and valid journey directions', () {
      final route = RouteModel(
        id: 'route_coastal',
        routeName: 'Coastal Line',
        originStation: 'Colombo Fort',
        destinationStation: 'Matara',
        stationCheckpoints: [
          'Colombo Fort',
          'Mount Lavinia',
          'Moratuwa',
          'Panadura',
          'Kalutara South',
          'Galle',
          'Matara',
        ],
      );

      expect(route.totalStops, 7);
      expect(route.containsStation('Galle'), isTrue);
      expect(route.containsStation('Kandy'), isFalse);
      expect(route.isValidJourney('Colombo Fort', 'Galle'), isTrue);
      expect(route.isValidJourney('Galle', 'Colombo Fort'), isFalse); // Reverse direction
    });
  });
}
