import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class PrefsLocalDataSource {
  Future<bool> getThemeMode(); // true for dark, false for light
  Future<void> setThemeMode(bool isDark);
}

class PrefsLocalDataSourceImpl implements PrefsLocalDataSource {
  final SharedPreferences prefs;

  PrefsLocalDataSourceImpl({required this.prefs});

  static const _kThemeMode = 'theme_mode';

  @override
  Future<bool> getThemeMode() async {
    if (prefs.containsKey(_kThemeMode)) {
      return prefs.getBool(_kThemeMode)!;
    }
    // First launch: follow system theme
    final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
    return brightness == Brightness.dark;
  }

  @override
  Future<void> setThemeMode(bool isDark) async {
    await prefs.setBool(_kThemeMode, isDark);
  }

}
