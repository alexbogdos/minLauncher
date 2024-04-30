import 'package:flutter/material.dart';

import 'package_info.dart';
import 'package_search_service.dart';

class PackageSearchController {
  PackageSearchController(this._searchService);

  final PackageSearchService _searchService;
  int loading = 0;

  List<PackageInfo> get packages => _searchService.packages;

  Future<void> init() async {
    await _searchService.initService();
  }

  Future<List<PackageInfo>> loadPackages({bool useIcons = false}) async {
    debugPrint("START");
    final List<PackageInfo> list = await _searchService.loadPackages(useIcons: useIcons);
    debugPrint("END");
    return list;
  }

  Future<void> launchPackage(String packageName) async {
    await _searchService.launchPackage(packageName);
  }
}
