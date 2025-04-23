import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/language_model.dart';
import 'screens/home_screen.dart';
import 'screens/splash_screen.dart';
import 'utils/app_localization.dart';
import 'screens/reminder_screen.dart';
import 'services/basic_notification.dart';
import 'services/scheduled_notification_service.dart';

// App color scheme
class AppColors {
  static const Color primaryGreen = Color(0xFF1E5631); // Royal green
  static const Color lightGreen = Color(0xFF3A8651);
  static const Color beige = Color(0xFFF5F2E9);
  static const Color darkBeige = Color(0xFFE8E2D5);
  static const Color textDark = Color(0xFF2D3A35);
  static const Color textLight = Color(0xFF6C7D73);
}
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    final prefs = await SharedPreferences.getInstance();
    final String languageCode = prefs.getString('language_code') ?? 'en';

    // Initialize notification services
    try {
      await BasicNotification.initialize();
      await ScheduledNotificationService().initialize();
      print("Notification services initialized successfully");
    } catch (e) {
      print("Failed to initialize notification services: $e");
      // Continue even if notification initialization fails
    }

    runApp(
      ChangeNotifierProvider(
        create: (_) => LanguageModel(languageCode),
        child: const MyApp(),
      ),
    );
  } catch (e) {
    print("Error during app initialization: $e");
    // Fallback initialization
    runApp(
      ChangeNotifierProvider(
        create: (_) => LanguageModel('en'),
        child: const MyApp(),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final languageModel = Provider.of<LanguageModel>(context);

    // Define base text theme using Google Fonts
    final baseTextTheme = GoogleFonts.poppinsTextTheme(
      Theme.of(context).textTheme,
    );

    return MaterialApp(
      title: 'LeafLens - Plant Doctor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primaryGreen,
        scaffoldBackgroundColor: AppColors.beige,
        colorScheme: ColorScheme.light(
          primary: AppColors.primaryGreen,
          secondary: AppColors.lightGreen,
          surface: AppColors.beige,
          background: AppColors.beige,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: AppColors.textDark,
          onBackground: AppColors.textDark,
          error: Colors.redAccent,
          onError: Colors.white,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: baseTextTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryGreen,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: baseTextTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primaryGreen,
            side: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: baseTextTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        cardTheme: CardTheme(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 3,
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.darkBeige,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: AppColors.primaryGreen,
              width: 1.5,
            ),
          ),
          hintStyle: baseTextTheme.bodyLarge?.copyWith(
            color: AppColors.textLight,
          ),
        ),
        textTheme: baseTextTheme.copyWith(
          bodyLarge: baseTextTheme.bodyLarge?.copyWith(
            color: AppColors.textDark,
            fontSize: 16,
          ),
          bodyMedium: baseTextTheme.bodyMedium?.copyWith(
            color: AppColors.textLight,
            fontSize: 14,
          ),
          titleLarge: baseTextTheme.titleLarge?.copyWith(
            color: AppColors.textDark,
            fontWeight: FontWeight.w600,
          ),
          titleMedium: baseTextTheme.titleMedium?.copyWith(
            color: AppColors.textDark,
            fontWeight: FontWeight.w500,
          ),
          labelLarge: baseTextTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        useMaterial3: true,
      ),
      locale: Locale(languageModel.currentLanguage),
      supportedLocales: const [
        Locale('en', ''), // English
        Locale('hi', ''), // Hindi
        Locale('mr', ''), // Marathi
      ],
      localizationsDelegates: const [
        AppLocalization.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const SplashScreen(),
    );
  }
}
