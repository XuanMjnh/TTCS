import 'dart:convert';

import 'package:flutter/services.dart';

import '../core/constants/app_constants.dart';
import '../data/models/crop_catalog_item.dart';
import '../data/models/crop_info_article.dart';
import '../data/models/farming_tip_article.dart';
import '../data/models/label_taxonomy_item.dart';
import '../data/models/plant_article.dart';

class TaxonomyLoader {
  Future<Map<String, LabelTaxonomyItem>> loadTaxonomy() async {
    final raw = await rootBundle.loadString(AppConstants.taxonomyAsset);
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return decoded.map(
      (key, value) => MapEntry(
        key,
        LabelTaxonomyItem.fromJson(Map<String, dynamic>.from(value as Map)),
      ),
    );
  }

  Future<Map<String, PlantArticle>> loadAdvice() async {
    final raw = await rootBundle.loadString(AppConstants.adviceAsset);
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return decoded.map(
      (key, value) => MapEntry(
        key,
        PlantArticle.fromJson(Map<String, dynamic>.from(value as Map)),
      ),
    );
  }

  Future<List<CropInfoArticle>> loadCropInfo() async {
    final raw = await rootBundle.loadString(AppConstants.cropInfoAsset);
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((e) =>
            CropInfoArticle.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList(growable: false);
  }

  Future<List<FarmingTipArticle>> loadFarmingTips() async {
    final raw = await rootBundle.loadString(AppConstants.farmingTipsAsset);
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((e) =>
            FarmingTipArticle.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList(growable: false);
  }

  Future<List<CropCatalogItem>> loadCropCatalog() async {
    final raw = await rootBundle.loadString(AppConstants.cropCatalogAsset);
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((e) =>
            CropCatalogItem.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList(growable: false);
  }

  List<String> validateContract({
    required List<String> labels,
    required int numClasses,
    required Map<String, LabelTaxonomyItem> taxonomy,
    required Map<String, PlantArticle> advice,
  }) {
    final errors = <String>[];
    if (labels.length != numClasses) {
      errors.add('Số class trong model_meta.json không khớp labels.txt.');
    }
    for (final label in labels) {
      if (!taxonomy.containsKey(label)) {
        errors.add('Thiếu taxonomy cho label: $label');
      }
      final item = taxonomy[label];
      if (item != null &&
          (item.isDisease || item.isHealthy || item.isUnknown) &&
          !advice.containsKey(label)) {
        errors.add('Thiếu advice_vi.json cho label: $label');
      }
    }
    return errors;
  }
}
