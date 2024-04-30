import 'package:flutter/material.dart';

import 'package_info.dart';
import 'package_search_service.dart';

class PackageSearchController with ChangeNotifier {
  PackageSearchController(this._searchService);

  final PackageSearchService _searchService;

  List<PackageInfo> get packages => _searchService.packages;

  Future<void> loadInstalledPackages() async {
    await _searchService.loadPackages();

    notifyListeners();
  }

  Future<void> launchPackage(String packageName) async {
    await _searchService.launchPackage(packageName);
  }
}
