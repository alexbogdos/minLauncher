import 'package:flutter/material.dart';

/// A service that stores and retrieves user settings.
///
/// By default, this class does not persist user settings. If you'd like to
/// persist the user settings locally, use the shared_preferences package. If
/// you'd like to store settings on a web server, use the http package.
class SettingsService {
  /// Load app icons alongside app names
  Future<bool> useIcons() async => false;

  /// Persists the user's preferred ThemeMode to local or remote storage.
  Future<void> updateUseIcons(bool newUseIcons) async {

  }

  /// Load app icons alongside app names
  Future<Locale> locale() async => const Locale('en', '');

  /// Persists the user's preferred ThemeMode to local or remote storage.
  Future<void> updateLocale(Locale newLocale) async {

  }

  /// Loads the User's preferred ThemeMode from local or remote storage.
  Future<ThemeMode> themeMode() async => ThemeMode.system;

  /// Persists the user's preferred ThemeMode to local or remote storage.
  Future<void> updateThemeMode(ThemeMode theme) async {
    // Use the shared_preferences package to persist settings locally or the
    // http package to persist settings over the network.
  }

  Future<ThemeData> themeData() async => ThemeData.from(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.orangeAccent),
    useMaterial3: true,
  );
}
