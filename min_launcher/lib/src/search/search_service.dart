import 'package:flutter/material.dart';
import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:min_launcher/src/search/package_info.dart';
import 'package:min_launcher/src/search/package_info_database.dart';

class SearchService {
  final PackageInfoDatabase _database = PackageInfoDatabase();
  final Set<PackageInfo> _packages = <PackageInfo>{};

  /// Load packages from the database and the device.
  Future<void> loadPackages() async {

    // Load stored apps from database
    Set<PackageInfo>? storedApps = await _database.getAllPackages();

    // Load apps from device
    Set<AppInfo> apps =
        (await InstalledApps.getInstalledApps(false, false)).toSet();

    // If database empty,
    if (storedApps == null) {
      // Create PackageInfo from device apps
      _packages.addAll(apps.map((app) => PackageInfo.fromAppInfo(app)));

      // Store device apps in database
      _packages.map((packageInfo) async =>
          await _database.insertPackageInfo(packageInfo));

      return;
    }

    // Merge device and stored data for each app and add to _packages
    for (AppInfo app in apps) {
      final PackageInfo info = PackageInfo.fromAppInfo(app);
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
  }
}
