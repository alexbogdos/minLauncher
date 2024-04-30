import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:min_launcher/src/search/package_info.dart';
import 'package:sqflite/sqflite.dart';

class SearchService {
  Database? _database;
  final String _databasePath = "installed_packages.db";
  final Set<PackageInfo> _packages = <PackageInfo>{};

  // Database getter
  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  /// Load packages from the database and the device.
  Future<void> loadPackages() async {
    await _initDatabase();

    // Load stored apps from database
    Set<PackageInfo>? storedApps = await getAllPackages();

    // Load apps from device
    Set<AppInfo> apps = (await InstalledApps.getInstalledApps(false, false)).toSet();

    // If database empty,
    if (storedApps == null) {
      // Create PackageInfo from device apps
      _packages.addAll(apps.map((app) => PackageInfo.fromAppInfo(app)));

      // Store device apps in database
      _packages.map((packageInfo) async => await insertPackageInfo(packageInfo));

      return;
    }

    // Merge device and stored data for each app and add to _packages
    for (AppInfo app in apps) {
      final PackageInfo info = PackageInfo.fromAppInfo(app);
      try {
        final PackageInfo storedInfo = storedApps.where((element) => element.packageName == info.packageName).first;
        info.score = storedInfo.score;
        info.lastAccessed = storedInfo.lastAccessed;
      }
      // Package not found in database
      on StateError catch (e) {
        await insertPackageInfo(info);
      }
      _packages.add(info);
      storedApps.removeWhere((element) => element.packageName == info.packageName);
    }

    // Remove from the database all apps that where not on the device
    storedApps.map((e) async => await removePackageInfo(e.packageName));
  }


  // Initialize database. Create if it doesn't exist
  Future<Database> _initDatabase() async {
    String path = '';
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDb,
    );
  }

  // Create Database
  Future<void> _createDb(Database db, int version) async {
    await db.execute('''
      CREATE TABLE package_info(
        package_name TEXT PRIMARY KEY,
        name TEXT
        score INTEGER,
        last_accessed INTEGER
      )
    ''');
  }

  // Insert a package info into the database
  Future<void> insertPackageInfo(PackageInfo packageInfo) async {
    Database db = await database;
    await db.insert('package_info', packageInfo.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Get info for the packageName passed
  Future<PackageInfo?> getPackageInfo(String packageName) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'package_info',
      where: 'package_name = ?',
      whereArgs: [packageName],
    );
    if (maps.isNotEmpty) {
      return PackageInfo.fromMap(maps.first);
    }
    return null;
  }

  Future<void> removePackageInfo(String packageName) async {
    Database db = await database;
    await db.delete('package_info', where: 'package_name = ?', whereArgs: [packageName]);
  }

  // Get all packages in database
  Future<Set<PackageInfo>?> getAllPackages() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'package_info',
    );
    if (maps.isNotEmpty) {
      return maps.map((e) => PackageInfo.fromMap(e)).toSet();
    }
    return null;
  }
}
