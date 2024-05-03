import 'package:flutter/material.dart';

import 'settings_service.dart';

/// A class that many Widgets can interact with to read user settings, update
/// user settings, or listen to user settings changes.
///
/// Controllers glue Data Services to Flutter Widgets. The SettingsController
/// uses the SettingsService to store and retrieve user settings.
class SettingsController with ChangeNotifier {
  SettingsController(this._settingsService, this.requestLoad);

  // Make SettingsService a private variable so it is not used directly.
  final SettingsService _settingsService;

  /// Currently passed by the PackageSearchController. When called 
  /// requests to load the packages.
  final void Function()? requestLoad;

  /// Load the user's settings from the SettingsService. It may load from a
  /// local database or the internet. The controller only knows it can load the
  /// settings from the service.
  Future<void> loadSettings() async {
    await _settingsService.init();

    _themeMode = await _settingsService.themeMode();
    _themeData = await _settingsService.themeData();
    _useIcons = await _settingsService.useIcons();
    _locale = await _settingsService.locale();
    _appsAlign = await _settingsService.appsAlign();

    if (requestLoad != null) requestLoad!();

    // Important! Inform listeners a change has occurred.
    notifyListeners();
  }

  // Make the settings private variables so they are not updated directly without
  // also persisting the changes with the SettingsService.
  late ThemeMode _themeMode;
  late ThemeData _themeData;
  late bool _useIcons;
  late Locale _locale;
  late TextAlign _appsAlign;

  // Allow Widgets to read the user's preferred Data.
  ThemeMode get themeMode => _themeMode;
  ThemeData get themeData => _themeData;
  bool get useIcons => _useIcons;
  Locale get locale => _locale;
  TextAlign get appsAlign => _appsAlign;

  /// Update and persist the Use Icons based on the user's selection.
  Future<void> updateUseIcons(bool? newUseIcons) async {
    if (newUseIcons == null) return;
    if (newUseIcons == _useIcons) return;
    _useIcons = newUseIcons;
    notifyListeners();
    await _settingsService.updateUseIcons(newUseIcons);
  }

  /// Update and persist the Locale based on the user's selection.
  Future<void> updateLocale(Locale? newLocale) async {
    if (newLocale == null) return;
    if (newLocale == _locale) return;
    _locale = newLocale;
    notifyListeners();
    await _settingsService.updateLocale(newLocale);
  }

  /// Update and persist the Apps Align based on the user's selection.
  Future<void> updateAppsAlign(TextAlign? newAppsAlign) async {
    if (newAppsAlign == null) return;
    if (newAppsAlign == _appsAlign) return;
    _appsAlign = newAppsAlign;
    notifyListeners();
    await _settingsService.updateAppsAlign(newAppsAlign);
  }

  /// Update and persist the ThemeMode based on the user's selection.
  Future<void> updateThemeMode(ThemeMode? newThemeMode) async {
    if (newThemeMode == null) return;

    // Do not perform any work if new and old ThemeMode are identical
    if (newThemeMode == _themeMode) return;

    // Otherwise, store the new ThemeMode in memory
    _themeMode = newThemeMode;

    // Important! Inform listeners a change has occurred.
    notifyListeners();

    // Persist the changes to the local database SettingService.
    await _settingsService.updateThemeMode(newThemeMode);
  }
}
