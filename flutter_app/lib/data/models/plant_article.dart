class PlantArticle {
  const PlantArticle({
    required this.label,
    required this.cropName,
    required this.diseaseName,
    required this.title,
    required this.symptoms,
    required this.possibleCauses,
    required this.treatment,
    required this.care,
    required this.prevention,
    required this.whenToAskExpert,
    required this.note,
  });

  final String label;
  final String cropName;
  final String diseaseName;
  final String title;
  final List<String> symptoms;
  final List<String> possibleCauses;
  final List<String> treatment;
  final List<String> care;
  final List<String> prevention;
  final List<String> whenToAskExpert;
  final String note;

  factory PlantArticle.fromJson(Map<String, dynamic> json) => PlantArticle(
        label: json['label'] as String,
        cropName: json['cropName'] as String,
        diseaseName: json['diseaseName'] as String,
        title: json['title'] as String,
        symptoms: (json['symptoms'] as List? ?? const [])
            .map((e) => e.toString())
            .toList(),
        possibleCauses: (json['possibleCauses'] as List? ?? const [])
            .map((e) => e.toString())
            .toList(),
        treatment: (json['treatment'] as List? ?? const [])
            .map((e) => e.toString())
            .toList(),
        care: (json['care'] as List? ?? const [])
            .map((e) => e.toString())
            .toList(),
        prevention: (json['prevention'] as List? ?? const [])
            .map((e) => e.toString())
            .toList(),
        whenToAskExpert: (json['whenToAskExpert'] as List? ?? const [])
            .map((e) => e.toString())
            .toList(),
        note: json['note'] as String,
      );
}
