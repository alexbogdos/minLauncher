import 'package:flutter/material.dart';

import 'package_info.dart';
import 'package_search_service.dart';

class PackageSearchController with ChangeNotifier {
  PackageSearchController(this._searchService);

  final PackageSearchService _searchService;
  bool canLoad = true;
  List<PackageInfo> query = List<PackageInfo>.empty(growable: true);
  TextEditingController textEditingController = TextEditingController();
  FocusNode focusNode = FocusNode();

  List<PackageInfo> get packages {
    if (query.isNotEmpty || textEditingController.value.text.isNotEmpty) return query;
    return _searchService.packages;
  }

  Future<void> init() async {
    await _searchService.initService();
  }

  void askToLoad() => canLoad = true;

  Future<void> reload() async {
    canLoad = true;
    await loadPackages();
    notifyListeners();
  }

  Future<void> search(String? value) async {
    query.clear();
    if (value == null || value == '') {
      notifyListeners();
      return;
    }

    for (PackageInfo info in _searchService.packages) {
      if (matchAlgorithm(info, value)) {
        query.add(info);
      }
    }

    query.sort((a, b) => a.compareTo(b));

    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 50), () {
      if (query.length == 1) launchFirst();
    });
  }

  /// Matching Algorithm
  bool matchAlgorithm(PackageInfo info, String text) {
    return info.name!.toLowerCase().contains(text.toLowerCase());
  }

  Future<List<PackageInfo>> loadPackages({bool useIcons = false}) async {
    if (!canLoad) return _searchService.packages;
    canLoad = false;
    debugPrint("Loading packages..");
    final List<PackageInfo> list = await _searchService.loadPackages(useIcons: useIcons);
    debugPrint("Finished. Packages loaded");
    notifyListeners();
    return list;
  }

  Future<void> launchFirst() async {
    PackageInfo? package = packages.firstOrNull;
    if (package != null) await launchPackage(package.packageName);
  }

  Future<void> launchPackage(String packageName) async {
    textEditingController.clear();
    query.clear();
    await _searchService.launchPackage(packageName);
    notifyListeners();
  }
}
