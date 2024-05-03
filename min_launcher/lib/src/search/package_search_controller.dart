import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package_info.dart';
import 'package_search_service.dart';

class PackageSearchController with ChangeNotifier {
  PackageSearchController(this._searchService);

  final PackageSearchService _searchService;
  bool _canLoad = true;
  final List<PackageInfo> _query = List<PackageInfo>.empty(growable: true);
  late Timer _timer;
  static const Duration _refreshDuration = Duration(seconds: 30);

  TextEditingController textEditingController = TextEditingController();
  ScrollController scrollController = ScrollController();
  FocusNode focusNode = FocusNode();

  List<PackageInfo> get packages {
    if (_query.isNotEmpty || textEditingController.value.text.isNotEmpty) return _query;
    return _searchService.packages;
  }

  Future<void> init() async {
    await _searchService.initService();
    _timer = Timer.periodic(_refreshDuration, (Timer timer) => _refresh);
  }

  void requestLoad() => _canLoad = true;

  bool atListTop() {
    return scrollController.position.atEdge && scrollController.position.pixels == 0;
  }

  Future<void> _refresh() async {
    _canLoad = true;
    await loadPackages();
    notifyListeners();
  }

  Future<void> search(String? value) async {
    _query.clear();
    if (value == null || value == '') {
      notifyListeners();
      return;
    }

    for (PackageInfo info in _searchService.packages) {
      if (matchAlgorithm(info, value)) {
        _query.add(info);
      }
    }

    _query.sort((a, b) => a.compareTo(b));

    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 50), () {
      if (_query.length == 1) launchPackageAtTop();
    });
  }

  /// Matching Algorithm
  bool matchAlgorithm(PackageInfo info, String text) {
    return info.name!.toLowerCase().contains(text.toLowerCase());
  }

  Future<List<PackageInfo>> loadPackages() async {
    if (!_canLoad) return _searchService.packages;
    _canLoad = false;
    debugPrint("Loading packages..");
    final List<PackageInfo> list = await _searchService.loadPackages();
    debugPrint("Finished. Packages loaded");
    notifyListeners();
    return list;
  }

  Future<void> launchPackageAtTop() async {
    PackageInfo? package = packages.firstOrNull;
    if (package != null) await launchPackage(package.packageName);
  }

  Future<void> launchPackage(String packageName) async {
    await _searchService.launchPackage(packageName);
    resetAndFocus();
    notifyListeners();
  }

  void resetAndFocus() {
    textEditingController.clear();
    _query.clear();
    focusNode.requestFocus();
  }
}
