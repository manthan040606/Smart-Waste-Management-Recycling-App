import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/waste_log.dart';
import '../models/schedule.dart';
import '../services/database_helper.dart';
import '../services/mongo_service.dart';

class AppProvider with ChangeNotifier {
  List<WasteLog> _wasteLogs = [];
  List<PickupSchedule> _schedules = [];
  int _totalPoints = 0;
  
  List<WasteLog> get wasteLogs => _wasteLogs;
  List<PickupSchedule> get schedules => _schedules;
  int get totalPoints => _totalPoints;

  AppProvider() {
    _initConnectivityListener();
  }

  void _initConnectivityListener() {
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> result) {
      bool isOnline = result.isNotEmpty && !result.contains(ConnectivityResult.none);
      
      if (isOnline) {
        _syncOfflineData();
      }
    });
  }

  Future<void> _syncOfflineData() async {
    final pendingLogs = _wasteLogs.where((log) => log.syncStatus == 0).toList();
    if (pendingLogs.isEmpty && _schedules.isEmpty) return;

    try {
      // Sync remaining offline Logs
      if (pendingLogs.isNotEmpty) {
        await MongoService.syncWasteLogs(pendingLogs);
        for (var log in pendingLogs) {
          await DatabaseHelper.instance.updateWasteLogSyncStatus(log.id, 1);
        }
      }
      
      // Also ensure schedules are synced up
      if (_schedules.isNotEmpty) {
        await MongoService.syncSchedules(_schedules);
      }
      
      await loadData();
      debugPrint('MongoDB Sync Completed');
    } catch (e) {
      debugPrint('MongoDB Sync Failed: $e');
    }
  }

  Future<void> loadData() async {
    _wasteLogs = await DatabaseHelper.instance.getWasteLogs();
    _schedules = await DatabaseHelper.instance.getSchedules();
    _calculatePoints();
    notifyListeners();
  }

  void _calculatePoints() {
    _totalPoints = _wasteLogs.fold(0, (sum, log) => sum + log.points);
  }

  Future<void> addWasteLog(WasteLog log) async {
    await DatabaseHelper.instance.insertWasteLog(log);
    await loadData();
    
    final result = await Connectivity().checkConnectivity();
    bool isOnline = result.isNotEmpty && !result.contains(ConnectivityResult.none);
    
    if (isOnline) {
      _syncOfflineData();
    }
  }

  Future<void> addSchedule(PickupSchedule schedule) async {
    await DatabaseHelper.instance.insertSchedule(schedule);
    await loadData();
    
    // Attempt instant sync for newly added schedule
    final result = await Connectivity().checkConnectivity();
    bool isOnline = result.isNotEmpty && !result.contains(ConnectivityResult.none);
    
    if (isOnline) {
      try {
        await MongoService.syncSchedules([schedule]);
        debugPrint('Schedule automatically synced to Mongo');
      } catch (e) {
        debugPrint('Failed to auto-sync schedule to Mongo');
      }
    }
  }
}
