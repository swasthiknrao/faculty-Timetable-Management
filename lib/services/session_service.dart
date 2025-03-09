import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static const String _isLoggedInKey = 'isLoggedIn';
  static const String _userTypeKey = 'userType';
  static const String _usernameKey = 'username';

  static Future<void> saveLoginSession(String userType, String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, true);
    await prefs.setString(_userTypeKey, userType);
    await prefs.setString(_usernameKey, username);
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  static Future<Map<String, String?>> getSessionInfo() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'userType': prefs.getString(_userTypeKey),
      'username': prefs.getString(_usernameKey),
    };
  }
}
