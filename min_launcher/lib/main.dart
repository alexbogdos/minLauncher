import 'package:flutter/material.dart';


import 'src/app.dart';
import 'src/settings/settings_controller.dart';
import 'src/settings/settings_service.dart';
import 'src/search/package_search_controller.dart';
import 'src/search/package_search_service.dart';

void main() async {
  // Make sure the app is initialized since code is been run
  // before the runApp function.
  WidgetsFlutterBinding.ensureInitialized();

  // Set up the SearchController
  final searchController = PackageSearchController(PackageSearchService());

  // Initialize the SearchController
  await searchController.init();

  // Set up the SettingsController, which will glue user settings to multiple
  // Flutter Widgets.
  final settingsController = SettingsController(SettingsService(), searchController.requestLoad);

  // Load the user's preferred theme while the splash screen is displayed.
  // This prevents a sudden theme change when the app is first displayed.
  await settingsController.loadSettings();

  // Run the app and pass in the SettingsController. The app listens to the
  // SettingsController for changes, then passes it further down to the
  // SettingsView.
  runApp(MyApp(
    settingsController: settingsController,
    searchController: searchController,
  ));
}
