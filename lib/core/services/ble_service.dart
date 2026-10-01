import 'dart:async';

/// Bluetooth Low Energy (BLE) Service interface and GATT Specification (Member 5).
/// Used by the Driver Flow to pair with the locomotive's onboard hardware beacon
/// and write trip metadata (train number, route, direction, driver ID).
class BleService {
  BleService._internal();
  static final BleService _instance = BleService._internal();

  /// Singleton instance
  static BleService get instance => _instance;

  // ---------------------------------------------------------------------------
  // TRAIN_PAIRING_SERVICE GATT Specification UUIDs
  // ---------------------------------------------------------------------------
  static const String trainPairingServiceUuid =
      '0000ffe0-0000-1000-8000-00805f9b34fb';
  static const String tripConfigCharacteristicUuid =
      '0000ffe1-0000-1000-8000-00805f9b34fb';
  static const String beaconTelemetryCharacteristicUuid =
      '0000ffe2-0000-1000-8000-00805f9b34fb';

  /// Toggle for simulated BLE mode so UI and state testing does not require
  /// physical locomotive BLE hardware. Default is [true].
  bool isMockMode = true;

  String? _connectedDeviceId;
  bool get isConnected => _connectedDeviceId != null;
  String? get connectedDeviceId => _connectedDeviceId;

  /// Scans for nearby locomotive BLE pairing beacons matching [trainPairingServiceUuid].
  /// Returns a list of discovered device identifiers/names.
  ///
  /// In [isMockMode], returns a simulated hardware beacon list after a short delay.
  /// TODO (Member 5): Implement flutter_blue_plus scanning logic:
  /// `FlutterBluePlus.startScan(withServices: [Guid(trainPairingServiceUuid)])`
  Future<List<String>> scanForDevice({
    Duration timeout = const Duration(seconds: 4),
  }) async {
    if (isMockMode) {
      await Future.delayed(const Duration(milliseconds: 600));
      return const [
        'SLR-BEACON-1001-COASTAL',
        'SLR-BEACON-1002-MAINLINE',
        'SLR-CAB-SIMULATOR',
      ];
    }

    // TODO (Member 5): Production flutter_blue_plus scan implementation
    return [];
  }

  /// Connects to a specific BLE device by [deviceId].
  ///
  /// In [isMockMode], simulates a successful connection handshake.
  /// TODO (Member 5): Implement `BluetoothDevice.connect()` and MTU negotiation.
  Future<bool> connectToDevice(String deviceId) async {
    if (isMockMode) {
      await Future.delayed(const Duration(milliseconds: 400));
      _connectedDeviceId = deviceId;
      return true;
    }

    // TODO (Member 5): Production BLE connection
    return false;
  }

  /// Writes trip configuration to the onboard locomotive characteristic.
  /// [config] format: `{ 'train_no': '...', 'route_id': '...', 'direction': '...', 'driver_id': '...' }`
  ///
  /// In [isMockMode], returns `true` (success) immediately.
  /// TODO (Member 5): Encode payload to UTF-8 bytes and call
  /// `characteristic.write(bytes, withoutResponse: false)`.
  Future<bool> writeTripConfig(Map<String, dynamic> config) async {
    if (isMockMode) {
      await Future.delayed(const Duration(milliseconds: 300));
      return true; // Mocked success so UI flow proceeds seamlessly
    }

    // TODO (Member 5): Production characteristic write
    return false;
  }

  /// Disconnects from the current BLE device
  Future<void> disconnect() async {
    _connectedDeviceId = null;
  }
}
