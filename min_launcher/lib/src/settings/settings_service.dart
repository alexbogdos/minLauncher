import 'package:flutter/material.dart';

import 'settings_database.dart';

/// A service that stores and retrieves user settings.
///
/// By default, this class does not persist user settings. If you'd like to
/// persist the user settings locally, use the shared_preferences package. If
/// you'd like to store settings on a web server, use the http package.
class SettingsService {
  final SettingsDatabase _database = SettingsDatabase();

  /// Initialize the SettingsService by opening the settings database.
  Future<void> init() async {
    await _database.open();
  }

  /// Loads the User's preferred Use Icons from the database.
  Future<bool> useIcons() async {
    return (await _get('use_icons', 'false')) == 'true' ? true : false;
  }

  /// Persists the user's preferred Use Icons to the database.
  Future<void> updateUseIcons(bool newUseIcons) async {
    await _update('use_icons', newUseIcons ? 'true' : 'false');
  }

  /// Loads the User's preferred Auto Launch from the database.
  Future<bool> autoLaunch() async {
    return (await _get('auto_launch', 'true')) == 'true' ? true : false;
  }

  /// Persists the user's preferred Auto Launch to the database.
  Future<void> updateAutoLaunch(bool newAutoLaunch) async {
    await _update('auto_launch', newAutoLaunch ? 'true' : 'false');
  }

  /// Loads the User's preferred Search Depth from the database.
  Future<int> searchDepth() async {
    return int.parse(await _get('search_depth', '0'));
  }

  /// Persists the user's preferred Search Depth to the database.
  Future<void> updateSearchDepth(int newSearchDepth) async {
    await _update('search_depth', newSearchDepth.toString());
  }

  /// Loads the User's preferred Locale from the database.
  Future<Locale> locale() async {
    switch (await _get('locale', 'en')) {
      case 'el':
        return const Locale('el', '');
      case 'en':
      default:
        return const Locale('en', '');
    }
  }

  /// Persists the user's preferred Locale to the database.
  Future<void> updateLocale(Locale newLocale) async {
    await _update('locale', newLocale.languageCode);
  }

  /// Apps Align: The alignment of applications names on the search view.
  /// Loads the User's preferred Apps Align from the database.
  Future<TextAlign> appsAlign() async {
    switch (await _get('apps_align', 'right')) {
      case 'left':
        return TextAlign.left;
      case 'center':
        return TextAlign.center;
      case 'right':
      default:
        return TextAlign.right;
    }
  }

  /// Persists the user's preferred Apps Align to the database.
  Future<void> updateAppsAlign(TextAlign newTextAlign) async {
    await _update('apps_align', newTextAlign.name.toLowerCase());
  }

  /// Loads the User's preferred ThemeMode from the database.
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

  /// Persists the user's preferred ThemeMode to the database.
  Future<void> updateThemeMode(ThemeMode newThemeMode) async {
    await _update('theme_mode', newThemeMode.name.toLowerCase());
  }

  /// Loads the User's preferred Theme Data from the database.
  Future<ThemeData> themeData() async => ThemeData.from(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orangeAccent),
        useMaterial3: true,
      );

  /// Retrieve a given setting's value from the database.
  /// If it doesn't exists the given defaultValue gets stored
  /// and returned.
  Future<String> _get(String key, String defaultValue) async {
    String? value = await _database.getValue(key);
    if (value == null) {
      await _database.insert(key, defaultValue);
      return defaultValue;
    }
    return value;
  }

  /// Update a given setting's value on the database
  Future<void> _update(String key, String newValue) async {
    await _database.update<String>(key, newValue);
  }
}
