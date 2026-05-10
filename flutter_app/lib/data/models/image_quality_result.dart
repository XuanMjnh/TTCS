class ImageQualityResult {
  const ImageQualityResult({
    required this.ok,
    required this.reasons,
    required this.brightness,
    required this.sharpness,
    required this.width,
    required this.height,
  });

  final bool ok;
  final List<String> reasons;
  final double brightness;
  final double sharpness;
  final int width;
  final int height;

  Map<String, dynamic> toJson() => {
        'ok': ok,
        'reasons': reasons,
        'brightness': brightness,
        'sharpness': sharpness,
        'width': width,
        'height': height,
      };

  factory ImageQualityResult.fromJson(Map<String, dynamic> json) =>
      ImageQualityResult(
        ok: json['ok'] == true,
        reasons: (json['reasons'] as List? ?? const [])
            .map((e) => e.toString())
            .toList(),
        brightness: (json['brightness'] as num? ?? 0).toDouble(),
        sharpness: (json['sharpness'] as num? ?? 0).toDouble(),
        width: (json['width'] as num? ?? 0).toInt(),
        height: (json['height'] as num? ?? 0).toInt(),
      );
}
