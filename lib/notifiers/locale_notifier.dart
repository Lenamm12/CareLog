import 'package:flutter/material.dart';
import 'package:carelog/services/settings_service.dart';

class LocaleNotifier extends ChangeNotifier {
  final SettingsService _settingsService = SettingsService();
  Locale _locale = const Locale('en', '');

  Locale get locale => _locale;

  Future<void> loadLocale() async {
    final localeString = await _settingsService.loadLocale();
    if (localeString != null) {
      _locale = Locale(localeString, '');
      notifyListeners();
    }
  }

  Future<void> setLocale(Locale newLocale) async {
    _locale = newLocale;
    await _settingsService.saveLocale(newLocale.languageCode);
    notifyListeners();
  }
}
