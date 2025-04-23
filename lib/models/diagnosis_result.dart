enum PlantCondition {
  healthy,
  mild,
  moderate,
  severe,
}

class DiagnosisResult {
  final String diseaseName;
  final String description;
  final List<String> remedies;
  final List<String> preventionTips;
  final double confidence;
  final PlantCondition condition;

  DiagnosisResult({
    required this.diseaseName,
    required this.description,
    required this.remedies,
    required this.preventionTips,
    required this.confidence,
    required this.condition,
  });

  factory DiagnosisResult.fromJson(Map<String, dynamic> json) {
    return DiagnosisResult(
      diseaseName: json['disease_name'],
      description: json['description'],
      remedies: List<String>.from(json['remedies']),
      preventionTips: List<String>.from(json['prevention_tips']),
      confidence: json['confidence'].toDouble(),
      condition: conditionFromString(json['condition']),
    );
  }

  static PlantCondition conditionFromString(String condition) {
    switch (condition.toLowerCase()) {
      case 'healthy':
        return PlantCondition.healthy;
      case 'mild':
        return PlantCondition.mild;
      case 'moderate':
        return PlantCondition.moderate;
      case 'severe':
        return PlantCondition.severe;
      default:
        return PlantCondition.moderate;
    }
  }
}
