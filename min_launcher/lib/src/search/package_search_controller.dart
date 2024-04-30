import 'package:flutter/material.dart';

import 'package_info.dart';
import 'package_search_service.dart';

class PackageSearchController with ChangeNotifier {
  PackageSearchController(this._searchService);

  final PackageSearchService _searchService;

  List<PackageInfo> get packages => _searchService.packages;

  Future<void> init() async {
    await _searchService.initService();
  }

  Future<bool> loadPackages({bool useIcons = false}) async {
    debugPrint("START");
    await _searchService.loadPackages(useIcons: useIcons);
    debugPrint("END");
    notifyListeners();
    return true;
  }

  Future<void> launchPackage(String packageName) async {
    await _searchService.launchPackage(packageName);
  }
}
