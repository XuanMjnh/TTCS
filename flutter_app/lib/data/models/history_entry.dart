import 'package:cloud_firestore/cloud_firestore.dart';

class HistoryEntry {
  const HistoryEntry({
    required this.id,
    required this.predictedLabel,
    required this.cropKey,
    required this.cropNameVi,
    required this.conditionNameVi,
    required this.displayTitle,
    required this.confidence,
    required this.margin,
    required this.diagnosisStatus,
    required this.createdAt,
    this.imageUrl,
    this.imageStoragePath,
    this.imagePreviewBase64,
    this.articleLabel,
    this.userNote,
  });

  final String id;
  final String predictedLabel;
  final String cropKey;
  final String cropNameVi;
  final String conditionNameVi;
  final String displayTitle;
  final double confidence;
  final double margin;
  final String diagnosisStatus;
  final DateTime createdAt;
  final String? imageUrl;
  final String? imageStoragePath;
  final String? imagePreviewBase64;
  final String? articleLabel;
  final String? userNote;

  factory HistoryEntry.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final ts = data['createdAt'];
    final client = data['createdAtClient'];
    DateTime created = DateTime.now();
    if (ts is Timestamp) created = ts.toDate();
    if (client is String) created = DateTime.tryParse(client) ?? created;
    return HistoryEntry(
      id: doc.id,
      predictedLabel: data['predictedLabel']?.toString() ?? '',
      cropKey: data['cropKey']?.toString() ?? '',
      cropNameVi: data['cropNameVi']?.toString() ?? '',
      conditionNameVi: data['conditionNameVi']?.toString() ?? '',
      displayTitle: data['displayTitle']?.toString() ?? '',
      confidence: (data['confidence'] as num? ?? 0).toDouble(),
      margin: (data['margin'] as num? ?? 0).toDouble(),
      diagnosisStatus: data['diagnosisStatus']?.toString() ?? 'uncertain',
      createdAt: created,
      imageUrl: data['imageUrl']?.toString(),
      imageStoragePath: data['imageStoragePath']?.toString(),
      imagePreviewBase64: data['imagePreviewBase64']?.toString(),
      articleLabel: data['articleLabel']?.toString(),
      userNote: data['userNote']?.toString(),
    );
  }
}
