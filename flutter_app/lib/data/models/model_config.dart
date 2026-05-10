class ModelConfig {
  const ModelConfig(
      {required this.disclaimer,
      required this.defaultMessages,
      required this.allowedStatuses});

  final String disclaimer;
  final Map<String, dynamic> defaultMessages;
  final List<String> allowedStatuses;

  String messageFor(String key) => defaultMessages[key]?.toString() ?? '';

  factory ModelConfig.fromJson(Map<String, dynamic> json) => ModelConfig(
        disclaimer: json['disclaimer'] as String,
        defaultMessages:
            Map<String, dynamic>.from(json['defaultMessages'] as Map),
        allowedStatuses:
            (json['allowedStatuses'] as List).map((e) => e.toString()).toList(),
      );
}
