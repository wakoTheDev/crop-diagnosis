import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:firebase_core/firebase_core.dart';

import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'core/services/navigation_service.dart';
import 'core/services/localization_service.dart';
import 'providers/app_providers.dart';
import 'features/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load();

  // Firebase disabled for now - configure Firebase web settings to enable
  // try {
  //   await Firebase.initializeApp();
  // } catch (e) {
  //   debugPrint('Firebase initialization skipped: $e');
  // }

  // Initialize Hive for local storage
  await Hive.initFlutter();
  await Hive.openBox(AppConstants.settingsBox);
  await Hive.openBox(AppConstants.cacheBox);

  runApp(const CropDiagnosticApp());
}

class CropDiagnosticApp extends StatelessWidget {
  const CropDiagnosticApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: AppProviders.providers,
      child: Consumer<LocalizationService>(
        builder: (context, localization, _) {
          return MaterialApp(
            title: 'Crop Diagnostic',
            debugShowCheckedModeBanner: false,

            // Theme
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,

            // Localization
            locale: localization.locale,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', ''), // English
              Locale('sw', ''), // Swahili
              Locale('ki', ''), // Kikuyu
            ],

            // Navigation
            navigatorKey: NavigationService.navigatorKey,
            onGenerateRoute: NavigationService.generateRoute,
            initialRoute: '/',

            // Home
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
