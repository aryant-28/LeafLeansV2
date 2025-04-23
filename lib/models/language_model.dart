import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageModel extends ChangeNotifier {
  String _currentLanguage;

  LanguageModel(this._currentLanguage);

  String get currentLanguage => _currentLanguage;

  Future<void> changeLanguage(String languageCode) async {
    if (_currentLanguage != languageCode) {
      _currentLanguage = languageCode;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('language_code', languageCode);
      notifyListeners();
    }
  }
} 