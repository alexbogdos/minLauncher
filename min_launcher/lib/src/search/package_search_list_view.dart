import 'package:flutter/material.dart';

import '../settings/settings_controller.dart';
import 'package_search_controller.dart';
import 'package_info.dart';

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
          widget.controller.focusIfAtTop();
        }
        return false;
      },

      // Due to an undefined bug with ListView the GestureDector
      // detects only when the list's height is smaller than the
      // screen's height. For that we use the NotificationListener
      // above to detect swipes when list's height > screen's height.
      // 
      // The focusIfAtTop() can not be run simultaniously meaning that
      // when the list's height <= screen's height it doesn't matter
      // which one detects the gesture.
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onVerticalDragUpdate: (details) {

          int sensitivity = 8;
          // Swipe down
          if (details.delta.dy > sensitivity) {
            widget.controller.focusIfAtTop();
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
