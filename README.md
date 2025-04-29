# LeafLens - AI Plant Doctor

LeafLens is a cross-platform Flutter application that leverages AI to diagnose plant diseases from leaf images, provides actionable care recommendations, and offers a smart chatbot for plant care advice. The app is designed for plant enthusiasts, gardeners, and farmers to help maintain plant health and prevent disease spread.

## 🚀 Finished Project Goal
- **End Goal:** A user-friendly mobile app that allows users to scan plant leaves, receive instant AI-powered disease diagnosis, get care/remedy suggestions, set plant care reminders, and chat with an AI plant expert—all with multilingual support.
- **Current Condition:**
  - Fully functional core features: leaf scanning, AI diagnosis, chatbot, reminders, and localization.
  - Modular, extensible codebase ready for new plant species, diseases, and languages.
  - Uses simulated AI for diagnosis and chat (can be upgraded to real models/APIs).

---

## 📊 Current Situation & Roadmap to Completion

### Current Situation
- The application is **feature-complete for a demo/MVP**: users can scan leaves, get simulated AI diagnosis, chat with an AI plant expert, set reminders, and use the app in three languages.
- **Diagnosis and chatbot currently use simulated or API-based responses** for demonstration; real on-device ML models and more advanced AI integration are planned.
- The codebase is **modular and well-structured**, making it easy to add new features, plant species, diseases, or languages.
- **UI/UX is modern and responsive**, but can be further polished and tested on more devices.
- **No cloud sync or user accounts** yet; all data is local.

### Steps to Complete the Full Application

| Step | Description | Goal | Status |
|------|-------------|------|--------|
| 1 | **Core UI/UX Implementation** | Home, camera, diagnosis, chat, reminders, settings, splash, login screens | ✅ Done |
| 2 | **Leaf Scanning & Image Input** | Capture or upload leaf images using camera/gallery | ✅ Done |
| 3 | **Simulated AI Diagnosis** | Return random disease/health status for demo | ✅ Done |
| 4 | **Diagnosis Result UI** | Show disease name, description, remedies, prevention tips, confidence | ✅ Done |
| 5 | **AI Chatbot (API/Simulated)** | Chat with plant expert using Gemini API or fallback responses | ✅ Done |
| 6 | **Plant Care Reminders** | Add, enable/disable, delete reminders with notifications | ✅ Done |
| 7 | **Localization** | English, Hindi, Marathi; easy to add more | ✅ Done |
| 8 | **Modern Theming** | Google Fonts, Material 3, animations | ✅ Done |
| 9 | **Code Modularization** | Models, services, utils, assets structure | ✅ Done |
| 10 | **Testing & Bug Fixes** | Widget tests, manual QA | 🟡 In Progress |
| 11 | **Integrate Real ML Models** | Use TFLite models for on-device diagnosis | 🔲 Planned |
| 12 | **Expand Disease Database** | Add more plant species and diseases | 🔲 Planned |
| 13 | **Offline Mode** | Ensure diagnosis and chat work offline | 🔲 Planned |
| 14 | **Cloud Sync & Accounts** | User login, cloud backup for reminders/data | 🔲 Planned |
| 15 | **Accessibility & UX Polish** | More languages, accessibility features, device testing | 🔲 Planned |
| 16 | **Production Release** | Publish to Play Store/App Store | 🔲 Planned |

#### Legend:
- ✅ Done: Fully implemented and tested
- 🟡 In Progress: Partially implemented, being tested or improved
- 🔲 Planned: Not yet started, on the roadmap

#### Detailed Steps & Goals
1. **UI/UX Implementation:**
   - Build all main screens and navigation.
   - Ensure a smooth, modern, and accessible user experience.
2. **Leaf Scanning & Image Input:**
   - Integrate camera and gallery for image selection.
   - Handle permissions and errors gracefully.
3. **Simulated AI Diagnosis:**
   - Provide demo diagnosis using random selection.
   - Structure code for easy swap to real models.
4. **Diagnosis Result UI:**
   - Display all relevant info: disease, remedies, prevention, confidence.
   - Animate and style results for clarity.
5. **AI Chatbot:**
   - Integrate Gemini API or fallback to simulated responses.
   - Ensure natural, helpful conversation flow.
6. **Plant Care Reminders:**
   - Allow users to schedule, enable, disable, and delete reminders.
   - Use local notifications for alerts.
7. **Localization:**
   - Support multiple languages with easy extensibility.
   - Persist user language choice.
8. **Modern Theming:**
   - Use Google Fonts, Material 3, and smooth animations.
9. **Code Modularization:**
   - Organize code for maintainability and extensibility.
10. **Testing & Bug Fixes:**
    - Write widget/unit tests, perform manual QA, fix bugs.
11. **Integrate Real ML Models:**
    - Replace simulated diagnosis with TFLite or other on-device models.
    - Optimize for speed and accuracy.
12. **Expand Disease Database:**
    - Add more plant species, diseases, and remedies.
    - Update UI and logic as needed.
13. **Offline Mode:**
    - Ensure core features work without internet.
    - Cache models and data locally.
14. **Cloud Sync & Accounts:**
    - Add user authentication and cloud backup for reminders and preferences.
15. **Accessibility & UX Polish:**
    - Add more languages, improve accessibility, test on more devices.
16. **Production Release:**
    - Prepare for app store submission, finalize branding, legal, and marketing materials.

---

## Features

- **Leaf Scanning & Diagnosis:**
  - Capture or upload a photo of a plant leaf.
  - AI analyzes the image and identifies possible diseases or confirms plant health.
  - Provides a confidence score, disease description, remedies, and prevention tips.

- **AI Chatbot:**
  - Chat with an AI-powered plant doctor for personalized advice, care instructions, and gardening tips.
  - Uses Google Gemini API (can be swapped for other LLMs).

- **Plant Care Reminders:**
  - Schedule daily reminders for watering, fertilizing, or other plant care tasks.
  - Local notifications ensure you never miss a plant care routine.

- **Multilingual Support:**
  - App available in English, Hindi, and Marathi.
  - Easily extensible to more languages via JSON locale files.

- **Modern UI/UX:**
  - Clean, animated interface with Google Fonts and Material 3 design.
  - Theming and accessibility in mind.

---

## Project Structure

```
lib/
├── main.dart                  # App entry point, theme, localization, routing
├── models/                    # Data models (DiagnosisResult, PlantReminder, LanguageModel)
├── screens/                   # UI screens (Home, Camera, Diagnosis, Chat, Reminders, Settings, Splash, Login)
├── services/                  # Business logic (Diagnosis, Chat, Notifications)
├── utils/                     # Localization helpers
assets/
├── images/                    # App images and icons
├── ml_models/                 # (Reserved for ML models, currently simulated)
├── locales/                   # Localization JSON files (en, hi, mr)
```

---

## Technical Details

### Diagnosis Workflow
- **Image Capture:** Uses device camera or gallery (camera, image_picker).
- **Diagnosis:**
  - Simulated AI model randomly selects a disease or healthy status for demonstration.
  - Returns disease name, description, remedies, prevention tips, and confidence score.
  - Easily upgradable to use real TFLite models (see `assets/ml_models/`).

### AI Chatbot
- **Backend:** Uses Google Gemini API for natural language responses.
- **Fallback:** Simulated responses for plant care, disease, and fertilizer queries.
- **Integration:** Modular service, can be swapped for other APIs or local models.

### Plant Care Reminders
- **Scheduling:** Users can add, enable/disable, and delete reminders for plant care tasks.
- **Notifications:** Uses `flutter_local_notifications` and timezone support for accurate alerts.

### Localization
- **Languages:** English, Hindi, Marathi (add more via `assets/locales/`).
- **Persistence:** User's language choice is saved with `shared_preferences`.

### Dependencies
- Flutter, Dart, Provider, Camera, Image Picker, TFLite Flutter, HTTP, Shared Preferences, Local Notifications, Google Fonts, Firebase (core/auth/firestore), and more (see `pubspec.yaml`).

---

## Getting Started

### Prerequisites
- Flutter SDK (2.17.0 or later)
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

---

## Future Improvements
- Integrate real on-device TFLite models for diagnosis
- Expand disease and plant species database
- Add offline mode for diagnosis and chat
- Cloud sync for reminders and user data
- More languages and accessibility features

---

## License
MIT License. See LICENSE file for details.

## Acknowledgments
- Plant Village Dataset (for model training)
- TensorFlow, Google Gemini, Flutter team
- Open source contributors
