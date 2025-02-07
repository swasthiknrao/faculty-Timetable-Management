import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;
  Color get backgroundColor =>
      _isDarkMode ? const Color.fromRGBO(24, 29, 32, 1) : Colors.white;

  ThemeData get theme => _isDarkMode ? _darkTheme : _lightTheme;

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

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}
