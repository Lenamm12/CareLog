import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeNotifier with ChangeNotifier {
  double _fontSize = 16.0;
  String _colorScheme = 'Pink';
  bool _isDarkMode = false;

  double get fontSize => _fontSize;
  String get colorScheme => _colorScheme;
  bool get isDarkMode => _isDarkMode;

  ThemeNotifier() {
    _loadTheme();
  }

  ThemeData get currentTheme {
    ThemeData baseTheme = _isDarkMode ? ThemeData.dark() : ThemeData.light();
    Color primaryColor = _getColor();
    Color secondaryColor = _getSecondaryColor();

    TextTheme baseTextTheme = const TextTheme(
      displayLarge: TextStyle(fontSize: 57.0),
      displayMedium: TextStyle(fontSize: 45.0),
      displaySmall: TextStyle(fontSize: 36.0),
      headlineLarge: TextStyle(fontSize: 32.0),
      headlineMedium: TextStyle(fontSize: 28.0),
      headlineSmall: TextStyle(fontSize: 24.0),
      titleLarge: TextStyle(fontSize: 22.0),
      titleMedium: TextStyle(fontSize: 16.0),
      titleSmall: TextStyle(fontSize: 14.0),
      bodyLarge: TextStyle(fontSize: 16.0),
      bodyMedium: TextStyle(fontSize: 14.0),
      bodySmall: TextStyle(fontSize: 12.0),
      labelLarge: TextStyle(fontSize: 14.0),
      labelMedium: TextStyle(fontSize: 12.0),
      labelSmall: TextStyle(fontSize: 11.0),
    );

    TextTheme newTextTheme = baseTheme.textTheme
        .merge(baseTextTheme)
        .apply(fontSizeFactor: _fontSize / 16.0);

    return baseTheme.copyWith(
      primaryColor: primaryColor,
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: secondaryColor,
        foregroundColor: Colors.white,
      ),
      buttonTheme: baseTheme.buttonTheme.copyWith(buttonColor: primaryColor),
      textTheme: newTextTheme,
      colorScheme:
          baseTheme.colorScheme.copyWith(primary: primaryColor, secondary: secondaryColor),
    );
  }

  void setFontSize(double fontSize) async {
    _fontSize = fontSize;
    notifyListeners();
    _saveTheme();
  }

  void setColorScheme(String colorScheme) async {
    _colorScheme = colorScheme;
    notifyListeners();
    _saveTheme();
  }

  void setDarkMode(bool isDarkMode) async {
    _isDarkMode = isDarkMode;
    notifyListeners();
    _saveTheme();
  }

  Color _getColor() {
    if (isDarkMode) {
      switch (_colorScheme) {
        case 'Blue':
          return Colors.blue[800]!;
        case 'Beige':
          return Colors.brown;
        case 'Purple':
          return Colors.purple;
        case 'Pink':
        default:
          return Colors.pink;
      }
    } else {
      switch (_colorScheme) {
        case 'Blue':
          return Colors.blue;
        case 'Beige':
          return Colors.brown[300]!;
        case 'Purple':
          return Colors.purple[300]!;
        case 'Pink':
        default:
          return Colors.pink[300]!;
      }
    }
  }

  Color _getSecondaryColor() {
    if (isDarkMode) {
      switch (_colorScheme) {
        case 'Blue':
          return Colors.blue;
        case 'Beige':
          return Colors.brown[300]!;
        case 'Purple':
          return Colors.purple[300]!;
        case 'Pink':
        default:
          return Colors.pink[300]!;
      }
    } else {
      switch (_colorScheme) {
        case 'Blue':
          return Colors.blue[800]!;
        case 'Beige':
          return Colors.brown[400]!;
        case 'Purple':
          return Colors.purple[700]!;
        case 'Pink':
        default:
          return Colors.pink[700]!;
      }
    }
  }

  _saveTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setDouble('fontSize', _fontSize);
    prefs.setString('colorScheme', _colorScheme);
    prefs.setBool('isDarkMode', _isDarkMode);
  }

  _loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _fontSize = prefs.getDouble('fontSize') ?? 16.0;
    _colorScheme = prefs.getString('colorScheme') ?? 'Pink';
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    notifyListeners();
  }
}
