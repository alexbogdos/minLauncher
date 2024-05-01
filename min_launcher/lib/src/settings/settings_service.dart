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
  Future<bool> useIcons(bool defaultValue) async => await _get<bool>('use_icons', defaultValue);
  Future<void> updateUseIcons(bool newUseIcons) async => await _update('use_icons', newUseIcons);

  Future<Locale> locale(Locale defaultValue) async => await _get<Locale>('locale', defaultValue);
  Future<void> updateLocale(Locale newLocale) async => await _update('locale', newLocale);

  /// Loads the User's preferred ThemeMode from local or remote storage.
  Future<ThemeMode> themeMode(ThemeMode defaultValue) async => await _get<ThemeMode>('theme_mode', defaultValue);

  /// Persists the user's preferred ThemeMode to local or remote storage.
  Future<void> updateThemeMode(ThemeMode newThemeMode) async => await _update('theme_mode', newThemeMode);

  Future<ThemeData> themeData() async => ThemeData.from(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orangeAccent),
        useMaterial3: true,
      );


  Future<T> _get<T>(String key, T defaultValue) async {
    T? value = await _database.getValue<T?>(key);
    if (value == null) {
      await _database.insert(key, defaultValue);
      return defaultValue;
    }
    return value;
  }

  Future<void> _update<T>(String key, T newValue) async {
    await _database.update(key, newValue);
  }
}
