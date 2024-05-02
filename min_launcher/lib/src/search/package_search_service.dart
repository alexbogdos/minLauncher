import 'package:flutter/material.dart';
import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:min_launcher/src/search/package_info.dart';
import 'package:min_launcher/src/search/package_info_database.dart';

class PackageSearchService {
  final PackageInfoDatabase _database = PackageInfoDatabase();
  final List<PackageInfo> _packages = <PackageInfo>[];

  // FIXME: Limit access to info. Remove PackageInfo, update directly to db.
  List<PackageInfo> get packages => _packages;

  Future<void> initService() async {
    await _database.initDatabase();
  }

  /// Launch package by packageName
  Future<void> launchPackage(String packageName) async {
    PackageInfo package = _packages.where((element) => element.packageName == packageName).first;

    package.launch();

    // Update in database
    await _database.updateLastAccessed(packageName, package.lastAccessed!);
    await _database.updateScore(packageName, package.score!);

    // Launch app
    await InstalledApps.startApp(packageName);

    // Sort packages
    _packages.sort((a,b) => a.compareTo(b));
  }

  /// Load packages from the database and the device.
  Future<List<PackageInfo>> loadPackages({bool useIcons = false}) async {
    // Load stored apps from database
    Set<PackageInfo>? storedApps = await _database.getAllPackages();

    // Load apps from device
    Set<AppInfo> apps =
        (await InstalledApps.getInstalledApps(true, useIcons, "")).toSet();

    // If database empty,
    if (storedApps == null) {
      _packages.clear();

      // Create PackageInfo from device apps
      _packages.addAll(apps.map((app) => PackageInfo.fromApp(app)));

      // Store device apps in database
      await Future.wait([
        for (PackageInfo info in _packages) _database.insertPackageInfo(info),
      ]);

      return _packages;
    }

    // Merge device and stored data for each app and add to _packages
    _packages.clear();

    for (AppInfo app in apps) {
      final PackageInfo info = PackageInfo.fromApp(app);
      try {
        final PackageInfo storedInfo = storedApps
            .where((element) => element.packageName == info.packageName)
            .first;
        info.score = storedInfo.score;
        info.lastAccessed = storedInfo.lastAccessed;
      }
      // Package not found in database
      on StateError {
        debugPrint(
            "Package: `${info.packageName}` not found in database. Creating..");
        await _database.insertPackageInfo(info);
      }
      _packages.add(info);
      storedApps.removeWhere((element) => element.packageName == info.packageName);
    }

    // Remove from the database all apps that where not on the device
    await Future.wait([
      for (PackageInfo info in storedApps)
        _database.removePackageInfo(info.packageName),
    ]);

    _packages.sort((a,b) => a.compareTo(b));

    return _packages;
  }
}
