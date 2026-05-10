class LabelTaxonomyItem {
  const LabelTaxonomyItem({
    required this.label,
    required this.cropKey,
    required this.cropNameVi,
    required this.conditionKey,
    required this.conditionNameVi,
    required this.isDisease,
    required this.isHealthy,
    required this.isUnknown,
    required this.articleLabel,
  });

  final String label;
  final String cropKey;
  final String cropNameVi;
  final String conditionKey;
  final String conditionNameVi;
  final bool isDisease;
  final bool isHealthy;
  final bool isUnknown;
  final String articleLabel;

  String get displayTitle => '$cropNameVi - $conditionNameVi';

  factory LabelTaxonomyItem.fromJson(Map<String, dynamic> json) =>
      LabelTaxonomyItem(
        label: json['label'] as String,
        cropKey: json['cropKey'] as String,
        cropNameVi: json['cropNameVi'] as String,
        conditionKey: json['conditionKey'] as String,
        conditionNameVi: json['conditionNameVi'] as String,
        isDisease: json['isDisease'] as bool,
        isHealthy: json['isHealthy'] as bool,
        isUnknown: json['isUnknown'] as bool,
        articleLabel: json['articleLabel'] as String,
      );
}
