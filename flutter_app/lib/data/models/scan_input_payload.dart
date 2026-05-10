import 'dart:typed_data';

class ScanInputPayload {
  const ScanInputPayload({required this.imageBytes, this.cropHint});
  final Uint8List imageBytes;
  final String? cropHint;
}
