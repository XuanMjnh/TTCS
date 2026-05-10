import 'knowledge_section.dart';

class FarmingTipArticle {
  const FarmingTipArticle({
    required this.id,
    required this.title,
    required this.summary,
    required this.sections,
    required this.sources,
  });

  final String id;
  final String title;
  final String summary;
  final List<KnowledgeSection> sections;
  final List<String> sources;

  factory FarmingTipArticle.fromJson(Map<String, dynamic> json) =>
      FarmingTipArticle(
        id: json['id']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
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
