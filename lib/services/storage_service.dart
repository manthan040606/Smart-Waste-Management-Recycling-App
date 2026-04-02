import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/waste_log.dart';

class StorageService {
  static const String _wasteLogsKey = 'wasteLogs';

  Future<void> saveWasteLog(WasteLog log) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> logsList = prefs.getStringList(_wasteLogsKey) ?? [];
    logsList.add(jsonEncode(log.toMap()));
    await prefs.setStringList(_wasteLogsKey, logsList);
  }

  Future<List<WasteLog>> getWasteLogs() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> logsList = prefs.getStringList(_wasteLogsKey) ?? [];
    return logsList.map((logStr) => WasteLog.fromMap(jsonDecode(logStr))).toList();
  }
}
