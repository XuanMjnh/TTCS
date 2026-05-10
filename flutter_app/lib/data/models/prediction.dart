class Prediction {
  const Prediction(
      {required this.label, required this.confidence, required this.index});
  final String label;
  final double confidence;
  final int index;

  Map<String, dynamic> toJson() =>
      {'label': label, 'confidence': confidence, 'index': index};

  factory Prediction.fromJson(Map<String, dynamic> json) => Prediction(
        label: json['label'] as String,
        confidence: (json['confidence'] as num).toDouble(),
        index: (json['index'] as num).toInt(),
      );
}
