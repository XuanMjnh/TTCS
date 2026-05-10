import '../../services/taxonomy_loader.dart';
import '../models/crop_info_article.dart';
import '../models/farming_tip_article.dart';
import '../models/plant_article.dart';

class KnowledgeRepository {
  KnowledgeRepository({TaxonomyLoader? loader})
      : _loader = loader ?? TaxonomyLoader();
  final TaxonomyLoader _loader;

  Future<List<PlantArticle>> allArticles() async {
    final map = await _loader.loadAdvice();
    final list = map.values.toList();
    list.sort((a, b) => a.cropName.compareTo(b.cropName));
    return list;
  }

  Future<List<CropInfoArticle>> cropInfoArticles() async {
    final list = await _loader.loadCropInfo();
    final sorted = list.toList()
      ..sort((a, b) => a.cropName.compareTo(b.cropName));
    return sorted;
  }

  Future<List<FarmingTipArticle>> farmingTips() async {
    return _loader.loadFarmingTips();
  }

  Future<PlantArticle?> articleByLabel(String label) async {
    final map = await _loader.loadAdvice();
    return map[label];
  }
}
