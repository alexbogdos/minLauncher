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
    PackageInfo package =
        _packages.where((element) => element.packageName == packageName).first;
    package.lastAccessed = DateTime.now().millisecondsSinceEpoch;

    await _database.updateLastAccessed(packageName, DateTime.now().millisecondsSinceEpoch);

    await InstalledApps.startApp(packageName);
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
      _packages.map((packageInfo) async =>
          await _database.insertPackageInfo(packageInfo));

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
      storedApps
          .removeWhere((element) => element.packageName == info.packageName);
    }

    // Remove from the database all apps that where not on the device
    storedApps
        .map((e) async => await _database.removePackageInfo(e.packageName));

    return _packages;
  }
}
