import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../settings/settings_view.dart';
import 'package_search_controller.dart';
import 'package_info.dart';
import 'search_list_view.dart';

/// Search View. Search for application to launch.
class PackageSearchView extends StatefulWidget {
  const PackageSearchView({
    super.key,
    required this.controller,
    this.useIcons = false,
  });

  static const routeName = '/';
  final PackageSearchController controller;
  final bool useIcons;

  @override
  State<PackageSearchView> createState() => _PackageSearchViewState();
}

class _PackageSearchViewState extends State<PackageSearchView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      restorationId: 'packageSearchView',
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.searchTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.restorablePushNamed(context, SettingsView.routeName);
            },
          ),
        ],
      ),
      body: FutureBuilder<List<PackageInfo>>(
        future: widget.controller.loadPackages(useIcons: widget.useIcons),
        builder:
            (BuildContext context, AsyncSnapshot<List<PackageInfo>> snapshot) {
          List<Widget> children;
          if (snapshot.hasData) {
            return SearchListView(controller: widget.controller);
          } else if (snapshot.hasError) {
            return Text(AppLocalizations.of(context)!.errorLoadingPackages);
          } else {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const CircularProgressIndicator(),
                  const SizedBox(height: 8),
                  Text(AppLocalizations.of(context)!.loadingPackages)
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
