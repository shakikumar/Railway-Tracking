# QR Scan Screen (`lib/screens/driver/qr_scan/`)

## 1. Overview
The **QR Scan Screen** is the entry point for locomotive drivers (Member 5). Drivers scan an optical QR code label physically affixed inside the locomotive cab to automatically register and identify the onboard IoT telemetry hardware.

## 2. Expected QR Code Payload Specification
The scanner expects a JSON formatted string conforming to:
```json
{
  "unit_id": "LOC-1001-ALPHA",
  "mac": "AA:BB:CC:DD:EE:FF",
  "hw_type": "ESP32-S3-TRAIN-NODE"
}
```

### Validation Rules:
* Root payload must be valid JSON object format.
* All three keys (`unit_id`, `mac`, and `hw_type`) must exist, be strings, and be non-empty after trimming.
* If validation fails, an inline error banner is rendered on-screen with a **Rescan** trigger. The scanner does not crash or navigate away.

## 3. Data Flow
* **Data Read:** Optical QR code payload read via `mobile_scanner`.
* **Data Written:** None written to local storage or Firebase on this screen.
* **Navigation Forward:** The parsed map `{ "unit_id": ..., "mac": ..., "hw_type": ... }` is forwarded as route arguments to the **Trip Setup Screen**.

## 4. Known Limitations & Dependencies
* **Route Dependency:** The navigation uses `Navigator.pushNamed('/driver/trip-setup', arguments: ...)` with `// TODO: needs route from Member 1` pending final route consolidation in `app_routes.dart`.
* **Hardware Pairing:** This screen only extracts device identifiers from the visual code; the actual BLE connection and GATT characteristic handshake take place in `TripSetupScreen` using `BleService`.
