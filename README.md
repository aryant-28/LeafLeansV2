# LeafLens - AI Plant Doctor

LeafLens is a Flutter application that uses AI to diagnose plant diseases from leaf images and provides care recommendations.

## Features

- **Leaf Scanning:** Capture or upload leaf images to identify diseases and health issues.
- **AI Diagnosis:** Uses ResNet-50 and EfficientNet B0 models for accurate plant disease detection.
- **Care Recommendations:** Provides detailed remedies and prevention tips based on diagnosis.
- **AI Chatbot:** Chat with an AI plant expert for personalized advice and care instructions.
- **Multilingual Support:** Available in English, Hindi, and Marathi.

## Getting Started

### Prerequisites

- Flutter SDK (2.5.0 or later)
- Dart SDK (2.14.0 or later)
- Android Studio / VS Code with Flutter extensions

### Installation

1. Clone the repository:
   ```
   git clone https://github.com/yourusername/leaf_lens.git
   cd leaf_lens
   ```

2. Install dependencies:
   ```
   flutter pub get
   ```

3. Run the app:
   ```
   flutter run
   ```

## Project Structure

```
lib/
├── main.dart            # App entry point
├── models/              # Data models
├── screens/             # App screens
├── services/            # Business logic and API services
├── utils/              # Utility classes and functions
└── widgets/            # Reusable UI components

assets/
├── images/             # App images
├── ml_models/          # TensorFlow Lite models
└── locales/            # Localization files
```

## Machine Learning Models

LeafLens uses two primary models for plant disease detection:

1. **ResNet-50:** Deep residual network offering high accuracy for general leaf disease classification.
2. **EfficientNet B0:** Lightweight model optimized for mobile devices.

Both models are implemented as TensorFlow Lite models for on-device inference.

## Localization

The app supports the following languages:
- English
- Hindi (हिंदी)
- Marathi (मराठी)

## Future Improvements

- Add more plant species and disease types to the detection system
- Implement offline mode for diagnosis
- Add plant care scheduling and reminders
- Expand language support

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Plant Village Dataset for training data
- TensorFlow for machine learning framework
- Flutter team for the amazing cross-platform framework 
