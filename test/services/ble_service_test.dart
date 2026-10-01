// ignore_for_file: deprecated_member_use_from_same_package
import 'package:flutter_test/flutter_test.dart';
import 'package:railway_tracker/core/services/ble_service.dart';

void main() {
  group('UnitQrPayload', () {
    test('serializes to and deserializes from Map correctly', () {
      const payload = UnitQrPayload(
        unitId: 'SLR-LOCO-1001',
        mac: 'AA:BB:CC:DD:EE:FF',
        hwType: 'ESP32_BLE_V1',
      );

      final map = payload.toMap();
      expect(map['unit_id'], 'SLR-LOCO-1001');
      expect(map['mac'], 'AA:BB:CC:DD:EE:FF');
      expect(map['hw_type'], 'ESP32_BLE_V1');

      final deserialized = UnitQrPayload.fromMap(map);
      expect(deserialized.unitId, 'SLR-LOCO-1001');
      expect(deserialized.mac, 'AA:BB:CC:DD:EE:FF');
      expect(deserialized.hwType, 'ESP32_BLE_V1');
    });

    test(
        'throws FormatException for missing, null, empty, or non-string fields',
        () {
      // Missing unit_id
      expect(
        () => UnitQrPayload.fromMap({
          'mac': 'AA:BB:CC:DD:EE:FF',
          'hw_type': 'ESP32_BLE_V1',
        }),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            contains('unit_id'),
          ),
        ),
      );

      // Null mac
      expect(
        () => UnitQrPayload.fromMap({
          'unit_id': 'SLR-LOCO-1001',
          'mac': null,
          'hw_type': 'ESP32_BLE_V1',
        }),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            contains('mac'),
          ),
        ),
      );

      // Empty hw_type after trim
      expect(
        () => UnitQrPayload.fromMap({
          'unit_id': 'SLR-LOCO-1001',
          'mac': 'AA:BB:CC:DD:EE:FF',
          'hw_type': '   ',
        }),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            contains('hw_type'),
          ),
        ),
      );

      // Non-string unit_id
      expect(
        () => UnitQrPayload.fromMap({
          'unit_id': 12345,
          'mac': 'AA:BB:CC:DD:EE:FF',
          'hw_type': 'ESP32_BLE_V1',
        }),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            contains('unit_id'),
          ),
        ),
      );
    });
  });

  group('MockBleService (latency: Duration.zero)', () {
    late MockBleService bleService;

    setUp(() {
      bleService = MockBleService(latency: Duration.zero);
    });

    tearDown(() {
      bleService.dispose();
    });

    test('connectToUnit returns true on success', () async {
      const payload = UnitQrPayload(
        unitId: 'SLR-LOCO-1001',
        mac: 'AA:BB:CC:DD:EE:FF',
        hwType: 'ESP32_BLE_V1',
      );

      final result = await bleService.connectToUnit(payload);
      expect(result, isTrue);
      expect(bleService.connectedUnit?.unitId, 'SLR-LOCO-1001');
      expect(bleService.connectedUnit?.mac, 'AA:BB:CC:DD:EE:FF');
    });

    test('writeTripConfig returns true and watchTripStatus emits "configured"',
        () async {
      final statusFuture = expectLater(
        bleService.watchTripStatus(),
        emits('configured'),
      );

      final tripConfig = {
        'train_no': '1001',
        'route_id': 'route_coastal_01',
        'direction': 'down',
        'driver_id': 'DRV-501',
      };

      final success = await bleService.writeTripConfig(tripConfig);
      expect(success, isTrue);
      expect(bleService.lastTripConfig, equals(tripConfig));

      await statusFuture;
    });

    test('readTripStatus returns "configured" after config write', () async {
      expect(await bleService.readTripStatus(), 'unconfigured');

      await bleService.writeTripConfig({
        'train_no': '1002',
        'route_id': 'route_mainline_02',
        'direction': 'up',
        'driver_id': 'DRV-502',
      });

      expect(await bleService.readTripStatus(), 'configured');
    });

    test('writeStationId returns true', () async {
      final connectSuccess =
          await bleService.connectToStationUnit('11:22:33:44:55:66');
      expect(connectSuccess, isTrue);
      expect(bleService.connectedStationMac, '11:22:33:44:55:66');

      final writeSuccess =
          await bleService.writeStationId('STATION-COLOMBO-FORT');
      expect(writeSuccess, isTrue);
      expect(bleService.configuredStationId, 'STATION-COLOMBO-FORT');
    });

    test('disconnect clears in-memory state', () async {
      const payload = UnitQrPayload(
        unitId: 'SLR-LOCO-1003',
        mac: 'CC:DD:EE:FF:00:11',
        hwType: 'ESP32_BLE_V1',
      );
      await bleService.connectToUnit(payload);
      await bleService.writeTripConfig({'train_no': '1003'});
      await bleService.connectToStationUnit('11:22:33:44:55:66');
      await bleService.writeStationId('STATION-GALLE');

      expect(bleService.connectedUnit, isNotNull);
      expect(bleService.connectedStationMac, isNotNull);
      expect(bleService.lastTripConfig, isNotNull);
      expect(await bleService.readTripStatus(), 'configured');
      expect(bleService.configuredStationId, 'STATION-GALLE');

      await bleService.disconnect();

      expect(bleService.connectedUnit, isNull);
      expect(bleService.connectedStationMac, isNull);
      expect(bleService.lastTripConfig, isNull);
      expect(await bleService.readTripStatus(), 'unconfigured');
      expect(bleService.configuredStationId, isNull);
    });

    test(
        'driver flow and station flow work independently (station write does not change trip status)',
        () async {
      expect(await bleService.readTripStatus(), 'unconfigured');

      final stationSuccess = await bleService.writeStationId('STATION-KANDY');
      expect(stationSuccess, isTrue);
      expect(bleService.configuredStationId, 'STATION-KANDY');

      // Writing station ID does not set or alter driver trip status
      expect(await bleService.readTripStatus(), 'unconfigured');
      expect(bleService.lastTripConfig, isNull);
    });

    test('legacy wrappers maintain backward compatibility', () async {
      final connectSuccess =
          await bleService.connectToDevice('SLR-LOCO-LEGACY');
      expect(connectSuccess, isTrue);
      expect(bleService.connectedDeviceId, 'SLR-LOCO-LEGACY');
      expect(bleService.isConnected, isTrue);

      final scanResults = await bleService.scanForDevice();
      expect(scanResults, isNotEmpty);
      expect(bleService.isMockMode, isTrue);
    });
  });

  group('MockBleService (simulateFailure: true)', () {
    late MockBleService failureService;

    setUp(() {
      failureService = MockBleService(
        latency: Duration.zero,
        simulateFailure: true,
      );
    });

    tearDown(() {
      failureService.dispose();
    });

    test(
        'simulateFailure: true -> connect/write return false, no uncaught exceptions',
        () async {
      const payload = UnitQrPayload(
        unitId: 'SLR-LOCO-FAIL',
        mac: '00:00:00:00:00:00',
        hwType: 'ESP32_BLE_V1',
      );

      final connectUnitSuccess = await failureService.connectToUnit(payload);
      expect(connectUnitSuccess, isFalse);
      expect(failureService.connectedUnit, isNull);

      final writeTripSuccess = await failureService.writeTripConfig({
        'train_no': '9999',
      });
      expect(writeTripSuccess, isFalse);
      expect(failureService.lastTripConfig, isNull);

      final status = await failureService.readTripStatus();
      expect(status, 'error');

      final connectStationSuccess =
          await failureService.connectToStationUnit('00:11:22:33:44:55');
      expect(connectStationSuccess, isFalse);
      expect(failureService.connectedStationMac, isNull);

      final writeStationSuccess =
          await failureService.writeStationId('STATION-FAIL');
      expect(writeStationSuccess, isFalse);
      expect(failureService.configuredStationId, isNull);

      // Disconnect does not crash on failure mode
      await expectLater(failureService.disconnect(), completes);
    });
  });
}
