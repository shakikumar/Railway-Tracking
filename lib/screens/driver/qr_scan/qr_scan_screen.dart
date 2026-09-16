import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'qr_payload_validator.dart';

/// Screen for Driver QR Code scanning (Member 5).
/// Scans IoT pairing tags affixed to locomotive cabs to extract unit configuration
/// and passes the validated payload to the Trip Setup screen.
class QrScanScreen extends StatefulWidget {
  const QrScanScreen({super.key});

  @override
  State<QrScanScreen> createState() => _QrScanScreenState();
}

class _QrScanScreenState extends State<QrScanScreen> {
  late final MobileScannerController _scannerController;
  bool _isScanning = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  /// Handles incoming barcode detections from the camera stream
  void _handleBarcodeDetected(BarcodeCapture capture) {
    if (!_isScanning) return;
    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final String? rawValue = barcodes.first.rawValue;
    if (rawValue == null || rawValue.trim().isEmpty) return;

    setState(() {
      _isScanning = false;
      _errorMessage = null;
    });

    _processPayload(rawValue.trim());
  }

  /// Parses and validates the QR string using standalone validator and updates UI or navigates
  void _processPayload(String rawJson) {
    try {
      final payload = parseAndValidateQrPayload(rawJson);
      _navigateToTripSetup(
        unitId: payload.unitId,
        mac: payload.mac,
        hwType: payload.hwType,
      );
    } on FormatException catch (e) {
      _showScanError(e.message);
    } catch (e) {
      _showScanError('Invalid QR Code: Content is not valid JSON ($e).');
    }
  }

  /// Navigates to the Trip Setup screen with the parsed pairing parameters
  void _navigateToTripSetup({
    required String unitId,
    required String mac,
    required String hwType,
  }) {
    final payload = {
      'unit_id': unitId,
      'mac': mac,
      'hw_type': hwType,
    };

    // TODO: needs route from Member 1
    // Navigating via named route with arguments payload.
    // Member 1 owns canonical GoRouter paths in lib/core/routes/app_routes.dart.
    Navigator.of(context).pushNamed(
      '/driver/trip-setup', // TODO: needs route from Member 1
      arguments: payload,
    );
  }

  /// Displays an inline error message and preserves the current screen state
  void _showScanError(String message) {
    setState(() {
      _errorMessage = message;
      _isScanning = false;
    });
  }

  /// Resets error state and resumes camera barcode detection
  void _rescan() {
    setState(() {
      _errorMessage = null;
      _isScanning = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Scan'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            tooltip: 'Toggle Flashlight',
            onPressed: () => _scannerController.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.flip_camera_android),
            tooltip: 'Switch Camera',
            onPressed: () => _scannerController.switchCamera(),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Align the locomotive QR code within the frame to start your trip.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ),
            if (_errorMessage != null)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: Colors.red.shade300),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red.shade900, fontSize: 13),
                      ),
                    ),
                    TextButton(
                      onPressed: _rescan,
                      child: const Text('Rescan'),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: Center(
                child: Container(
                  width: 280,
                  height: 280,
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _errorMessage != null ? Colors.red : Colors.blueAccent,
                      width: 2,
                    ),
                  ),
                  child: MobileScanner(
                    controller: _scannerController,
                    onDetect: _handleBarcodeDetected,
                  ),
                ),
              ),
            ),
            if (!_isScanning && _errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: ElevatedButton.icon(
                  onPressed: _rescan,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Tap to Scan Again'),
                ),
              )
            else
              const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}
