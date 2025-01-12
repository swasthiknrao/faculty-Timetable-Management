import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;
  static const String _themeKey = 'isDarkMode';

  ThemeProvider() {
    _loadTheme();
  }

  bool get isDarkMode => _isDarkMode;
  Color get backgroundColor =>
      _isDarkMode ? const Color.fromRGBO(24, 29, 32, 1) : Colors.white;

  ThemeData get theme => _isDarkMode ? _darkTheme : _lightTheme;

  Color get textColor =>
      _isDarkMode ? const Color.fromRGBO(159, 160, 162, 1) : Colors.black87;

  Color get accentColor => const Color.fromRGBO(153, 55, 30, 1);

  Color get cardColor =>
      _isDarkMode ? const Color.fromRGBO(34, 39, 42, 1) : Colors.white;

  static final _darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color.fromRGBO(24, 29, 32, 1),
    primaryColor: const Color.fromRGBO(153, 55, 30, 1),
    colorScheme: ColorScheme.dark(
      primary: const Color.fromRGBO(153, 55, 30, 1),
      secondary: Colors.grey[800]!,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color.fromRGBO(34, 39, 42, 1),
      elevation: 0,
    ),
    cardTheme: CardTheme(
      color: const Color.fromRGBO(34, 39, 42, 1),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );

  static final _lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.white,
    primaryColor: const Color.fromRGBO(153, 55, 30, 1),
    colorScheme: ColorScheme.light(
      primary: const Color.fromRGBO(153, 55, 30, 1),
      secondary: Colors.grey[200]!,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
    ),
    cardTheme: CardTheme(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );

  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isDarkMode = prefs.getBool(_themeKey) ?? false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading theme: $e');
    }
  }

  Future<void> toggleTheme() async {
    try {
      _isDarkMode = !_isDarkMode;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_themeKey, _isDarkMode);
      notifyListeners();
    } catch (e) {
      debugPrint('Error toggling theme: $e');
    }
  }
}
