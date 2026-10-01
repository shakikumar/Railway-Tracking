import 'package:flutter_test/flutter_test.dart';
import 'package:railway_tracker/models/train_model.dart';
import 'package:railway_tracker/providers/station_dashboard_provider.dart';

void main() {
  group('StationDashboardProvider Tests', () {
    late StationDashboardProvider provider;

    setUp(() {
      provider = StationDashboardProvider();
    });

    test('Initial state defaults to Colombo Fort and is not loading', () {
      expect(provider.stationId, 'colombo_fort');
      expect(provider.stationName, 'Colombo Fort');
      expect(provider.stationTrains, isEmpty);
      expect(provider.isLoading, false);
      expect(provider.errorMessage, isNull);
    });

    test('setMockCheckpointData filters strictly to assigned station only', () {
      final colomboTrain = const TrainModel(
        id: 'train_1',
        trainNumber: '1001',
        name: 'Rajarata Rejina',
        routeId: 'route_1',
        currentStation: 'Colombo Fort',
        scheduledDeparture: '06:00 AM',
        status: 'on-time',
      );

      final kandyTrain = const TrainModel(
        id: 'train_2',
        trainNumber: '1015',
        name: 'Udarata Menike',
        routeId: 'route_2',
        currentStation: 'Kandy',
        scheduledDeparture: '08:30 AM',
        status: 'on-time',
      );

      final galleTrain = const TrainModel(
        id: 'train_3',
        trainNumber: '8056',
        name: 'Galu Kumari',
        routeId: 'route_3',
        currentStation: 'Galle',
        scheduledDeparture: '07:15 AM',
        status: 'delayed',
        delayMinutes: 10,
      );

      // Current station is Colombo Fort
      provider.setMockCheckpointData([colomboTrain, kandyTrain, galleTrain]);

      expect(provider.stationTrains.length, 1);
      expect(provider.stationTrains.first.trainNumber, '1001');
      expect(provider.stationTrains.first.currentStation, 'Colombo Fort');
    });

    test('Station list contains predefined transit hubs', () {
      expect(StationDashboardProvider.availableStations, isNotEmpty);
      final stationIds = StationDashboardProvider.availableStations.map((s) => s['id']).toList();
      expect(stationIds, contains('colombo_fort'));
      expect(stationIds, contains('kandy'));
      expect(stationIds, contains('galle'));
    });
  });
}
