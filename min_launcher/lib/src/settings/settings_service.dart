import 'package:flutter/material.dart';

import 'settings_database.dart';

/// A service that stores and retrieves user settings.
///
/// By default, this class does not persist user settings. If you'd like to
/// persist the user settings locally, use the shared_preferences package. If
/// you'd like to store settings on a web server, use the http package.
class SettingsService {
  final SettingsDatabase _database = SettingsDatabase();

  Future<void> init() async {
    await _database.open();
  }

  /// Load app icons alongside app names
  Future<bool> useIcons() async {
    return (await _get('use_icons', 'false')) == 'true' ? true : false;
  }

  Future<void> updateUseIcons(bool newUseIcons) async {
    await _update('use_icons', newUseIcons ? 'true' : 'false');
  }

  Future<Locale> locale() async {
    switch (await _get('locale', 'en')) {
      case 'el':
        return const Locale('el', '');
      case 'en':
      default:
        return const Locale('en', '');
    }
  }

  Future<void> updateLocale(Locale newLocale) async {
    await _update('locale', newLocale.languageCode);
  }

  /// Loads the User's preferred ThemeMode from local or remote storage.
  Future<ThemeMode> themeMode() async {
    switch (await _get('theme_mode', 'system')) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  /// Persists the user's preferred ThemeMode to local or remote storage.
  Future<void> updateThemeMode(ThemeMode newThemeMode) async {
    await _update('theme_mode', newThemeMode.name.toLowerCase());
  }

  Future<ThemeData> themeData() async => ThemeData.from(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orangeAccent),
        useMaterial3: true,
      );

  Future<String> _get(String key, String defaultValue) async {
    String? value = await _database.getValue<String?>(key);
    if (value == null) {
      debugPrint("Default $key: $value");
      await _database.insert(key, defaultValue);
      return defaultValue;
    }
    debugPrint("Loaded $key: $value");
    return value;
  }

  Future<void> _update(String key, String newValue) async {
    debugPrint("Update $key: $newValue");
    await _database.update<String>(key, newValue);
  }
}
