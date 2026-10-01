import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:railway_tracker/screens/driver/qr_scan/qr_payload_validator.dart';
import 'package:railway_tracker/screens/driver/qr_scan/qr_scan_screen.dart';

void main() {
  group('Driver QR Scan Payload Validation Tests (Member 5)', () {
    const validJson = '''
    {
      "unit_id": "LOC-1001-ALPHA",
      "mac": "AA:BB:CC:DD:EE:FF",
      "hw_type": "ESP32-S3-TRAIN-NODE"
    }
    ''';

    test('Scenario 1: Valid payload with all 3 fields parses successfully', () {
      final payload = parseAndValidateQrPayload(validJson);

      expect(payload.unitId, equals('LOC-1001-ALPHA'));
      expect(payload.mac, equals('AA:BB:CC:DD:EE:FF'));
      expect(payload.hwType, equals('ESP32-S3-TRAIN-NODE'));

      final map = payload.toMap();
      expect(map['unit_id'], equals('LOC-1001-ALPHA'));
      expect(map['mac'], equals('AA:BB:CC:DD:EE:FF'));
      expect(map['hw_type'], equals('ESP32-S3-TRAIN-NODE'));
    });

    test('Scenario 2: Payload missing one or more fields throws FormatException', () {
      // Missing hw_type
      const missingHw = '{"unit_id": "LOC-1001", "mac": "AA:BB:CC:DD:EE:FF"}';
      expect(
        () => parseAndValidateQrPayload(missingHw),
        throwsA(isA<FormatException>().having(
          (e) => e.message,
          'message',
          contains('Incomplete QR'),
        )),
      );

      // Empty string unit_id
      const emptyUnit = '{"unit_id": "  ", "mac": "AA:BB:CC:DD:EE:FF", "hw_type": "ESP32"}';
      expect(
        () => parseAndValidateQrPayload(emptyUnit),
        throwsA(isA<FormatException>().having(
          (e) => e.message,
          'message',
          contains('Incomplete QR'),
        )),
      );

      // Empty string mac
      const emptyMac = '{"unit_id": "LOC-1001", "mac": "", "hw_type": "ESP32"}';
      expect(
        () => parseAndValidateQrPayload(emptyMac),
        throwsA(isA<FormatException>().having(
          (e) => e.message,
          'message',
          contains('Incomplete QR'),
        )),
      );
    });

    test('Scenario 3: Non-JSON or malformed payload throws FormatException', () {
      // Plain text string
      const nonJson = 'https://railway.example.com/locomotive/1001';
      expect(
        () => parseAndValidateQrPayload(nonJson),
        throwsA(isA<FormatException>().having(
          (e) => e.message,
          'message',
          contains('Invalid QR Code'),
        )),
      );

      // JSON array instead of JSON object
      const jsonArray = '["LOC-1001", "AA:BB:CC", "ESP32"]';
      expect(
        () => parseAndValidateQrPayload(jsonArray),
        throwsA(isA<FormatException>().having(
          (e) => e.message,
          'message',
          contains('Malformed QR'),
        )),
      );
    });

    testWidgets('Scenario 4: Screen renders without error on Android and iOS platforms', (tester) async {
      for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(platform: platform),
            home: const QrScanScreen(),
          ),
        );

        // Confirm title renders
        expect(find.text('QR Scan'), findsOneWidget);

        // Confirm instructions render
        expect(
          find.text('Align the locomotive QR code within the frame to start your trip.'),
          findsOneWidget,
        );

        // Confirm scanner action buttons (flash, switch camera) exist
        expect(find.byIcon(Icons.flash_on), findsOneWidget);
        expect(find.byIcon(Icons.flip_camera_android), findsOneWidget);
      }
    });
  });
}
