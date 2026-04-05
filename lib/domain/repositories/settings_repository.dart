abstract class SettingsRepository {
  Future<bool> isDarkMode();
  Future<void> setDarkMode(bool isDark);
}
