import 'package:min_launcher/src/search/package_info.dart';
import 'package:sqflite/sqflite.dart';

class PackageInfoDatabase {
  final String _databasePath = "installed_packages.db";
  Database? _database;

  // Database getter
  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await initDatabase();
    return _database!;
  }

  // Initialize database. Create if it doesn't exist
  Future<Database> initDatabase() async {
    return await openDatabase(
      _databasePath,
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
    await db.delete('package_info',
        where: 'package_name = ?', whereArgs: [packageName]);
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
