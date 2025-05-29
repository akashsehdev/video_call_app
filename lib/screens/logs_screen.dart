// import 'package:flutter/material.dart';
// import '../services/call_log_service.dart';

// class LogsScreen extends StatefulWidget {
//   @override
//   _LogsScreenState createState() => _LogsScreenState();
// }

// class _LogsScreenState extends State<LogsScreen> {
//   List<Map<String, dynamic>> _logs = [];

//   @override
//   void initState() {
//     super.initState();
//     _loadLogs();
//   }

//   Future<void> _loadLogs() async {
//     final logs = await CallLogService.getLogs();
//     setState(() => _logs = logs);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Call Logs')),
//       body:
//           _logs.isEmpty
//               ? Center(child: Text('No calls logged'))
//               : ListView.builder(
//                 itemCount: _logs.length,
//                 itemBuilder: (context, index) {
//                   final log = _logs[index];
//                   return ListTile(
//                     title: Text('${log['type']}'),
//                     subtitle: Text('${log['timestamp']}'),
//                     trailing: Text('Channel: ${log['channelId']}'),
//                   );
//                 },
//               ),
//     );
//   }
// }
