import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import '../core/constants/app_constants.dart';
import '../data/models/model_metadata.dart';
import '../data/models/prediction.dart';
import 'model_metadata_loader.dart';
import 'taxonomy_loader.dart';

class ClassifierResult {
  const ClassifierResult(
      {required this.predictions,
      required this.metadata,
      required this.labels});
  final List<Prediction> predictions;
  final ModelMetadata metadata;
  final List<String> labels;
}

class Classifier {
  Classifier(
      {ModelMetadataLoader? metadataLoader, TaxonomyLoader? taxonomyLoader})
      : _metadataLoader = metadataLoader ?? ModelMetadataLoader(),
        _taxonomyLoader = taxonomyLoader ?? TaxonomyLoader();

  final ModelMetadataLoader _metadataLoader;
  final TaxonomyLoader _taxonomyLoader;
  Interpreter? _interpreter;
  ModelMetadata? _metadata;
  List<String>? _labels;

  Future<void> initialize() async {
    _labels ??= await _metadataLoader.loadLabels();
    _metadata ??= await _metadataLoader.loadMetadata();
    final taxonomy = await _taxonomyLoader.loadTaxonomy();
    final advice = await _taxonomyLoader.loadAdvice();
    final contractErrors = _taxonomyLoader.validateContract(
        labels: _labels!,
        numClasses: _metadata!.numClasses,
        taxonomy: taxonomy,
        advice: advice);
    if (contractErrors.isNotEmpty) {
      throw StateError(contractErrors.join('\n'));
    }
    if (_interpreter == null) {
      try {
        _interpreter = await Interpreter.fromAsset(AppConstants.modelAsset);
        final outputShape = _interpreter!.getOutputTensor(0).shape;
        if (outputShape.isEmpty || outputShape.last != _labels!.length) {
          throw StateError('Output class của model không khớp labels.txt.');
        }
      } catch (e) {
        throw StateError(
            'Không load được model.tflite. Hãy train/export model thật rồi thay file placeholder. Chi tiết: $e');
      }
    }
  }

  Future<ClassifierResult> predict(Uint8List bytes) async {
    await initialize();
    final meta = _metadata!;
    final labels = _labels!;
    final input = _preprocess(bytes, meta);
    final output =
        List.generate(1, (_) => List<double>.filled(labels.length, 0));
    _interpreter!.run(input, output);
    var scores = List<double>.from(output.first);
    if (meta.outputActivation == 'logits') {
      final temp = meta.calibration['enabled'] == true
          ? (meta.calibration['temperature'] as num? ?? 1).toDouble()
          : 1.0;
      scores = _softmax(scores, temp);
    }
    final preds = <Prediction>[];
    for (var i = 0; i < labels.length; i++) {
      preds.add(Prediction(label: labels[i], confidence: scores[i], index: i));
    }
    preds.sort((a, b) => b.confidence.compareTo(a.confidence));
    return ClassifierResult(
        predictions: preds.take(meta.topK).toList(growable: false),
        metadata: meta,
        labels: labels);
  }

  List<List<List<List<double>>>> _preprocess(
      Uint8List bytes, ModelMetadata meta) {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) throw StateError('Không đọc được ảnh.');
    final oriented = img.bakeOrientation(decoded);
    final resized = img.copyResize(oriented,
        width: meta.inputSize,
        height: meta.inputSize,
        interpolation: img.Interpolation.linear);
    final norm = meta.normalization;
    final type = norm['type']?.toString() ?? 'scale_0_1';
    final scale = (norm['scale'] as num? ?? 255.0).toDouble();
    final mean = (norm['mean'] as List? ?? [0, 0, 0])
        .map((e) => (e as num).toDouble())
        .toList();
    final std = (norm['std'] as List? ?? [1, 1, 1])
        .map((e) => (e as num).toDouble())
        .toList();
    return [
      List.generate(meta.inputSize, (y) {
        return List.generate(meta.inputSize, (x) {
          final p = resized.getPixel(x, y);
          final rgb = [p.r.toDouble(), p.g.toDouble(), p.b.toDouble()];
          if (type == 'scale_0_1') {
            return rgb.map((v) => v / scale).toList();
          } else if (type == 'minus1_1') {
            return rgb.map((v) => (v / 127.5) - 1.0).toList();
          } else if (type == 'standardize') {
            return List.generate(3, (i) => (rgb[i] / scale - mean[i]) / std[i]);
          } else {
            return rgb;
          }
        });
      })
    ];
  }

  List<double> _softmax(List<double> logits, double temperature) {
    final maxLogit = logits.reduce(max);
    final exps = logits
        .map((v) => exp((v - maxLogit) / max(temperature, 1e-6)))
        .toList();
    final sum = exps.reduce((a, b) => a + b);
    return exps.map((v) => v / sum).toList();
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
  }
}
