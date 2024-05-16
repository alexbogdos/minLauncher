import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'settings_controller.dart';
import 'widgets/settings_entries.dart';
import 'widgets/settings_category.dart';

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
        padding: const EdgeInsets.fromLTRB(16, 16, 20, 16),
        child: Column(
          children: [
            SettingsCategory(
              title: AppLocalizations.of(context)!.settingsCategoryGlobal,
            ),
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
                items: const [
                  DropdownMenuItem(
                    value: Locale('en', ''),
                    child: Text('English'),
                  ),
                  DropdownMenuItem(
                    value: Locale('el', ''),
                    child: Text('Ελληνικά'),
                  )
                ],
              ),
            ),
            SettingsCategory(
              title: AppLocalizations.of(context)!.settingsCategoryDrawer,
              topPadding: 24,
            ),
            SettingsEntry(
              title: AppLocalizations.of(context)!.settingsToggleUseIconsTitle,
              child: Switch(
                value: controller.useIcons,
                onChanged: controller.updateUseIcons,
              ),
            ),
            SettingsEntry(
              title: AppLocalizations.of(context)!.settingsToggleAppsAlignTitle,
              child: DropdownButton<TextAlign>(
                // Read the selected themeMode from the controller
                value: controller.appsAlign,
                // Call the updateThemeMode method any time the user selects a theme.
                onChanged: controller.updateAppsAlign,
                items: [
                  DropdownMenuItem(
                    value: TextAlign.left,
                    child: Text(AppLocalizations.of(context)!
                        .settingsToggleAppsAlignValueLeft),
                  ),
                  DropdownMenuItem(
                    value: TextAlign.center,
                    child: Text(AppLocalizations.of(context)!
                        .settingsToggleAppsAlignValueCenter),
                  ),
                  DropdownMenuItem(
                    value: TextAlign.right,
                    child: Text(AppLocalizations.of(context)!
                        .settingsToggleAppsAlignValueRight),
                  ),
                ],
              ),
            ),
            SettingsEntry(
              title:
                  AppLocalizations.of(context)!.settingsToggleSearchDepthTitle,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: () {
                      controller.updateSearchDepth(controller.searchDepth - 1);
                    },
                    style: TextButton.styleFrom(
                      minimumSize: const Size(30, 30),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text("-"),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    controller.searchDepth.toString(),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(width: 4),
                  TextButton(
                    onPressed: () {
                      controller.updateSearchDepth(controller.searchDepth + 1);
                    },
                    style: TextButton.styleFrom(
                      minimumSize: const Size(30, 30),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text("+"),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
