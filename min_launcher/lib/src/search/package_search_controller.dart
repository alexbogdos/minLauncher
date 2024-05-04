import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package_info.dart';
import 'package_search_service.dart';

class PackageSearchController with ChangeNotifier {
  PackageSearchController(this._searchService);

  final PackageSearchService _searchService;
  bool _canLoad = true;
  bool canFocus = true;
  bool _start = true;
  final List<PackageInfo> _query = List<PackageInfo>.empty(growable: true);
  late Timer _timer;
  static const Duration _refreshDuration = Duration(seconds: 30);

  TextEditingController textEditingController = TextEditingController();
  ScrollController scrollController = ScrollController();
  FocusNode focusNode = FocusNode();

  /// Return the raw list of packages or the resulted query list if
  /// there is a query been made.
  List<PackageInfo> get packages {
    if (_query.isNotEmpty || textEditingController.value.text.isNotEmpty) return _query;
    return _searchService.packages;
  }

  /// Initialize the PackageSearchService.
  Future<void> init() async {
    await _searchService.initService();
  }

  /// Request to reload packages at the next update of the PackageSearchView.
  void requestLoad() => _canLoad = true;

  /// The ListView on PackageSearchListView is a the top.
  bool atListTop() {
    return scrollController.position.atEdge && scrollController.position.pixels == 0;
  }

  /// Force reload of packages.
  Future<void> _refresh() async {
    _canLoad = true;
    await loadPackages();
  }

  /// Search for the packages that match the given name
  /// return sorted based on package frecency.
  Future<void> search(String? name) async {
    // Its query it's separate than others
    _query.clear();
    
    // The given name must be the result of the user
    // pressing backspace. Call notifyListeners() to update
    // the PackageSearchView and show the complete package list
    // after clearing the query.
    if (name == null || name == '') {
      notifyListeners();
      return;
    }

    // Add all packages that match the name to the query list
    _query.addAll(_searchService.packages.where((element) => matchAlgorithm(element, name)));

    // Sort based on package frecency
    _query.sort((a, b) => a.compareTo(b));

    // Redraw PackageSearchView, display new packages list
    notifyListeners();

    // If the query has only one result, launch the app
    // There is a small to delay as to have time to show the user 
    // the results
    await Future.delayed(const Duration(milliseconds: 50), () {
      if (_query.length == 1) launchPackageAtTop();
    });
  }

  /// Query - Package matching algorithm.
  bool matchAlgorithm(PackageInfo info, String text) {
    return info.name!.toLowerCase().contains(text.toLowerCase());
  }

  /// Initialize the Timer which periodically refreshes the packages list.
  void _onStart() {
    _timer = Timer.periodic(_refreshDuration, (Timer timer) => _refresh());
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

  /// Launch the app located at the top of the list.
  Future<void> launchPackageAtTop() async {
    PackageInfo? package = packages.firstOrNull;
    if (package != null) await launchPackage(package.packageName);
  }

  /// Open app from given package name.
  Future<void> launchPackage(String packageName) async {
    await _searchService.launchPackage(packageName);
    await resetAndFocus();
    notifyListeners();
  }

  /// Open the system page from application settings.
  Future<void> openPackageSettings(String packageName) async {
    _searchService.openPackageSettings(packageName);
    await resetAndFocus();
    notifyListeners();
  }

  /// Unfocus from text field.
  void unfocus() {
    focusNode.unfocus();
    canFocus = false;
  }

  /// Clear query text and query list and request/deny focus
  Future<void> resetAndFocus({bool focus = false}) async {
    _query.clear();

    // Remove focus from the text field because, after an app launch
    // returning to launcher the keyboard will be hidden but sometimes
    // the text field will be focused making the swipe down not work
    if (!focus) {focusNode.unfocus();} 
    else {canFocus = true;}

    notifyListeners();
    
    // Delay so that any key pressed during the launch of a package
    // can be cleared
    await Future.delayed(const Duration(milliseconds: 250), () {
      textEditingController.clear();
      if (canFocus) {focusNode.requestFocus();}
      else {focusNode.requestFocus();}
    });
  }
}
