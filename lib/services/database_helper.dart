import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/waste_log.dart';
import '../models/schedule.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('greencity.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    const realType = 'REAL NOT NULL';
    const integerType = 'INTEGER NOT NULL';
    
    // Create WasteLogs table
    await db.execute('''
CREATE TABLE waste_logs (
  id $idType,
  category $textType,
  description $textType,
  quantityKg $realType,
  timestamp $textType,
  latitude REAL,
  longitude REAL,
  points $integerType,
  syncStatus $integerType
  )
''');

    // Create Schedules table
    await db.execute('''
CREATE TABLE schedules (
  id $idType,
  scheduledTime $textType,
  address $textType,
  latitude REAL,
  longitude REAL,
  status $textType
  )
''');
  }

  Future<void> insertWasteLog(WasteLog log) async {
    final db = await instance.database;
    await db.insert('waste_logs', log.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<WasteLog>> getWasteLogs() async {
    final db = await instance.database;
    final result = await db.query('waste_logs', orderBy: 'timestamp DESC');
    return result.map((json) => WasteLog.fromMap(json)).toList();
  }

  Future<void> updateWasteLogSyncStatus(String id, int syncStatus) async {
    final db = await instance.database;
    await db.update(
      'waste_logs',
      {'syncStatus': syncStatus},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> insertSchedule(PickupSchedule schedule) async {
    final db = await instance.database;
    await db.insert('schedules', schedule.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<PickupSchedule>> getSchedules() async {
    final db = await instance.database;
    final result = await db.query('schedules', orderBy: 'scheduledTime ASC');
    return result.map((json) => PickupSchedule.fromMap(json)).toList();
  }
}
