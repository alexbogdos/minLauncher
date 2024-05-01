import 'package:flutter/material.dart';

import 'package_search_controller.dart';

class SearchListView extends StatelessWidget {
  const SearchListView({super.key, required this.controller});

  final PackageSearchController controller;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: controller.packages.length,
      itemBuilder: (BuildContext context, int index) {
        final package = controller.packages[index];

        return ListTile(
            title: Text(
              "${package.name}, ${package.score ?? 0}, ${package.lastAccessed != null ? '${Duration(milliseconds: package.lastAccessedDiff).inMinutes}"' : '-'}",
              textAlign: TextAlign.right, // TODO: Control from SettingsController
            ),
            leading: package.hasIcon
                ? CircleAvatar(
                    // Display the Flutter Logo image asset.
                    foregroundImage:
                        Image.memory(package.icon!, width: 32, height: 32)
                            .image,
                  )
                : null,
            onTap: () {
              controller.launchPackage(package.packageName);
            });
      },
    );
  }
}
