# BLE Service (`BleService`) — Stub Interface (Member 5)

## Purpose
`BleService` provides an abstract Bluetooth Low Energy (BLE) interface and simulated in-memory mock implementation (`MockBleService`) for the Railway Tracking application. It decouples downstream UI screens from physical BLE/GATT hardware, allowing driver and station master workflows to run and be tested without physical locomotives or hardware beacons.

## Stub Status (What is Mocked)
The service operates strictly in mock mode (`MockBleService`).
- **Device Discovery & Verification**: Mocked handshake verifying the locomotive beacon payload against simulated `UNIT_INFO_CHAR`.
- **Trip Configuration Write**: Simulates writing trip metadata to `TRIP_CONFIG_CHAR` with configurable artificial latency.
- **Trip Status Notification**: Returns `"configured"` status via Future reads and broadcast Stream updates (`watchTripStatus()`).
- **Station Master Configuration**: Simulates writing station identifiers to station beacon hardware.
- **Hardware Isolation**: No native Bluetooth calls, platform channels, or OS-level BLE daemons are invoked.

## Two Separate Flows
The interface enforces structural and conceptual separation between two independent hardware flows:

1. **Driver-Train Pairing Flow (`TrainPairingBle`)**
   - Triggered on every locomotive power-on and shift onboarding.
   - Accepts a typed QR payload (`UnitQrPayload`: `{unit_id, mac, hw_type}`).
   - Simulates reading and verifying the onboard locomotive unit (`UNIT_INFO_CHAR`).
   - Writes trip metadata (`train_no`, `route_id`, `direction`, `driver_id`) to `TRIP_CONFIG_CHAR`.
   - Subscribes to and reads live trip configuration status from `TRIP_STATUS_CHAR`.
2. **Station Master Setup Flow (`StationConfigBle`)**
   - One-time administrative setup performed at physical station terminals.
   - Connects to the station beacon via MAC address.
   - Writes station identity (`station_id`) using separate station GATT service UUIDs.
   - Operates independently from train pairing state; configuring a station does not modify or overwrite locomotive trip status.

Both flows are composed into the unified entry point `abstract class BleService implements TrainPairingBle, StationConfigBle`.

## RAM-Only Trip Data
Trip configuration and pairing states are maintained **strictly in RAM**:
- State variables (`_connectedUnit`, `_lastTripConfig`, `_tripStatus`, `_configuredStationId`) are reset when `disconnect()` is called or the app process terminates.
- **Zero Persistence**: No data is written to disk, `SharedPreferences`, Cloud Firestore, or Firebase Realtime Database by this service.

## Placeholder UUIDs
All GATT service and characteristic identifiers are defined as named constants in `TrainPairingUuids` and `StationConfigUuids`:
- Driver Pairing Service: `0000ffe0-0000-1000-8000-00805f9b34fb`
- Unit Info Char: `0000ffe1-0000-1000-8000-00805f9b34fb`
- Trip Config Char: `0000ffe2-0000-1000-8000-00805f9b34fb`
- Trip Status Char: `0000ffe3-0000-1000-8000-00805f9b34fb`
- Station Config Service: `0000fff0-0000-1000-8000-00805f9b34fb`
- Station ID Char: `0000fff1-0000-1000-8000-00805f9b34fb`

*Note: These UUIDs are temporary placeholders pending final hardware specification approval.*

## Failure Simulation for Testing
`MockBleService` accepts an optional `simulateFailure` boolean in its constructor:
```dart
final failingService = MockBleService(
  latency: Duration.zero,
  simulateFailure: true,
);
```
When `simulateFailure: true`:
- `connectToUnit`, `connectToStationUnit`, `writeTripConfig`, and `writeStationId` return `false`.
- `readTripStatus` returns `"error"`.
- Simulated error events are pushed to `watchTripStatus()`.
- No uncaught exceptions are thrown, allowing UI error banners, retry prompts, and timeout handlers to be reliably tested.

## What the Hardware Phase Will Replace
During the hardware integration phase:
1. A production class `HardwareBleService implements BleService` will be added using real GATT calls (`flutter_blue_plus`).
2. Placeholder UUIDs in `TrainPairingUuids` and `StationConfigUuids` will be replaced with final hardware specification UUIDs.
3. Raw byte packet encoding/decoding (UTF-8 / byte-struct serialization) will be introduced inside characteristic read/write routines.
4. Native Bluetooth adapter state monitoring, MTU negotiation, and physical connection timeout recovery will be activated.

Downstream screens and providers programmed against `BleService` will require zero refactoring when swapping in the hardware implementation.

## Known Limitations
- `flutter_blue_plus: ^2.3.12` is present in `pubspec.yaml` (added during repository infrastructure setup in PR #1), but is intentionally **not** imported or utilized by this stub service.
- `BleService.instance` is retained for legacy callers and backward compatibility. This will be replaced by direct dependency injection via `Provider<BleService>` in the application shell.
