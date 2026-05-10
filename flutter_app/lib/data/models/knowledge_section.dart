class KnowledgeSection {
  const KnowledgeSection({
    required this.title,
    required this.items,
  });

  final String title;
  final List<String> items;

  factory KnowledgeSection.fromJson(Map<String, dynamic> json) =>
      KnowledgeSection(
        title: json['title']?.toString() ?? '',
        items: (json['items'] as List? ?? const [])
            .map((item) => item.toString())
            .toList(growable: false),
      );
}
