import 'dart:convert';

/// Model representing a validated locomotive IoT QR code payload (Member 5).
class QrPayload {
  final String unitId;
  final String mac;
  final String hwType;

  const QrPayload({
    required this.unitId,
    required this.mac,
    required this.hwType,
  });

  /// Converts the payload to a String map for navigation arguments
  Map<String, String> toMap() {
    return {
      'unit_id': unitId,
      'mac': mac,
      'hw_type': hwType,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QrPayload &&
          runtimeType == other.runtimeType &&
          unitId == other.unitId &&
          mac == other.mac &&
          hwType == other.hwType;

  @override
  int get hashCode => unitId.hashCode ^ mac.hashCode ^ hwType.hashCode;

  @override
  String toString() =>
      'QrPayload(unit_id: $unitId, mac: $mac, hw_type: $hwType)';
}

/// Standalone, pure validator function for IoT locomotive pairing QR payloads.
/// Parses raw JSON string and validates the presence and non-emptiness of
/// 'unit_id', 'mac', and 'hw_type'.
///
/// Throws [FormatException] on invalid JSON, missing fields, or empty values.
QrPayload parseAndValidateQrPayload(String rawJson) {
  final dynamic decoded;
  try {
    decoded = jsonDecode(rawJson);
  } catch (e) {
    throw FormatException('Invalid QR Code: Content is not valid JSON ($e).');
  }

  if (decoded is! Map<String, dynamic>) {
    throw const FormatException(
      'Malformed QR: Payload must be a valid JSON object.',
    );
  }

  final unitId = decoded['unit_id']?.toString().trim();
  final mac = decoded['mac']?.toString().trim();
  final hwType = decoded['hw_type']?.toString().trim();

  // Validate all 3 fields are present and non-empty
  if (unitId == null || unitId.isEmpty ||
      mac == null || mac.isEmpty ||
      hwType == null || hwType.isEmpty) {
    throw const FormatException(
      'Incomplete QR: Required fields (unit_id, mac, hw_type) are missing or empty.',
    );
  }

  return QrPayload(
    unitId: unitId,
    mac: mac,
    hwType: hwType,
  );
}
