import 'package:mongo_dart/mongo_dart.dart';
import '../models/waste_log.dart';
import '../models/schedule.dart';
import 'package:flutter/foundation.dart';

class MongoService {
  static Db? _db;
  // URL encoding the password "manthan@1543" -> "manthan%401543" to avoid parsing errors
  static const String _uri = "mongodb+srv://verified3737_db_user:manthan%401543@23it007.khzjsrh.mongodb.net/smart_waste?appName=23IT007";
  
  static Future<void> connect() async {
    if (_db != null && _db!.isConnected) return;
    try {
      _db = await Db.create(_uri);
      await _db!.open();
      debugPrint('Connected to MongoDB');
    } catch (e) {
      debugPrint('Failed to connect to MongoDB: $e');
    }
  }

  static Future<void> syncWasteLogs(List<WasteLog> logs) async {
    if (_db == null || !_db!.isConnected) await connect();
    if (_db == null || !_db!.isConnected) return;
    
    final collection = _db!.collection('waste_logs');
    for (var log in logs) {
      try {
        final existing = await collection.findOne(where.eq('id', log.id));
        if (existing == null) {
          await collection.insert(log.toMap());
        } else {
          await collection.update(where.eq('id', log.id), log.toMap());
        }
      } catch (e) {
        debugPrint('Mongo Error: $e');
      }
    }
  }
  
  static Future<void> syncSchedules(List<PickupSchedule> schedules) async {
    if (_db == null || !_db!.isConnected) await connect();
    if (_db == null || !_db!.isConnected) return;
    
    final collection = _db!.collection('schedules');
    for (var schedule in schedules) {
      try {
        final existing = await collection.findOne(where.eq('id', schedule.id));
        if (existing == null) {
          await collection.insert(schedule.toMap());
        } else {
          await collection.update(where.eq('id', schedule.id), schedule.toMap());
        }
      } catch (e) {
        debugPrint('Mongo Error: $e');
      }
    }
  }
}
