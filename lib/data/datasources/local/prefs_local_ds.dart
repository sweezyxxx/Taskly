import 'package:shared_preferences/shared_preferences.dart';

abstract class PrefsLocalDataSource {
  Future<bool> getThemeMode(); // true for dark, false for light
  Future<void> setThemeMode(bool isDark);
  Future<String> getUsername();
  Future<void> setUsername(String name);
}

class PrefsLocalDataSourceImpl implements PrefsLocalDataSource {
  final SharedPreferences prefs;

  PrefsLocalDataSourceImpl({required this.prefs});

  static const _kThemeMode = 'theme_mode';
  static const _kUsername = 'username';

  @override
  Future<bool> getThemeMode() async {
    return prefs.getBool(_kThemeMode) ?? false;
  }

  @override
  Future<void> setThemeMode(bool isDark) async {
    await prefs.setBool(_kThemeMode, isDark);
  }

  @override
  Future<String> getUsername() async {
    return prefs.getString(_kUsername) ?? 'User';
  }

  @override
  Future<void> setUsername(String name) async {
    await prefs.setString(_kUsername, name);
  }
}
