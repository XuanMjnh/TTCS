import 'knowledge_section.dart';

class CropInfoArticle {
  const CropInfoArticle({
    required this.cropKey,
    required this.cropName,
    required this.summary,
    required this.sections,
    required this.sources,
  });

  final String cropKey;
  final String cropName;
  final String summary;
  final List<KnowledgeSection> sections;
  final List<String> sources;

  factory CropInfoArticle.fromJson(Map<String, dynamic> json) =>
      CropInfoArticle(
        cropKey: json['cropKey']?.toString() ?? '',
        cropName: json['cropName']?.toString() ?? '',
        summary: json['summary']?.toString() ?? '',
        sections: (json['sections'] as List? ?? const [])
            .map((section) => KnowledgeSection.fromJson(
                Map<String, dynamic>.from(section as Map)))
            .toList(growable: false),
        sources: (json['sources'] as List? ?? const [])
            .map((source) => source.toString())
            .toList(growable: false),
      );
}
