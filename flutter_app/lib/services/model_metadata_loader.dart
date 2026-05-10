import 'dart:convert';
import 'package:flutter/services.dart';
import '../core/constants/app_constants.dart';
import '../data/models/model_metadata.dart';
import '../data/models/model_config.dart';

class ModelMetadataLoader {
  Future<List<String>> loadLabels() async {
    final raw = await rootBundle.loadString(AppConstants.labelsAsset);
    return raw
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList(growable: false);
  }

  Future<ModelMetadata> loadMetadata() async {
    final raw = await rootBundle.loadString(AppConstants.modelMetaAsset);
    return ModelMetadata.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<ModelConfig> loadModelConfig() async {
    final raw = await rootBundle.loadString(AppConstants.modelConfigAsset);
    return ModelConfig.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }
}
