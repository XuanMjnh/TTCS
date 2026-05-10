import 'prediction.dart';
import 'image_quality_result.dart';
import 'label_taxonomy_item.dart';

class ScanDiagnosis {
  const ScanDiagnosis({
    required this.predictedLabel,
    required this.taxonomy,
    required this.confidence,
    required this.margin,
    required this.status,
    required this.cropHint,
    required this.cropConsistencyStatus,
    required this.topPredictions,
    required this.modelVersion,
    required this.labelsVersion,
    required this.taxonomyVersion,
    required this.preprocessingVersion,
    required this.imageQuality,
    required this.message,
  });

  final String predictedLabel;
  final LabelTaxonomyItem taxonomy;
  final double confidence;
  final double margin;
  final String status;
  final String? cropHint;
  final String cropConsistencyStatus;
  final List<Prediction> topPredictions;
  final String modelVersion;
  final String labelsVersion;
  final String taxonomyVersion;
  final String preprocessingVersion;
  final ImageQualityResult imageQuality;
  final String message;

  String get displayTitle {
    return switch (status) {
      'low_quality' => 'Ảnh chưa đạt',
      'error' => 'Lỗi xử lý ảnh',
      'uncertain' => 'Chưa chắc chắn',
      'unknown' => 'Không xác định',
      'crop_mismatch' => 'Không khớp cây trồng',
      _ => taxonomy.displayTitle,
    };
  }

  Map<String, dynamic> toHistoryMap({
    String? imageUrl,
    String? imageStoragePath,
    String? imageUploadError,
    String? imagePreviewBase64,
    String? userNote,
  }) =>
      {
        'predictedLabel': predictedLabel,
        'cropKey': taxonomy.cropKey,
        'cropNameVi': taxonomy.cropNameVi,
        'conditionKey': taxonomy.conditionKey,
        'conditionNameVi': taxonomy.conditionNameVi,
        'displayTitle': displayTitle,
        'articleLabel': taxonomy.articleLabel,
        'articleTitle': displayTitle,
        'confidence': confidence,
        'margin': margin,
        'diagnosisStatus': status,
        'cropHint': cropHint,
        'cropConsistencyStatus': cropConsistencyStatus,
        'modelTopPredictions': topPredictions.map((e) => e.toJson()).toList(),
        'modelVersion': modelVersion,
        'labelsVersion': labelsVersion,
        'taxonomyVersion': taxonomyVersion,
        'preprocessingVersion': preprocessingVersion,
        'imageQualityInfo': imageQuality.toJson(),
        'imageUrl': imageUrl,
        'imageStoragePath': imageStoragePath,
        'imageUploadError': imageUploadError,
        'imagePreviewBase64': imagePreviewBase64,
        'userNote': userNote,
        'userCorrectionLabel': null,
        'createdAtClient': DateTime.now().toIso8601String(),
      };
}
