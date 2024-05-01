import 'package:flutter/material.dart';

import 'package_info.dart';
import 'package_search_service.dart';

class PackageSearchController with ChangeNotifier {
  PackageSearchController(this._searchService);

  final PackageSearchService _searchService;
  bool canLoad = true;

  List<PackageInfo> get packages => _searchService.packages;

  Future<void> init() async {
    await _searchService.initService();
  }

  void askToLoad() => canLoad = true;

  Future<List<PackageInfo>> loadPackages({bool useIcons = false}) async {
    if (!canLoad) return _searchService.packages;
    canLoad = false;
    debugPrint("Loading packages..");
    final List<PackageInfo> list = await _searchService.loadPackages(useIcons: useIcons);
    debugPrint("Finished. Packages loaded");
    notifyListeners();
    return list;
  }

  Future<void> launchPackage(String packageName) async {
    await _searchService.launchPackage(packageName);
    notifyListeners();
  }
}
