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

    package.updateInfo();

    // Start app launch
    InstalledApps.startApp(packageName);

    if (await _database.exists(packageName)) {
      // Update in database
      await _database.updateLastAccessed(packageName, package.lastAccessed!);
      await _database.updateScore(packageName, package.score!);
    } else {
      // Store in database
      await _database.insertPackageInfo(package);
    }
  }

  /// Load packages from the database and the device.
  Future<List<PackageInfo>> loadPackages() async {
    // Load stored apps from database
    Set<PackageInfo>? storedApps = await _database.getAllPackages();

    // Get installed apps
    Set<AppInfo> apps = (await InstalledApps.getInstalledApps(true, true, "")).toSet();

    // Database empty, map apps to PackageInfos and exit
    if (storedApps == null) {
      _packages.clear();

      // Create PackageInfo from device apps
      _packages.addAll(apps.map((app) => PackageInfo.fromApp(app)));

      // Sort packages alphabetically
      _packages.sort((a, b) => a.compareNameTo(b));

      return _packages;
    }

    _packages.clear();

    // Merge device and stored data for each app and add to _packages
    for (AppInfo app in apps) {
      final PackageInfo info = PackageInfo.fromApp(app);
      final PackageInfo? storedInfo = storedApps
          .where((element) => element.packageName == info.packageName)
          .firstOrNull;

      // Package exists in database
      if (storedInfo != null) {
        info.score = storedInfo.score;
        info.lastAccessed = storedInfo.lastAccessed;
      }

      _packages.add(info);

      // Remove package from stored apps. This means that any package remaining
      // exists in the database but has been uninstalled from the device
      // as such, it is later removed from the database.
      storedApps.removeWhere((element) => element.packageName == info.packageName);
    }

    // Remove from the database all apps that where not on the device
    await Future.wait([
      for (PackageInfo info in storedApps)
        _database.removePackageInfo(info.packageName),
    ]);

    // Sort packages alphabetically
    _packages.sort((a, b) => a.compareNameTo(b));

    return _packages;
  }
}
