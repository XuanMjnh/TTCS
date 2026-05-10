import 'dart:typed_data';
import '../data/models/image_quality_result.dart';
import '../data/models/label_taxonomy_item.dart';
import '../data/models/prediction.dart';
import '../data/models/scan_diagnosis.dart';
import 'classifier.dart';
import 'image_quality_service.dart';
import 'model_metadata_loader.dart';
import 'taxonomy_loader.dart';

class LeafScanService {
  LeafScanService(
      {Classifier? classifier,
      ImageQualityService? qualityService,
      TaxonomyLoader? taxonomyLoader,
      ModelMetadataLoader? metadataLoader})
      : _classifier = classifier ?? Classifier(),
        _qualityService = qualityService ?? ImageQualityService(),
        _taxonomyLoader = taxonomyLoader ?? TaxonomyLoader(),
        _metadataLoader = metadataLoader ?? ModelMetadataLoader();

  final Classifier _classifier;
  final ImageQualityService _qualityService;
  final TaxonomyLoader _taxonomyLoader;
  final ModelMetadataLoader _metadataLoader;

  Future<ScanDiagnosis> scan(Uint8List bytes, {String? cropHint}) async {
    final meta = await _metadataLoader.loadMetadata();
    final config = await _metadataLoader.loadModelConfig();
    final taxonomy = await _taxonomyLoader.loadTaxonomy();
    final quality = _qualityService.check(bytes, meta);
    if (!quality.ok) {
      final item =
          taxonomy['unknown__non_leaf_or_other'] ?? taxonomy.values.first;
      return _diagnosis(
          item,
          0,
          0,
          'low_quality',
          cropHint,
          'not_checked',
          const [],
          meta.modelVersion,
          meta.labelsVersion,
          meta.taxonomyVersion,
          meta.preprocessingVersion,
          quality,
          config.messageFor('low_quality'));
    }
    try {
      final result = await _classifier.predict(bytes);
      final top = result.predictions;
      final best = top.first;
      final second = top.length > 1 ? top[1] : top.first;
      final margin = best.confidence - second.confidence;
      final item = taxonomy[best.label];
      if (item == null) throw StateError('Thiếu taxonomy cho ${best.label}');
      final threshold = result.metadata.thresholdFor(best.label);
      final cropMismatch = cropHint != null &&
          cropHint.isNotEmpty &&
          cropHint != 'auto' &&
          item.cropKey != cropHint;
      final cropConsistency = cropMismatch ? 'mismatch' : 'matched_or_auto';
      String status;
      String message = '';
      if (cropMismatch) {
        status = best.confidence >= threshold ? 'crop_mismatch' : 'uncertain';
        message = config.messageFor('crop_mismatch');
      } else if (item.isUnknown) {
        status = best.confidence >= threshold ? 'unknown' : 'uncertain';
        message = status == 'uncertain'
            ? config.messageFor('uncertain')
            : 'Ảnh có thể không thuộc nhóm cây/bệnh model đã học. Vui lòng kiểm tra lại ảnh.';
      } else if (margin < result.metadata.uncertaintyMargin ||
          best.confidence < threshold) {
        status = 'uncertain';
        message = config.messageFor('uncertain');
      } else if (item.isHealthy) {
        status = 'healthy';
        message =
            'AI chưa thấy dấu hiệu bệnh rõ trong ảnh. Tiếp tục theo dõi thực tế cây trồng.';
      } else if (item.isDisease) {
        status = 'confident';
        message =
            'AI đủ tin cậy để gợi ý nhóm bệnh này. Hãy đối chiếu triệu chứng ngoài thực tế trước khi xử lý.';
      } else {
        status = 'uncertain';
        message = config.messageFor('uncertain');
      }
      return _diagnosis(
          item,
          best.confidence,
          margin,
          status,
          cropHint,
          cropConsistency,
          top,
          result.metadata.modelVersion,
          result.metadata.labelsVersion,
          result.metadata.taxonomyVersion,
          result.metadata.preprocessingVersion,
          quality,
          message);
    } catch (e) {
      final item =
          taxonomy['unknown__non_leaf_or_other'] ?? taxonomy.values.first;
      return _diagnosis(
          item,
          0,
          0,
          'error',
          cropHint,
          'error',
          const [],
          meta.modelVersion,
          meta.labelsVersion,
          meta.taxonomyVersion,
          meta.preprocessingVersion,
          quality,
          'Lỗi xử lý ảnh hoặc model: $e');
    }
  }

  ScanDiagnosis _diagnosis(
      LabelTaxonomyItem item,
      double confidence,
      double margin,
      String status,
      String? cropHint,
      String cropConsistencyStatus,
      List<Prediction> topPredictions,
      String modelVersion,
      String labelsVersion,
      String taxonomyVersion,
      String preprocessingVersion,
      ImageQualityResult quality,
      String message) {
    return ScanDiagnosis(
      predictedLabel: item.label,
      taxonomy: item,
      confidence: confidence,
      margin: margin,
      status: status,
      cropHint: cropHint,
      cropConsistencyStatus: cropConsistencyStatus,
      topPredictions: topPredictions,
      modelVersion: modelVersion,
      labelsVersion: labelsVersion,
      taxonomyVersion: taxonomyVersion,
      preprocessingVersion: preprocessingVersion,
      imageQuality: quality,
      message: message,
    );
  }
}
