import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'settings_controller.dart';
import 'settings_entry.dart';

/// Displays the various settings that can be customized by the user.
///
/// When a user changes a setting, the SettingsController is updated and
/// Widgets that listen to the SettingsController are rebuilt.
class SettingsView extends StatelessWidget {
  const SettingsView({super.key, required this.controller});

  static const routeName = '/settings';

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settingsTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
        child: Column(
          children: [
            SettingsEntry(
              title: AppLocalizations.of(context)!.settingsToggleThemeModeTitle,
              child: DropdownButton<ThemeMode>(
                // Read the selected themeMode from the controller
                value: controller.themeMode,
                // Call the updateThemeMode method any time the user selects a theme.
                onChanged: controller.updateThemeMode,
                items: [
                  DropdownMenuItem(
                    value: ThemeMode.system,
                    child: Text(
                      AppLocalizations.of(context)!
                          .settingsToggleThemeModeValueSystem,
                    ),
                  ),
                  DropdownMenuItem(
                    value: ThemeMode.light,
                    child: Text(
                      AppLocalizations.of(context)!
                          .settingsToggleThemeModeValueLight,
                    ),
                  ),
                  DropdownMenuItem(
                    value: ThemeMode.dark,
                    child: Text(
                      AppLocalizations.of(context)!
                          .settingsToggleThemeModeValueDark,
                    ),
                  )
                ],
              ),
            ),
            SettingsEntry(
              title: AppLocalizations.of(context)!.settingsToggleLocaleTitle,
              child: DropdownButton<Locale>(
                // Read the selected themeMode from the controller
                value: controller.locale,
                // Call the updateThemeMode method any time the user selects a theme.
                onChanged: controller.updateLocale,
                items: [
                  DropdownMenuItem(
                    value: const Locale('en', ''),
                    child: Text(
                      AppLocalizations.of(context)!.settingsToggleLocaleValueEn,
                    ),
                  ),
                  DropdownMenuItem(
                    value: const Locale('el', ''),
                    child: Text(
                      AppLocalizations.of(context)!.settingsToggleLocaleValueEl,
                    ),
                  )
                ],
              ),
            ),
            SettingsEntry(
              title: AppLocalizations.of(context)!.settingsToggleUseIconsTitle,
              child: Switch(
                value: controller.useIcons,
                onChanged: controller.updateUseIcons,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
