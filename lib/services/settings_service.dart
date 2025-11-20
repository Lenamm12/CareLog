import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const _themeKey = 'isDarkMode';
  static const _colorSchemeKey = 'colorScheme';
  static const _fontSizeKey = 'fontSize';
  static const _localeKey = 'locale';

  Future<void> saveTheme(bool isDarkMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, isDarkMode);
  }

  Future<bool> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_themeKey) ?? false;
  }

  Future<void> saveColorScheme(String colorScheme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_colorSchemeKey, colorScheme);
  }

  Future<String> loadColorScheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_colorSchemeKey) ?? 'Pink'; // Default color
  }

  Future<void> saveFontSize(double fontSize) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_fontSizeKey, fontSize);
  }

  Future<double> loadFontSize() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_fontSizeKey) ?? 16.0; // Default font size
  }

  Future<void> saveLocale(String locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale);
  }

  Future<String?> loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_localeKey);
  }
}
