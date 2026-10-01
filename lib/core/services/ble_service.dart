import 'dart:async';

/// Typed QR code payload containing locomotive beacon hardware parameters (Member 5).
///
/// Encapsulates the visual code fields scanned by the driver during train onboarding.
class UnitQrPayload {
  /// Unique locomotive/beacon unit identifier (e.g. "SLR-LOCO-1001").
  final String unitId;

  /// Hardware MAC address of the BLE peripheral beacon.
  final String mac;

  /// Hardware revision or beacon category (e.g. "ESP32_BLE_V1").
  final String hwType;

  /// Creates a [UnitQrPayload] data model.
  const UnitQrPayload({
    required this.unitId,
    required this.mac,
    required this.hwType,
  });

  /// Deserializes a [UnitQrPayload] from a JSON-compatible map.
  factory UnitQrPayload.fromMap(Map<String, dynamic> map) {
    return UnitQrPayload(
      unitId: map['unit_id'] as String? ?? '',
      mac: map['mac'] as String? ?? '',
      hwType: map['hw_type'] as String? ?? '',
    );
  }

  /// Serializes this payload to a JSON-compatible map.
  Map<String, dynamic> toMap() {
    return {
      'unit_id': unitId,
      'mac': mac,
      'hw_type': hwType,
    };
  }
}

/// GATT UUID definitions for the Driver-Train Pairing flow.
///
/// TODO: Placeholder UUIDs — replace with hardware GATT spec in hardware phase.
abstract class TrainPairingUuids {
  TrainPairingUuids._();

  /// Primary GATT service UUID for locomotive onboarding & driver pairing.
  static const String serviceUuid = '0000ffe0-0000-1000-8000-00805f9b34fb';

  /// Characteristic for reading unit information to verify hardware identity.
  static const String unitInfoCharUuid = '0000ffe1-0000-1000-8000-00805f9b34fb';

  /// Characteristic for writing trip parameters (train number, route, direction).
  static const String tripConfigCharUuid =
      '0000ffe2-0000-1000-8000-00805f9b34fb';

  /// Characteristic for subscribing to live trip lifecycle status updates.
  static const String tripStatusCharUuid =
      '0000ffe3-0000-1000-8000-00805f9b34fb';
}

/// GATT UUID definitions for Station Master hardware configuration.
///
/// TODO: Placeholder UUIDs — replace with hardware GATT spec in hardware phase.
abstract class StationConfigUuids {
  StationConfigUuids._();

  /// Primary GATT service UUID for station master terminal configuration.
  static const String serviceUuid = '0000fff0-0000-1000-8000-00805f9b34fb';

  /// Characteristic for setting the station identifier during one-time setup.
  static const String stationIdCharUuid =
      '0000fff1-0000-1000-8000-00805f9b34fb';
}

/// BLE contract for the Driver-Train pairing lifecycle (every locomotive power-on).
abstract class TrainPairingBle {
  /// Connects to a locomotive BLE unit using scanned [payload], mocking verification
  /// of the hardware identity via UNIT_INFO_CHAR.
  Future<bool> connectToUnit(UnitQrPayload payload);

  /// Writes trip metadata to the onboard locomotive characteristic.
  ///
  /// Persists in RAM only on the stub.
  Future<bool> writeTripConfig(Map<String, dynamic> config);

  /// Reads the current trip status from TRIP_STATUS_CHAR.
  Future<String> readTripStatus();

  /// Subscribes to live trip configuration status notifications.
  Stream<String> watchTripStatus();

  /// Disconnects from the current locomotive pairing unit.
  Future<void> disconnect();
}

/// BLE contract for Station Master terminal configuration (one-time setup).
abstract class StationConfigBle {
  /// Connects to the station master beacon unit by [mac] address.
  Future<bool> connectToStationUnit(String mac);

  /// Writes the station identifier to the station unit characteristic.
  Future<bool> writeStationId(String stationId);

  /// Disconnects from the station beacon unit.
  Future<void> disconnect();
}

/// Unified BLE service interface combining driver and station flows while
/// maintaining structural separation.
abstract class BleService implements TrainPairingBle, StationConfigBle {
  /// Default shared instance for backward compatibility with existing callers.
  static BleService instance = MockBleService();
}

/// Simulated in-memory implementation of [BleService] for UI and testing.
///
/// Does not call native Bluetooth hardware or platform channels. All state is
/// stored strictly in RAM.
class MockBleService implements BleService {
  /// Simulated latency for asynchronous BLE operations.
  final Duration latency;

  /// Whether simulated operations should fail to verify screen error paths.
  final bool simulateFailure;

  UnitQrPayload? _connectedUnit;
  String? _connectedStationMac;
  Map<String, dynamic>? _lastTripConfig;
  String _tripStatus = 'unconfigured';
  String? _configuredStationId;

  final StreamController<String> _tripStatusController =
      StreamController<String>.broadcast();

  /// Creates a [MockBleService] with optional [latency] and [simulateFailure].
  MockBleService({
    this.latency = const Duration(milliseconds: 500),
    this.simulateFailure = false,
  });

  /// Currently connected locomotive unit payload, if any.
  UnitQrPayload? get connectedUnit => _connectedUnit;

  /// Currently connected station beacon MAC, if any.
  String? get connectedStationMac => _connectedStationMac;

  /// Last trip configuration written to RAM.
  Map<String, dynamic>? get lastTripConfig => _lastTripConfig;

  /// Last station identifier configured.
  String? get configuredStationId => _configuredStationId;

  // ---------------------------------------------------------------------------
  // TrainPairingBle Implementation (Driver Flow)
  // ---------------------------------------------------------------------------

  @override
  Future<bool> connectToUnit(UnitQrPayload payload) async {
    if (latency > Duration.zero) {
      await Future.delayed(latency);
    }
    if (simulateFailure) {
      return false;
    }
    _connectedUnit = payload;
    return true;
  }

  @override
  Future<bool> writeTripConfig(Map<String, dynamic> config) async {
    if (latency > Duration.zero) {
      await Future.delayed(latency);
    }
    if (simulateFailure) {
      if (!_tripStatusController.isClosed) {
        _tripStatusController.addError('Simulated writeTripConfig failure');
      }
      return false;
    }
    _lastTripConfig = Map<String, dynamic>.from(config);
    _tripStatus = 'configured';
    if (!_tripStatusController.isClosed) {
      _tripStatusController.add('configured');
    }
    return true;
  }

  @override
  Future<String> readTripStatus() async {
    if (latency > Duration.zero) {
      await Future.delayed(latency);
    }
    if (simulateFailure) {
      return 'error';
    }
    return _tripStatus;
  }

  @override
  Stream<String> watchTripStatus() {
    return _tripStatusController.stream;
  }

  // ---------------------------------------------------------------------------
  // StationConfigBle Implementation (Station Master Flow)
  // ---------------------------------------------------------------------------

  @override
  Future<bool> connectToStationUnit(String mac) async {
    if (latency > Duration.zero) {
      await Future.delayed(latency);
    }
    if (simulateFailure) {
      return false;
    }
    _connectedStationMac = mac;
    return true;
  }

  @override
  Future<bool> writeStationId(String stationId) async {
    if (latency > Duration.zero) {
      await Future.delayed(latency);
    }
    if (simulateFailure) {
      return false;
    }
    _configuredStationId = stationId;
    return true;
  }

  // ---------------------------------------------------------------------------
  // Disconnect & Lifecycle
  // ---------------------------------------------------------------------------

  @override
  Future<void> disconnect() async {
    if (latency > Duration.zero) {
      await Future.delayed(latency);
    }
    _connectedUnit = null;
    _connectedStationMac = null;
    _lastTripConfig = null;
    _tripStatus = 'unconfigured';
    _configuredStationId = null;
  }

  /// Closes the broadcast stream controller.
  void dispose() {
    _tripStatusController.close();
  }

  // ---------------------------------------------------------------------------
  // Backward-compatibility wrappers for legacy callers
  // ---------------------------------------------------------------------------

  /// Legacy device connection stub.
  /// TODO: remove once screens migrate to new API
  @Deprecated('Use connectToUnit instead')
  Future<bool> connectToDevice(String deviceId) async {
    return connectToUnit(UnitQrPayload(unitId: deviceId, mac: '', hwType: ''));
  }

  /// Legacy beacon scan stub.
  /// TODO: remove once screens migrate to new API
  @Deprecated('Legacy scan method - driver flow uses QR scan')
  Future<List<String>> scanForDevice({
    Duration timeout = const Duration(seconds: 4),
  }) async {
    if (latency > Duration.zero) {
      await Future.delayed(latency);
    }
    if (simulateFailure) {
      return const [];
    }
    return const [
      'SLR-BEACON-1001-COASTAL',
      'SLR-BEACON-1002-MAINLINE',
      'SLR-CAB-SIMULATOR',
    ];
  }

  /// Legacy mock mode toggle.
  /// TODO: remove once screens migrate to new API
  @Deprecated('MockBleService is always mock mode')
  bool isMockMode = true;

  /// Legacy connected device ID accessor.
  /// TODO: remove once screens migrate to new API
  @Deprecated('Use connectedUnit or connectedStationMac instead')
  String? get connectedDeviceId => _connectedUnit?.unitId;

  /// Legacy connection status accessor.
  /// TODO: remove once screens migrate to new API
  @Deprecated('Use connectedUnit != null instead')
  bool get isConnected => _connectedUnit != null;
}
