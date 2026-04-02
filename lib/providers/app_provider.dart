import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/waste_log.dart';
import '../models/schedule.dart';
import '../models/app_notification.dart';
import '../services/database_helper.dart';
import '../services/mongo_service.dart';

class AppProvider with ChangeNotifier {
  List<WasteLog> _wasteLogs = [];
  List<PickupSchedule> _schedules = [];
  List<AppNotification> _notifications = [];
  int _totalPoints = 0;
  int _pointsSpent = 0;
  
  List<WasteLog> get wasteLogs => _wasteLogs;
  List<PickupSchedule> get schedules => _schedules;
  List<AppNotification> get notifications => _notifications;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;
  int get totalPoints => _totalPoints - _pointsSpent;

  AppProvider() {
    _initConnectivityListener();
  }

  void _initConnectivityListener() {
    try {
      Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> result) {
        bool isOnline = result.isNotEmpty && !result.contains(ConnectivityResult.none);
        if (isOnline) {
          _syncOfflineData();
        }
      });
    } catch (e) {
      // Ignored on Web Hot Restart where JS channel is missing
      debugPrint('Plugin Error: $e');
    }
  }

  Future<void> _syncOfflineData() async {
    final pendingLogs = _wasteLogs.where((log) => log.syncStatus == 0).toList();
    if (pendingLogs.isEmpty && _schedules.isEmpty) return;

    try {
      if (pendingLogs.isNotEmpty) {
        await MongoService.syncWasteLogs(pendingLogs);
        for (var log in pendingLogs) {
          await DatabaseHelper.instance.updateWasteLogSyncStatus(log.id, 1);
        }
      }
      
      if (_schedules.isNotEmpty) {
        await MongoService.syncSchedules(_schedules);
      }
      
      await loadData();
    } catch (e) {
      debugPrint('MongoDB Sync Failed: $e');
    }
  }

  Future<void> loadData() async {
    try {
      _wasteLogs = await DatabaseHelper.instance.getWasteLogs();
      _schedules = await DatabaseHelper.instance.getSchedules();
      _notifications = await DatabaseHelper.instance.getNotifications();
      _pointsSpent = await DatabaseHelper.instance.getPointsSpent();
      _calculatePoints();
      notifyListeners();
    } catch (e) {
      debugPrint('Failed mapping JSON: $e');
    }
  }

  Future<void> redeemReward(int cost) async {
    if (totalPoints >= cost) {
      await DatabaseHelper.instance.addPointsSpent(cost);
      await addNotification('Reward Redeemed!', 'You spent $cost points on a reward.');
      await loadData();
    }
  }

  Future<void> markNotificationsRead() async {
    await DatabaseHelper.instance.markNotificationsRead();
    await loadData();
  }

  Future<void> addNotification(String title, String message) async {
    final notif = AppNotification(
      id: const Uuid().v4(),
      title: title,
      message: message,
      timestamp: DateTime.now(),
    );
    await DatabaseHelper.instance.insertNotification(notif);
    await loadData();
  }

  void _calculatePoints() {
    _totalPoints = _wasteLogs.fold(0, (sum, log) => sum + log.points);
  }

  Future<void> addWasteLog(WasteLog log) async {
    await DatabaseHelper.instance.insertWasteLog(log);
    await addNotification('Waste Logged & Analysed!', 'You correctly categorized your ${log.category} waste and earned ${log.points} points!');
    await loadData(); // Update UI immediately
    
    // Force sync unconditionally to bypass OS network detection glitches
    _syncOfflineData();
  }

  Future<void> deleteWasteLog(String id) async {
    await DatabaseHelper.instance.deleteWasteLog(id);
    await loadData();
  }

  Future<void> addSchedule(PickupSchedule schedule) async {
    await DatabaseHelper.instance.insertSchedule(schedule);
    await addNotification('Pickup Confirmed!', 'We scheduled your pickup at ${schedule.address}. You will be reminded when it arrives!');
    await loadData(); // Update UI immediately
    
    // Force sync unconditionally
    _syncOfflineData();
  }

  Future<void> deleteSchedule(String id) async {
    await DatabaseHelper.instance.deleteSchedule(id);
    await loadData();
  }
}

