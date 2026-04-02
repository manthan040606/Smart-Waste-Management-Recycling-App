import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/waste_log.dart';
import '../models/schedule.dart';
import '../models/app_notification.dart';
import '../models/user.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  DatabaseHelper._init();

  static const String _wasteKey = 'waste_logs_data';
  static const String _scheduleKey = 'schedules_data';
  static const String _pointsSpentKey = 'points_spent_data';
  static const String _notifKey = 'notifications_data';
  static const String _userKey = 'current_user_data';

  Future<void> saveCurrentUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toMap()));
  }

  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_userKey);
    if (str != null) {
      return User.fromMap(jsonDecode(str));
    }
    return null;
  }

  Future<void> logoutUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  Future<void> insertNotification(AppNotification notif) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> list = prefs.getStringList(_notifKey) ?? [];
    list.insert(0, jsonEncode(notif.toMap()));
    await prefs.setStringList(_notifKey, list);
  }

  Future<List<AppNotification>> getNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> list = prefs.getStringList(_notifKey) ?? [];
    return list.map((s) => AppNotification.fromMap(jsonDecode(s))).toList();
  }

  Future<void> markNotificationsRead() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> list = prefs.getStringList(_notifKey) ?? [];
    List<String> updated = list.map((s) {
      final map = jsonDecode(s);
      map['isRead'] = 1;
      return jsonEncode(map);
    }).toList();
    await prefs.setStringList(_notifKey, updated);
  }

  Future<int> getPointsSpent() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_pointsSpentKey) ?? 0;
  }

  Future<void> addPointsSpent(int points) async {
    final prefs = await SharedPreferences.getInstance();
    int current = prefs.getInt(_pointsSpentKey) ?? 0;
    await prefs.setInt(_pointsSpentKey, current + points);
  }

  Future<void> insertWasteLog(WasteLog log) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> logsStr = prefs.getStringList(_wasteKey) ?? [];
    
    int index = logsStr.indexWhere((s) {
      final map = jsonDecode(s);
      return map['id'] == log.id;
    });

    if (index >= 0) {
      logsStr[index] = jsonEncode(log.toMap());
    } else {
      logsStr.insert(0, jsonEncode(log.toMap()));
    }
    
    await prefs.setStringList(_wasteKey, logsStr);
  }

  Future<List<WasteLog>> getWasteLogs() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> logsStr = prefs.getStringList(_wasteKey) ?? [];
    final logs = logsStr.map((s) => WasteLog.fromMap(jsonDecode(s))).toList();
    logs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return logs;
  }

  Future<void> updateWasteLogSyncStatus(String id, int syncStatus) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> logsStr = prefs.getStringList(_wasteKey) ?? [];
    
    for (int i = 0; i < logsStr.length; i++) {
        final map = jsonDecode(logsStr[i]);
        if (map['id'] == id) {
            map['syncStatus'] = syncStatus;
            logsStr[i] = jsonEncode(map);
            break;
        }
    }
    await prefs.setStringList(_wasteKey, logsStr);
  }

  Future<void> deleteWasteLog(String id) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> logsStr = prefs.getStringList(_wasteKey) ?? [];
    logsStr.removeWhere((s) {
      final map = jsonDecode(s);
      return map['id'] == id;
    });
    await prefs.setStringList(_wasteKey, logsStr);
  }

  Future<void> insertSchedule(PickupSchedule schedule) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> schedStr = prefs.getStringList(_scheduleKey) ?? [];
    
    int index = schedStr.indexWhere((s) {
      final map = jsonDecode(s);
      return map['id'] == schedule.id;
    });

    if (index >= 0) {
      schedStr[index] = jsonEncode(schedule.toMap());
    } else {
      schedStr.add(jsonEncode(schedule.toMap()));
    }
    
    await prefs.setStringList(_scheduleKey, schedStr);
  }

  Future<List<PickupSchedule>> getSchedules() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> schedStr = prefs.getStringList(_scheduleKey) ?? [];
    final schedules = schedStr.map((s) => PickupSchedule.fromMap(jsonDecode(s))).toList();
    schedules.sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
    return schedules;
  }

  Future<void> deleteSchedule(String id) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> schedStr = prefs.getStringList(_scheduleKey) ?? [];
    schedStr.removeWhere((s) {
      final map = jsonDecode(s);
      return map['id'] == id;
    });
    await prefs.setStringList(_scheduleKey, schedStr);
  }
}
