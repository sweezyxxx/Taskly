abstract class SettingsRepository {
  Future<bool> isDarkMode();
  Future<void> setDarkMode(bool isDark);
  Future<String> getUsername();
  Future<void> setUsername(String username);
}
