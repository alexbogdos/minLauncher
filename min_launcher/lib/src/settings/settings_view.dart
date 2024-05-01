import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'settings_controller.dart';

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
        // Glue the SettingsController to the theme selection DropdownButton.
        //
        // When a user selects a theme from the dropdown list, the
        // SettingsController is updated, which rebuilds the MaterialApp.
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Theme mode:", style: Theme.of(context).textTheme.bodyLarge,),
                DropdownButton<ThemeMode>(
                  // Read the selected themeMode from the controller
                  value: controller.themeMode,
                  // Call the updateThemeMode method any time the user selects a theme.
                  onChanged: controller.updateThemeMode,
                  items: const [
                    DropdownMenuItem(
                      value: ThemeMode.system,
                      child: Text('System Theme'),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.light,
                      child: Text('Light Theme'),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.dark,
                      child: Text('Dark Theme'),
                    )
                  ],
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Locale:", style: Theme.of(context).textTheme.bodyLarge,),
                DropdownButton<Locale>(
                  // Read the selected themeMode from the controller
                  value: controller.locale,
                  // Call the updateThemeMode method any time the user selects a theme.
                  onChanged: controller.updateLocale,
                  items: const [
                    DropdownMenuItem(
                      value: Locale('en', ''),
                      child: Text("English"),
                    ),
                    DropdownMenuItem(
                      value: Locale('el', ''),
                      child: Text("Greek"),
                    )
                  ]
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Show app icons:", style: Theme.of(context).textTheme.bodyLarge,),
                Switch(value: controller.useIcons, onChanged: controller.updateUseIcons),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
