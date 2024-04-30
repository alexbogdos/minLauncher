import 'package:flutter/material.dart';
import 'package:min_launcher/src/search/search_service.dart';

class SearchController with ChangeNotifier {
  SearchController(this._searchService);

  final SearchService _searchService;

  Future<void> loadInstalledPackages() async {
    await _searchService.loadPackages();

    notifyListeners();
  }
}