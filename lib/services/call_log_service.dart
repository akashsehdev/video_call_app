import 'package:cloud_firestore/cloud_firestore.dart';

class CallLogService {
  static final _firestore = FirebaseFirestore.instance;

  static Future<void> logCall({
    required String callerId,
    required String receiverId,
    required bool isVideoCall,
    required DateTime timestamp,
  }) async {
    await _firestore.collection('call_logs').add({
      'callerId': callerId,
      'receiverId': receiverId,
      'isVideoCall': isVideoCall,
      'timestamp': timestamp,
    });
  }

  static Future<List<Map<String, dynamic>>> getLogs() async {
    final snapshot =
        await _firestore
            .collection('call_logs')
            .orderBy('timestamp', descending: true)
            .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }
}
