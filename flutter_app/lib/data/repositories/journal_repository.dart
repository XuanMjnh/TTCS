import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/journal_entry.dart';

class JournalRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  CollectionReference<Map<String, dynamic>> _collection(String uid) =>
      _firestore.collection('users').doc(uid).collection('journals');

  Stream<List<JournalEntry>> watchJournals(String uid) {
    return _collection(uid)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(JournalEntry.fromDoc).toList());
  }

  Future<void> create(String uid,
      {required String title,
      required String note,
      required String cropKey,
      required String cropNameVi}) async {
    await _collection(uid).add({
      'title': title,
      'note': note,
      'cropKey': cropKey,
      'cropNameVi': cropNameVi,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> update(String uid, JournalEntry entry) async =>
      _collection(uid).doc(entry.id).update(entry.toMap());
  Future<void> delete(String uid, String id) async =>
      _collection(uid).doc(id).delete();
}
