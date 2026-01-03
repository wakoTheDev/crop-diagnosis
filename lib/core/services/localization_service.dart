import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalizationService extends ChangeNotifier {
  Locale _locale = const Locale('en');
  
  Locale get locale => _locale;
  
  Future<void> loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('language') ?? 'en';
    _locale = Locale(languageCode);
    notifyListeners();
  }
  
  Future<void> setLocale(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', languageCode);
    _locale = Locale(languageCode);
    notifyListeners();
  }
  
  String translate(String key) {
    return _translations[_locale.languageCode]?[key] ?? key;
  }
  
  static const Map<String, Map<String, String>> _translations = {
    'en': {
      'app_name': 'Crop Diagnostic',
      'welcome': 'Welcome',
      'get_started': 'Get Started',
      'sign_in': 'Sign In',
      'sign_up': 'Sign Up',
      'chat': 'Chat',
      'diagnose': 'Diagnose',
      'market': 'Market',
      'community': 'Community',
      'profile': 'Profile',
    },
    'sw': {
      'app_name': 'Uchunguzi wa Mazao',
      'welcome': 'Karibu',
      'get_started': 'Anza',
      'sign_in': 'Ingia',
      'sign_up': 'Jisajili',
      'chat': 'Mazungumzo',
      'diagnose': 'Chunguza',
      'market': 'Soko',
      'community': 'Jamii',
      'profile': 'Wasifu',
    },
    'ki': {
      'app_name': 'Ũthondeki wa Mbeũ',
      'welcome': 'Ũkena',
      'get_started': 'Ambĩrĩria',
      'sign_in': 'Toonya',
      'sign_up': 'Ĩyandĩkithie',
      'chat': 'Mĩario',
      'diagnose': 'Thondeka',
      'market': 'Ndũnyũ',
      'community': 'Kĩama',
      'profile': 'Ũhoro waku',
    },
  };
}
