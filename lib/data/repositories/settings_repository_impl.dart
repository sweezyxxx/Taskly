import '../../domain/repositories/settings_repository.dart';
import '../datasources/local/prefs_local_ds.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final PrefsLocalDataSource localDs;

  SettingsRepositoryImpl({required this.localDs});

  @override
  Future<bool> isDarkMode() => localDs.getThemeMode();

  @override
  Future<void> setDarkMode(bool isDark) => localDs.setThemeMode(isDark);

  @override
  Future<String> getUsername() => localDs.getUsername();

  @override
  Future<void> setUsername(String username) => localDs.setUsername(username);
}
