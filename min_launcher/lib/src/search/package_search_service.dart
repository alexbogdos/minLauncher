import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:min_launcher/src/search/package_info.dart';
import 'package:min_launcher/src/search/package_info_database.dart';

class PackageSearchService {
  final PackageInfoDatabase _database = PackageInfoDatabase();
  final List<PackageInfo> _packages = <PackageInfo>[];

  // FIXME: Limit access to info. Remove PackageInfo, update directly to db.
  List<PackageInfo> get packages => _packages;

  /// Initialize PackageInfoDatabase.
  Future<void> init() async {
    await _database.open();
  }

  /// Launch package by packageName.
  Future<void> launchPackage(String packageName) async {
    // Get package with the given packageName from _packages
    PackageInfo package = _packages.where((element) => element.packageName == packageName).first;

    // Increase package score by one and update lastAccessed to DateTime.now()
    package.updateInfo();

    // Start app launch
    InstalledApps.startApp(packageName);

    if (await _database.exists(packageName)) {
      // Update in database
      await _database.update(packageName, package.score!, package.lastAccessed!);
    } else {
      // Store in database
      await _database.insertPackageInfo(package);
    }
  }

  /// Open system settings page for this app.
  Future<void> openPackageSettings(String packageName) async => InstalledApps.openSettings(packageName);

  /// Load packages from the database and the device.
  Future<List<PackageInfo>> loadPackages() async {
    // Load stored apps from database
    Set<PackageInfo>? storedApps = await _database.getAllPackages();

    // Get installed apps from device
    Set<AppInfo> apps = (await InstalledApps.getInstalledApps(true, true, "")).toSet();

    // Hide self from the search list
    apps.removeWhere((element) => element.packageName == 'com.bogdosdev.min_launcher');

    // Database empty, map apps to PackageInfos and exit
    if (storedApps == null) {
      // It may be a reload of the packages so we need to clear any
      // previous ones
      _packages.clear();

      // Create PackageInfo from device apps
      _packages.addAll(apps.map((app) => PackageInfo.fromApp(app)));

      // Sort packages alphabetically
      _packages.sort((a, b) => a.compareNameTo(b));

      return _packages;
    }
    
    // It may be a reload of the packages so we need to clear any
    // previous ones
    _packages.clear();

    // Merge app name, icon and stored score, lastAccessed for each app
    // to on PackageInfo and add to _packages
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
      // as such, it is later removed from the database
      storedApps.removeWhere((element) => element.packageName == info.packageName);
    }

    // Remove from the database all apps that were not on the device
    await Future.wait([
      for (PackageInfo info in storedApps) _database.removePackageInfo(info.packageName),
    ]);

    // Sort packages alphabetically
    _packages.sort((a, b) => a.compareNameTo(b));

    return _packages;
  }
}
