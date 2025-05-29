// import 'dart:convert';
// import 'package:shared_preferences/shared_preferences.dart';

// class CallLogService {
//   static const _key = 'call_logs';

//   static Future<void> logCall(String type, String channelId) async {
//     final prefs = await SharedPreferences.getInstance();
//     final logs = prefs.getStringList(_key) ?? [];
//     logs.add(
//       jsonEncode({
//         'timestamp': DateTime.now().toIso8601String(),
//         'type': type,
//         'channelId': channelId,
//       }),
//     );
//     await prefs.setStringList(_key, logs);
//   }

//   static Future<List<Map<String, dynamic>>> getLogs() async {
//     final prefs = await SharedPreferences.getInstance();
//     final logs = prefs.getStringList(_key) ?? [];
//     return logs.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
//   }

//   static Future<void> clearLogs() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove(_key);
//   }
// }
