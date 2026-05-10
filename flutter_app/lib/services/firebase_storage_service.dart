import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';

class UploadedImageInfo {
  const UploadedImageInfo({this.url, this.path, this.error});
  final String? url;
  final String? path;
  final String? error;
}

class FirebaseStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<UploadedImageInfo> uploadScanImage(
      {required String uid,
      required String historyId,
      required Uint8List bytes}) async {
    final path = 'users/$uid/scans/$historyId.jpg';
    try {
      final ref = _storage.ref(path);
      await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
      final url = await ref.getDownloadURL();
      return UploadedImageInfo(url: url, path: path);
    } catch (e) {
      return UploadedImageInfo(error: e.toString());
    }
  }

  Future<void> deleteIfExists(String? path) async {
    if (path == null || path.isEmpty) return;
    try {
      await _storage.ref(path).delete();
    } on FirebaseException catch (e) {
      if (e.code != 'object-not-found') rethrow;
    }
  }
}
