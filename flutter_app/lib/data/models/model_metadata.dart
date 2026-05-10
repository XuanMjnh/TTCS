class ModelMetadata {
  ModelMetadata({
    required this.modelVersion,
    required this.labelsVersion,
    required this.taxonomyVersion,
    required this.preprocessingVersion,
    required this.architecture,
    required this.inputSize,
    required this.numClasses,
    required this.topK,
    required this.outputActivation,
    required this.normalization,
    required this.thresholding,
    required this.qualityGate,
    required this.calibration,
  });

  final String modelVersion;
  final String labelsVersion;
  final String taxonomyVersion;
  final String preprocessingVersion;
  final String architecture;
  final int inputSize;
  final int numClasses;
  final int topK;
  final String outputActivation;
  final Map<String, dynamic> normalization;
  final Map<String, dynamic> thresholding;
  final Map<String, dynamic> qualityGate;
  final Map<String, dynamic> calibration;

  double get globalThreshold =>
      (thresholding['globalConfidenceThreshold'] as num?)?.toDouble() ?? 0.78;
  double get uncertaintyMargin =>
      (thresholding['globalUncertaintyMargin'] as num?)?.toDouble() ?? 0.15;
  bool get perClassThresholdsEnabled =>
      thresholding['perClassThresholdsEnabled'] == true;

  double thresholdFor(String label) {
    final per = thresholding['perClassThresholds'];
    if (perClassThresholdsEnabled && per is Map && per[label] is num) {
      return (per[label] as num).toDouble();
    }
    return globalThreshold;
  }

  factory ModelMetadata.fromJson(Map<String, dynamic> json) => ModelMetadata(
        modelVersion: json['modelVersion'] as String,
        labelsVersion: json['labelsVersion'] as String,
        taxonomyVersion: json['taxonomyVersion'] as String,
        preprocessingVersion: json['preprocessingVersion'] as String,
        architecture: json['architecture'] as String,
        inputSize: (json['inputSize'] as num).toInt(),
        numClasses: (json['numClasses'] as num).toInt(),
        topK: (json['topK'] as num).toInt(),
        outputActivation: json['outputActivation'] as String,
        normalization: Map<String, dynamic>.from(json['normalization'] as Map),
        thresholding: Map<String, dynamic>.from(json['thresholding'] as Map),
        qualityGate: Map<String, dynamic>.from(json['qualityGate'] as Map),
        calibration: Map<String, dynamic>.from(json['calibration'] as Map),
      );
}
