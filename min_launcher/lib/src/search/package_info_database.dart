import 'package:sqflite/sqflite.dart';

import 'package_info.dart';

class PackageInfoDatabase {
  final String _databasePath = "installed_packages.db";
  late Database _db;

  // Initialize database. Create if it doesn't exist
  Future<void> initDatabase() async {
    _db = await openDatabase(
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
        score INTEGER,
        last_accessed INTEGER
      );
    ''');
  }

  // Insert a package info into the database
  Future<void> insertPackageInfo(PackageInfo packageInfo) async {
    await _db.insert('package_info', packageInfo.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<bool> exists(String packageName) async {
    List<Map<String, dynamic>> maps = await _db.query(
      'package_info',
      where: 'package_name = ?',
      whereArgs: [packageName],
    );
    return maps.isNotEmpty;
  }

  Future<void> updateScore(String packageName, int score) async {
    await _db.update(
      'package_info',
      {'score': score},
      where: 'package_name = ?',
      whereArgs: [packageName],
    );
  }

  Future<void> updateLastAccessed(String packageName, int lastAccessed) async {
    await _db.update(
      'package_info',
      {'last_accessed': lastAccessed},
      where: 'package_name = ?',
      whereArgs: [packageName],
    );
  }

  // Get info for the packageName passed
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

  Future<void> removePackageInfo(String packageName) async {
    await _db.delete('package_info',
        where: 'package_name = ?', whereArgs: [packageName]);
  }

  // Get all packages in database
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
