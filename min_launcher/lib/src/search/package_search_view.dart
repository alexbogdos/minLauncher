import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../settings/settings_view.dart';
import 'package_search_controller.dart';

/// Search View. Search for application to launch.
class PackageSearchView extends StatelessWidget {
  const PackageSearchView({
    super.key,
    required this.controller,
    this.useIcons = false,
  });

  static const routeName = '/';
  final PackageSearchController controller;
  final bool useIcons;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      key: const ValueKey("SearchFutureBuilder"),
      future: controller.loadPackages(),
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [const CircularProgressIndicator(),
              const SizedBox(height: 8),
              Text(AppLocalizations.of(context)!.errorLoadingPackages)],
            ),
          );
        }
        return Scaffold(
          appBar: AppBar(
            title: Text(AppLocalizations.of(context)!.appTitle),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  // Navigate to the settings page. If the user leaves and returns
                  // to the app after it has been killed while running in the
                  // background, the navigation stack is restored.
                  Navigator.restorablePushNamed(
                      context, SettingsView.routeName);
                },
              ),
            ],
          ),
          body: Container(
            color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.3),
            child: PackageSearchView(controller: controller),
          ),
        );
      },
    );
  }
}

class PackagesListView extends StatelessWidget {
  const PackagesListView({super.key, required this.controller});

  final PackageSearchController controller;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      // Providing a restorationId allows the ListView to restore the
      // scroll position when a user leaves and returns to the app after it
      // has been killed while running in the background.
      restorationId: 'sampleItemListView',
      itemCount: controller.packages.length,
      itemBuilder: (BuildContext context, int index) {
        final package = controller.packages[index];

        return ListTile(
            title: Text(
                "${package.name}, ${package.score ?? 0}, ${package.lastAccessed != null ? '${Duration(milliseconds: package.lastAccessedDiff).inMinutes}"' : '-'}"),
            leading: package.hasIcon
                ? CircleAvatar(
                    // Display the Flutter Logo image asset.
                    foregroundImage:
                        Image.memory(package.icon!, width: 32, height: 32)
                            .image,
                  )
                : null,
            onTap: () {
              // Navigate to the details page. If the user leaves and returns to
              // the app after it has been killed while running in the
              // background, the navigation stack is restored.
              controller.launchPackage(package.packageName);
            });
      },
    );
  }
}
