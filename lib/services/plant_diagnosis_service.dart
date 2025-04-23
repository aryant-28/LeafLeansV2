import 'dart:io';
import 'dart:math' as math;
import '../models/diagnosis_result.dart';

class PlantDiagnosisService {
  // Class labels - these would be loaded from a file in a real app
  static final List<String> _diseaseLabels = [
    'Healthy',
    'Apple Black Rot',
    'Apple Scab',
    'Apple Cedar Rust',
    'Cherry Powdery Mildew',
    'Corn Gray Leaf Spot',
    'Corn Common Rust',
    'Corn Northern Leaf Blight',
    'Grape Black Rot',
    'Grape Esca (Black Measles)',
    'Grape Leaf Blight',
  ];

  // Disease information database - this would come from an API in a real app
  static final Map<String, Map<String, dynamic>> _diseaseInfo = {
    'Healthy': {
      'description':
          'Your plant appears to be healthy! No signs of disease or stress detected.',
      'remedies': [
        'Continue with regular care and maintenance.',
        'Ensure proper watering, fertilization, and sunlight.'
      ],
      'prevention_tips': [
        'Regular monitoring for early signs of stress or disease.',
        'Maintain good air circulation around plants.',
        'Avoid overwatering or overcrowding plants.'
      ],
      'condition': 'healthy',
    },
    'Apple Black Rot': {
      'description':
          'Black rot is a fungal disease that affects apple trees, causing leaf spots and fruit rot.',
      'remedies': [
        'Remove and destroy infected fruits and leaves.',
        'Apply fungicides containing captan or myclobutanil as recommended.',
        'Prune affected branches during the dormant season.'
      ],
      'prevention_tips': [
        'Maintain proper tree spacing for good air circulation.',
        'Clean up fallen leaves and fruit from the orchard floor.',
        'Apply preventative fungicide sprays during the growing season.'
      ],
      'condition': 'moderate',
    },
  };

  Future<DiagnosisResult> diagnoseLeaf(File imageFile) async {
    try {
      // Simulate model processing time
      await Future.delayed(const Duration(seconds: 2));

      // Get a random disease for demonstration
      final random = math.Random();
      final isHealthy =
          random.nextDouble() > 0.8; // 20% chance of being healthy

      String diseaseName;
      if (isHealthy) {
        diseaseName = 'Healthy';
      } else {
        // Select a random disease from our labels (excluding the healthy one)
        final diseaseIndex =
            random.nextInt(_diseaseLabels.length - 1) + 1; // Skip healthy
        diseaseName = _diseaseLabels[diseaseIndex];
      }

      // If we don't have info for this disease, default to a common one
      final diseaseData =
          _diseaseInfo[diseaseName] ?? _diseaseInfo['Apple Black Rot']!;

      // Generate a confidence score - higher for healthy, more variable for diseases
      final confidence = isHealthy
          ? 0.85 + (random.nextDouble() * 0.15) // 85-100% for healthy
          : 0.6 + (random.nextDouble() * 0.3); // 60-90% for diseases

      return DiagnosisResult(
        diseaseName: diseaseName,
        description: diseaseData['description'],
        remedies: List<String>.from(diseaseData['remedies']),
        preventionTips: List<String>.from(diseaseData['prevention_tips']),
        confidence: confidence,
        condition:
            DiagnosisResult.conditionFromString(diseaseData['condition']),
      );
    } catch (e) {
      throw Exception('Failed to diagnose leaf image: $e');
    }
  }
}
