import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:min_launcher/src/settings/settings_controller.dart';

import '../settings/settings_view.dart';
import 'package_search_controller.dart';
import 'package_info.dart';
import 'package_search_list_view.dart';

/// Search View. Search for application to launch.
class PackageSearchView extends StatefulWidget {
  const PackageSearchView({
    super.key,
    required this.settings,
    required this.controller,
    this.useIcons = false,
  });

  static const routeName = '/';
  final SettingsController settings;
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
        body: ListenableBuilder(
            listenable: widget.controller,
            builder: (BuildContext context, Widget? child) {
              return FutureBuilder<List<PackageInfo>>(
                future:
                    widget.controller.loadPackages(useIcons: widget.useIcons),
                builder: (BuildContext context,
                    AsyncSnapshot<List<PackageInfo>> snapshot) {
                  if (snapshot.hasData) {
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24,),
                          child: TextField(
                            autofocus: true,
                            showCursor: false,
                            controller: widget.controller.textEditingController,
                            textAlign: widget.settings.appsAlign,
                            style:  Theme.of(context).textTheme.titleMedium,
                            decoration: InputDecoration(
                              hintText: AppLocalizations.of(context)!.searchTitle,
                            ),
                            onChanged: widget.controller.search,
                            onEditingComplete: widget.controller.launchFirst,
                          ),
                        ),
                        Expanded(
                          child: PackageSearchListView(
                            settings: widget.settings,
                            controller: widget.controller,
                          ),
                        ),
                      ],
                    );
                  } else if (snapshot.hasError) {
                    debugPrintStack(
                        label: snapshot.error.toString(),
                        stackTrace: snapshot.stackTrace);
                    return Center(
                      child: Text(
                        AppLocalizations.of(context)!
                            .searchErrorLoadingPackages,
                      ),
                    );
                  } else {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const CircularProgressIndicator(),
                          const SizedBox(height: 8),
                          Text(AppLocalizations.of(context)!
                              .searchLoadingPackages)
                        ],
                      ),
                    );
                  }
                },
              );
            }));
  }
}
