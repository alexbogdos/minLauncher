import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package_info.dart';
import 'package_search_service.dart';
import 'package_search_bar_utils.dart';

class PackageSearchController with ChangeNotifier {
  PackageSearchController(this._searchService);

  final PackageSearchService _searchService;
  bool _canLoad = true;
  bool _start = true;
  final List<PackageInfo> _query = List<PackageInfo>.empty(growable: true);
  late Timer _timer;
  static const Duration _refreshDuration = Duration(seconds: 30);

  final PackageSearchBarUtils _barUtils = PackageSearchBarUtils();
  final ScrollController scrollController = ScrollController();

  TextEditingController get textEditingController =>
      _barUtils.textEditingController;
  FocusNode get focusNode => _barUtils.focusNode;

  /// Return the raw list of packages or the resulted query list if
  /// there is a query been made.
  List<PackageInfo> get packages {
    if (_query.isNotEmpty ||
        textEditingController.value.text.trim().isNotEmpty) {
      return _query;
    }
    return _searchService.packages;
  }

  /// Initialize the PackageSearchService.
  Future<void> init() async {
    await _searchService.init();
    _barUtils.init();
  }

  /// Initialize the Timer which periodically refreshes the packages list.
  void _onStart() {
    _timer = Timer.periodic(_refreshDuration, (Timer timer) => _forceReload());
    _start = false;
  }

  /// Load all system packages.
  Future<List<PackageInfo>> loadPackages() async {
    // Since the init() runs before the PackageSearchView widget
    // gets initialized, this is the best place to run _onStart()
    if (_start) _onStart();

    if (!_canLoad) return _searchService.packages;
    _canLoad = false;
    debugPrint("Loading packages..");
    final List<PackageInfo> list = await _searchService.loadPackages();
    debugPrint("Finished. Packages loaded");
    notifyListeners();
    return list;
  }

  /// Request to reload packages at the next update of the PackageSearchView.
  void requestLoad() => _canLoad = true;

  /// Force reload of packages.
  Future<void> _forceReload() async {
    _canLoad = true;
    await loadPackages();
  }

  /// Launch the app located at the top of the list.
  Future<void> launchPackageAtTop() async {
    PackageInfo? package = packages.firstOrNull;
    if (package != null) await launchPackage(package.packageName);
  }

  /// Open app from given package name.
  Future<void> launchPackage(String packageName) async {
    await clearAndFocus();
    await _searchService.launchPackage(packageName);
    notifyListeners();
  }

  /// Open the system page from application settings.
  Future<void> openPackageSettings(String packageName) async {
    await clearAndFocus();
    _searchService.openPackageSettings(packageName);
    notifyListeners();
  }

  /// Search for the packages that match the given name
  /// return sorted based on package frecency.
  Future<void> search(String queryStr, bool autoLaunch, int depth) async {
    // Its query it's separate than others
    _query.clear();

    // The given name must be the result of the user
    // pressing backspace. Call notifyListeners() to update
    // the PackageSearchView and show the complete package list
    // after clearing the query.
    if (queryStr == '') {
      notifyListeners();
      return;
    }

    // Add all packages that match the name to the query list
    _query.addAll(_searchService.packages
        .where((element) => matchAlgorithm(element, queryStr)));

    // Sort based on package frecency
    _query.sort((a, b) => a.compareTo(b));

    // Redraw PackageSearchView, display new packages list
    notifyListeners();

    if (!autoLaunch) return;

    // If the query has only one result, launch the app
    // There is a small to delay as to have time to show the user
    // the results
    await Future.delayed(const Duration(milliseconds: 50), () {
      if (_query.length == 1 || (depth > 0 && queryStr.length >= depth)) {
        launchPackageAtTop();
      }
    });
  }

  /// Query - Package matching algorithm.
  bool matchAlgorithm(PackageInfo info, String text) {
    return info.name!.toLowerCase().contains(text.toLowerCase());
  }

  /// Unfocus from text field.
  void unfocus() => _barUtils.unfocus();

  /// Ensure only one focus request can be made at once.
  bool _canFocusTop = true;

  /// Focus on search bar when the ListView on PackageSearchListView is a the top.
  Future<void> focusIfAtTop() async {
    if (_canFocusTop &&
        scrollController.position.atEdge &&
        scrollController.position.pixels == 0) {
      _canFocusTop = false;
      await clearAndFocus(focus: true, clear: false);
      _canFocusTop = true;
    }
  }

  /// Clear query text and query list and request focus
  Future<void> clearAndFocus({bool focus = false, bool clear = true}) async {
    if (clear) _query.clear();
    await _barUtils.clearAndFocus(notifyListeners, focus: focus, clear: clear);
  }
}
