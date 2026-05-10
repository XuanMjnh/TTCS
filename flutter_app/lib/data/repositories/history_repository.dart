import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/firebase_storage_service.dart';
import '../models/history_entry.dart';

class HistoryRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorageService _storage = FirebaseStorageService();

  CollectionReference<Map<String, dynamic>> _collection(String uid) =>
      _firestore.collection('users').doc(uid).collection('history');

  String newId(String uid) => _collection(uid).doc().id;

  Future<void> saveWithId(
      String uid, String historyId, Map<String, dynamic> data) {
    return _collection(uid)
        .doc(historyId)
        .set({...data, 'createdAt': FieldValue.serverTimestamp()});
  }

  Stream<List<HistoryEntry>> watchHistory(String uid,
      {String? cropKey, String? status}) {
    Query<Map<String, dynamic>> q =
        _collection(uid).orderBy('createdAt', descending: true);
    if (cropKey != null && cropKey.isNotEmpty && cropKey != 'auto')
      q = q.where('cropKey', isEqualTo: cropKey);
    if (status != null && status.isNotEmpty && status != 'all')
      q = q.where('diagnosisStatus', isEqualTo: status);
    return q
        .snapshots()
        .map((snap) => snap.docs.map(HistoryEntry.fromDoc).toList());
  }

  Future<HistoryEntry?> getOne(String uid, String id) async {
    final doc = await _collection(uid).doc(id).get();
    if (!doc.exists) return null;
    return HistoryEntry.fromDoc(doc);
  }

  Future<void> deleteOne(String uid, HistoryEntry entry) async {
    await _storage.deleteIfExists(entry.imageStoragePath);
    await _collection(uid).doc(entry.id).delete();
  }

  Future<void> deleteAll(String uid) async {
    final snap = await _collection(uid).get();
    final batch = _firestore.batch();
    for (final doc in snap.docs) {
      final entry = HistoryEntry.fromDoc(doc);
      await _storage.deleteIfExists(entry.imageStoragePath);
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
