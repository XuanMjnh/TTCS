import 'package:cloud_firestore/cloud_firestore.dart';

class JournalEntry {
  const JournalEntry(
      {required this.id,
      required this.title,
      required this.note,
      required this.cropKey,
      required this.cropNameVi,
      required this.createdAt,
      required this.updatedAt});

  final String id;
  final String title;
  final String note;
  final String cropKey;
  final String cropNameVi;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toMap() => {
        'title': title,
        'note': note,
        'cropKey': cropKey,
        'cropNameVi': cropNameVi,
        'updatedAt': FieldValue.serverTimestamp(),
      };

  factory JournalEntry.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    DateTime read(dynamic v) => v is Timestamp ? v.toDate() : DateTime.now();
    return JournalEntry(
      id: doc.id,
      title: data['title']?.toString() ?? '',
      note: data['note']?.toString() ?? '',
      cropKey: data['cropKey']?.toString() ?? 'auto',
      cropNameVi: data['cropNameVi']?.toString() ?? 'Tự động',
      createdAt: read(data['createdAt']),
      updatedAt: read(data['updatedAt']),
    );
  }
}
