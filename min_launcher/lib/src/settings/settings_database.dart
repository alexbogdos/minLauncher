import 'package:sqflite/sqflite.dart';

class SettingsDatabase {
  final String _databasePath = "settings.db";
  late Database _db;

  // Initialize database. Create if it doesn't exist
  Future<void> open() async {
    _db = await openDatabase(
      _databasePath,
      version: 1,
      onCreate: _createDb,
    );
  }

  // Create Database
  Future<void> _createDb(Database db, int version) async {
    await db.execute('''
      CREATE TABLE settings (
        title TEXT PRIMARY KEY,
        value TEXT
      );
    ''');
  }

  // Insert a setting into the database
  Future<void> insert(String title, dynamic value) async {
    await _db.insert(
      'settings',
      {'title': title, 'value': value.toString()},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> update<T>(String title, T value) async {
    await _db.update(
      'settings',
      {'value': value},
      where: 'title = ?',
      whereArgs: [title],
    );
  }

  // Get the value of a setting
  Future<T?> getValue<T>(String title) async {
    List<Map<String, dynamic>> maps = await _db.query(
      'settings',
      where: 'title = ?',
      whereArgs: [title],
    );
    if (maps.isNotEmpty) {
      return maps.first['value'] as T?;
    }
    return null;
  }
}
