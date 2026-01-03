class AppConstants {
  // App Info
  static const String appName = 'Crop Diagnostic';
  static const String appVersion = '1.0.0';
  
  // Storage Keys
  static const String settingsBox = 'settings';
  static const String cacheBox = 'cache';
  static const String userBox = 'user';
  static const String chatBox = 'chat';
  static const String diagnosisBox = 'diagnosis';
  
  // Preferences Keys
  static const String keyFirstLaunch = 'first_launch';
  static const String keyLanguage = 'language';
  static const String keyThemeMode = 'theme_mode';
  static const String keyUserId = 'user_id';
  static const String keyUserToken = 'user_token';
  static const String keyOfflineMode = 'offline_mode';
  
  // API Configuration
  static const String baseUrl = 'https://api.cropdiagnostic.app/v1';
  static const String apiKey = 'YOUR_API_KEY_HERE';
  static const int connectionTimeout = 30000;
  static const int receiveTimeout = 30000;
  
  // ML Model Configuration
  static const String diseaseModelPath = 'assets/models/disease_detection.tflite';
  static const String labelPath = 'assets/models/labels.txt';
  static const int imageSize = 224;
  static const double confidenceThreshold = 0.7;
  
  // Chat Configuration
  static const int maxMessageLength = 1000;
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const int maxVoiceRecordingDuration = 300; // 5 minutes
  
  // Weather Configuration
  static const String weatherApiKey = 'YOUR_WEATHER_API_KEY';
  static const int weatherUpdateInterval = 3600; // 1 hour
  
  // Supported Languages
  static const List<String> supportedLanguages = [
    'en', // English
    'sw', // Swahili
    'ki', // Kikuyu
  ];
  
  // Supported Crops (partial list)
  static const List<String> supportedCrops = [
    'Maize',
    'Wheat',
    'Rice',
    'Beans',
    'Coffee',
    'Tea',
    'Tomato',
    'Potato',
    'Cassava',
    'Banana',
  ];
  
  // Disease Categories
  static const List<String> diseaseCategories = [
    'Fungal',
    'Bacterial',
    'Viral',
    'Pest',
    'Nutrient Deficiency',
    'Environmental',
  ];
  
  // Severity Levels
  static const List<String> severityLevels = [
    'Low',
    'Medium',
    'High',
    'Critical',
  ];
  
  // Market Price Update Interval
  static const int marketPriceUpdateInterval = 1800; // 30 minutes
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // File Paths
  static const String imagesPath = 'images';
  static const String voicesPath = 'voices';
  static const String documentsPath = 'documents';
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;
  
  // Colors (to be used in theme)
  static const int primaryColorValue = 0xFF4CAF50;
  static const int accentColorValue = 0xFF8BC34A;
  static const int errorColorValue = 0xFFF44336;
  static const int warningColorValue = 0xFFFF9800;
  static const int successColorValue = 0xFF4CAF50;
  
  // Expert Consultation
  static const int expertResponseTimeout = 300; // 5 minutes
  
  // Community
  static const int maxPostLength = 2000;
  static const int maxCommentsPerPost = 100;
}
