import 'package:sqflite/sqflite.dart';

import 'package_info.dart';

class PackageInfoDatabase {
  final String _databasePath = "installed_packages.db";
  late Database _db;

  /// Initialize database. Create if it doesn't exist.
  Future<void> initDatabase() async {
    _db = await openDatabase(
      _databasePath,
      version: 1,
      onCreate: _createDb,
    );
  }

  /// Create Database.
  Future<void> _createDb(Database db, int version) async {
    await db.execute('''
      CREATE TABLE package_info(
        package_name TEXT PRIMARY KEY,
        score INTEGER,
        last_accessed INTEGER
      );
    ''');
  }

  /// Insert a PackageInfo into the database.
  Future<void> insertPackageInfo(PackageInfo packageInfo) async {
    await _db.insert('package_info', packageInfo.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Return true if the given packageName exists in the database.
  Future<bool> exists(String packageName) async {
    List<Map<String, dynamic>> maps = await _db.query(
      'package_info',
      where: 'package_name = ?',
      whereArgs: [packageName],
    );
    return maps.isNotEmpty;
  }

  /// Update the score, lastAccessed of the stored package with the given packageName.
  Future<void> update(String packageName, int score, int lastAccessed) async {
    await _db.update(
      'package_info',
      {'score': score, 'last_accessed': lastAccessed},
      where: 'package_name = ?',
      whereArgs: [packageName],
    );
  }

  /// Get the score, lastAccessed as PackageInfo for the packageName passed.
  Future<PackageInfo?> getPackageInfo(String packageName) async {
    List<Map<String, dynamic>> maps = await _db.query(
      'package_info',
      where: 'package_name = ?',
      whereArgs: [packageName],
    );
    if (maps.isNotEmpty) {
      return PackageInfo.fromMap(maps.first);
    }
    return null;
  }

  /// Remove a database entry with the given packageName.
  Future<void> removePackageInfo(String packageName) async {
    await _db.delete('package_info',
        where: 'package_name = ?', whereArgs: [packageName]);
  }

  /// Get all score, lastAccessed as PackageInfo for every
  /// entry in the database.
  Future<Set<PackageInfo>?> getAllPackages() async {
    List<Map<String, dynamic>> maps = await _db.query(
      'package_info',
    );
    if (maps.isNotEmpty) {
      return maps.map((e) => PackageInfo.fromMap(e)).toSet();
    }
    return null;
  }
}
