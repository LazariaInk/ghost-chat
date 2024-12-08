import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  static const String _themeModeKey = 'themeMode';

  static Future<void> setThemeMode(bool isDarkMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeModeKey, isDarkMode);
  }

  static Future<bool> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_themeModeKey) ?? false;
  }
}
