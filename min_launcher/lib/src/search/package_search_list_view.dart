import 'package:flutter/material.dart';

import '../settings/settings_controller.dart';
import 'package_search_controller.dart';

class PackageSearchListView extends StatefulWidget {
  const PackageSearchListView({
    super.key,
    required this.settings,
    required this.controller,
  });

  final SettingsController settings;
  final PackageSearchController controller;

  @override
  State<PackageSearchListView> createState() => _PackageSearchListViewState();
}

class _PackageSearchListViewState extends State<PackageSearchListView> {
  int _selected = -1;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: widget.controller.reload,
      child: ListView.builder(
        restorationId: 'packageSearchViewListView',
        itemCount: widget.controller.packages.length,
        itemBuilder: (BuildContext context, int index) {
          final package = widget.controller.packages[index];

          return ListTile(
            visualDensity: VisualDensity.compact,
            selected: _selected == index,
            title: Text(
              "${package.name}, ${package.score ?? 0}, ${package.lastAccessed != null ? '${Duration(milliseconds: package.lastAccessedDiff).inMinutes}"' : '-'}",
              textAlign: widget.settings.appsAlign,
            ),
            leading: widget.settings.useIcons && package.hasIcon
                ? CircleAvatar(
                    // Display the Flutter Logo image asset.
                    foregroundImage:
                        Image.memory(package.icon!, width: 32, height: 32).image,
                  )
                : null,
            onTap: () {
              _selected = -1;
              widget.controller.launchPackage(package.packageName);
            },
            onLongPress: () {
              setState(() {
                _selected = index;
              });
            },
          );
        },
      ),
    );
  }
}
