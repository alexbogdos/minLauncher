import 'package:flutter/material.dart';
import 'package:min_launcher/src/search/package_info.dart';

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

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      // When the user scrolls
      onNotification: (scrollNotification) {
        // Is in a scroll action
        if (scrollNotification is ScrollUpdateNotification) {
          widget.controller.unfocus();
        }
        // Just started scrolling
        else if (scrollNotification is ScrollStartNotification) {
          if (widget.controller.atListTop()) widget.controller.resetAndFocus(focus: true);
        }
        return false;
      },
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onVerticalDragUpdate: (details) {
          int sensitivity = 8;
          // Swipe down
          if (details.delta.dy > sensitivity) {
            if (widget.controller.atListTop()) {
              widget.controller.resetAndFocus(focus: true, clear: false);
            }
          }
        },
        child: ListView.builder(
          restorationId: 'packageSearchViewListView',
          controller: widget.controller.scrollController,
          itemCount: widget.controller.packages.length,
          itemBuilder: (BuildContext context, int index) {
            final PackageInfo package = widget.controller.packages[index];
            return ListTile(
              visualDensity: VisualDensity.compact,
              title: Text(
                "${package.name}",
                textAlign: widget.settings.appsAlign,
              ),
              leading: widget.settings.useIcons && package.hasIcon
                  ? CircleAvatar(
                // Display the Flutter Logo image asset.
                foregroundImage:
                Image.memory(package.icon!, width: 32, height: 32).image,
              )
                  : null,
              onTap: () => widget.controller.launchPackage(package.packageName),
              onLongPress: () => widget.controller.openPackageSettings(package.packageName),
            );
          },
        ),
      ),
    );
  }
}
