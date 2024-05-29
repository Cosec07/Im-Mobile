import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:latlong2/latlong.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
  String path = join(await getDatabasesPath(), 'path_tracker.db');
  return await openDatabase(
    path,
    version: 1,
    onCreate: (db, version) {
      db.execute(
        '''
        CREATE TABLE sessions(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          start_time INTEGER,
          end_time INTEGER
        );
        '''
      );
      db.execute(
        '''
        CREATE TABLE locations(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          session_id INTEGER,
          latitude REAL,
          longitude REAL,
          timestamp INTEGER,
          FOREIGN KEY (session_id) REFERENCES sessions(id)
        );
        '''
      );
    },
  );
}

  Future<int> createSession() async {
    final db = await database;
    return await db.insert('sessions', {
      'start_time': DateTime.now().millisecondsSinceEpoch,
      'end_time': 0,
    });
  }

  Future<void> endSession(int sessionId) async {
    final db = await database;
    await db.update(
      'sessions',
      {'end_time': DateTime.now().millisecondsSinceEpoch},
      where: 'id = ?',
      whereArgs: [sessionId],
    );
  }

  Future<void> insertLatLng(int sessionId, LatLng latLng) async {
    final db = await database;
    await db.insert(
      'locations',
      {
        'session_id': sessionId,
        'latitude': latLng.latitude,
        'longitude': latLng.longitude,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getPath(int sessionId) async {
    final db = await database;
    return await db.query('locations', where: 'session_id = ?', whereArgs: [sessionId]);
  }

  Future<List<Map<String, dynamic>>> getSessions() async {
    final db = await database;
    return await db.query('sessions');
  }
}
