import 'dart:convert';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image/image.dart' as img;
import '../data/models/scan_diagnosis.dart';
import '../data/repositories/history_repository.dart';
import 'firebase_storage_service.dart';
import 'leaf_scan_service.dart';

class ScanImageService {
  ScanImageService(
      {LeafScanService? leafScanService,
      HistoryRepository? historyRepository,
      FirebaseStorageService? storageService})
      : _leafScanService = leafScanService ?? LeafScanService(),
        _historyRepository = historyRepository ?? HistoryRepository(),
        _storageService = storageService ?? FirebaseStorageService();

  final LeafScanService _leafScanService;
  final HistoryRepository _historyRepository;
  final FirebaseStorageService _storageService;

  Future<ScanDiagnosis> scanAndSave(Uint8List bytes,
      {String? cropHint, String? userNote}) async {
    final diagnosis = await _leafScanService.scan(bytes, cropHint: cropHint);
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final historyId = _historyRepository.newId(user.uid);
      final uploaded = await _storageService.uploadScanImage(
          uid: user.uid, historyId: historyId, bytes: bytes);
      final preview = _previewBase64(bytes);
      final data = diagnosis.toHistoryMap(
        imageUrl: uploaded.url,
        imageStoragePath: uploaded.path,
        imageUploadError: uploaded.error,
        imagePreviewBase64: uploaded.url == null ? preview : null,
        userNote: userNote,
      );
      await _historyRepository.saveWithId(user.uid, historyId, data);
    }
    return diagnosis;
  }

  String? _previewBase64(Uint8List bytes) {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return null;
    final oriented = img.bakeOrientation(decoded);
    final resized = img.copyResize(
      oriented,
      width: oriented.width >= oriented.height ? 640 : null,
      height: oriented.height > oriented.width ? 640 : null,
      interpolation: img.Interpolation.average,
    );
    return base64Encode(Uint8List.fromList(img.encodeJpg(resized, quality: 82)));
  }
}
