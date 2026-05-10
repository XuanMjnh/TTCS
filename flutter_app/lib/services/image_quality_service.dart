import 'dart:math';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import '../data/models/image_quality_result.dart';
import '../data/models/model_metadata.dart';

class ImageQualityService {
  ImageQualityResult check(Uint8List bytes, ModelMetadata meta) {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      return const ImageQualityResult(
          ok: false,
          reasons: ['decode_error'],
          brightness: 0,
          sharpness: 0,
          width: 0,
          height: 0);
    }
    final image = img.bakeOrientation(decoded);
    final gray = img.grayscale(image);
    final pixels = <int>[];
    for (final p in gray) {
      pixels.add(p.r.toInt());
    }
    final brightness =
        pixels.isEmpty ? 0.0 : pixels.reduce((a, b) => a + b) / pixels.length;
    double gradientVariance = 0;
    if (gray.width > 2 && gray.height > 2) {
      final vals = <double>[];
      for (var y = 1; y < gray.height - 1; y += max(1, gray.height ~/ 300)) {
        for (var x = 1; x < gray.width - 1; x += max(1, gray.width ~/ 300)) {
          final c = gray.getPixel(x, y).r.toDouble();
          final left = gray.getPixel(x - 1, y).r.toDouble();
          final right = gray.getPixel(x + 1, y).r.toDouble();
          final up = gray.getPixel(x, y - 1).r.toDouble();
          final down = gray.getPixel(x, y + 1).r.toDouble();
          vals.add((left + right + up + down - 4 * c).abs());
        }
      }
      if (vals.isNotEmpty) {
        final mean = vals.reduce((a, b) => a + b) / vals.length;
        gradientVariance =
            vals.map((v) => pow(v - mean, 2)).reduce((a, b) => a + b) /
                vals.length;
      }
    }
    final q = meta.qualityGate;
    final minSharpness = (q['minSharpness'] as num? ?? 80).toDouble();
    final minBrightness = (q['minBrightness'] as num? ?? 35).toDouble();
    final maxBrightness = (q['maxBrightness'] as num? ?? 230).toDouble();
    final reasons = <String>[];
    if (image.width < 96 || image.height < 96) reasons.add('too_small');
    if (brightness < minBrightness) reasons.add('too_dark');
    if (brightness > maxBrightness) reasons.add('too_bright');
    if (gradientVariance < minSharpness) reasons.add('too_blurry');
    return ImageQualityResult(
        ok: reasons.isEmpty,
        reasons: reasons,
        brightness: brightness,
        sharpness: gradientVariance,
        width: image.width,
        height: image.height);
  }
}
