// import 'dart:convert';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:http/http.dart' as http;

// class FCMService {
//   static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

//   // Initialize FCM and get token for the user
//   static Future<String?> initFCM(String userId) async {
//     await _messaging.requestPermission();

//     String? token = await _messaging.getToken();
//     if (token != null) {
//       print("FCM Token for $userId: $token");

//       // Save FCM token to Firestore under user's document
//       await FirebaseFirestore.instance.collection('users').doc(userId).update({
//         'deviceToken': token,
//       });
//     }

//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       print('Received a message while in foreground: ${message.messageId}');
//       // You can add logic here to handle incoming foreground messages (show notification/dialog etc.)
//     });

//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//       print('Message clicked!: ${message.messageId}');
//       // Handle when the app is opened from notification tap
//     });

//     return token;
//   }

//   // Send a call notification to a receiver using Firebase Cloud Messaging HTTP API
//   // IMPORTANT: You must replace 'YOUR_SERVER_KEY' with your Firebase Cloud Messaging server key from Firebase Console
//   static Future<void> sendCallNotification({
//     required String receiverId,
//     required String callerId,
//     required String channelName,
//     required String agoraToken,
//     required bool isVideoCall,
//   }) async {
//     // Get receiver's device token from Firestore
//     final receiverDoc =
//         await FirebaseFirestore.instance
//             .collection('users')
//             .doc(receiverId)
//             .get();
//     final deviceToken = receiverDoc.data()?['deviceToken'];
//     if (deviceToken == null) {
//       print('Receiver device token not found!');
//       return;
//     }

//     // Your local backend URL (adjust if running on an actual device/emulator)
//     // final postUrl = Uri.parse('http://localhost:3000/send-notification');
//     final postUrl = Uri.parse('http://192.168.1.45:3000/send-notification');

//     final notificationPayload = {
//       "token": deviceToken,
//       "title": 'Incoming ${isVideoCall ? 'Video' : 'Audio'} Call',
//       "body": 'User $callerId is calling you',
//       // optionally you can add extra data if your backend supports it
//       "data": {
//         'type': 'call',
//         'callerId': callerId,
//         'channelName': channelName,
//         'agoraToken': agoraToken,
//         'isVideoCall': isVideoCall.toString(),
//       },
//     };

//     try {
//       final response = await http.post(
//         postUrl,
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode(notificationPayload),
//       );

//       if (response.statusCode == 200) {
//         print('Call notification sent successfully');
//         print('Response body: ${response.body}');
//       } else {
//         print(
//           'Failed to send call notification. Status code: ${response.statusCode}',
//         );
//         print('Response body: ${response.body}');
//       }
//     } catch (e) {
//       print('Error sending call notification: $e');
//     }
//   }
// }

import 'dart:convert';
import 'dart:io'; // For Platform check
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

class FCMService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // Initialize FCM and get token for the user
  static Future<String?> initFCM(String userId) async {
    await _messaging.requestPermission();

    String? token = await _messaging.getToken();
    if (token != null) {
      print("FCM Token for $userId: $token");

      // Save FCM token to Firestore under user's document
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'deviceToken': token,
      });
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received a message while in foreground: ${message.messageId}');
      // Add your foreground message handling here
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Message clicked!: ${message.messageId}');
      // Add your notification tap handling here
    });

    return token;
  }

  // Helper method to get the correct backend URL depending on device/emulator
  static Uri getBackendUrl() {
    if (Platform.isAndroid) {
      // Android emulator special localhost alias
      return Uri.parse('http://10.0.2.2:3000/send-notification');
    } else {
      // For iOS simulator or physical devices (adjust your PC IP accordingly)
      return Uri.parse('http://192.168.1.45:3000/send-notification');
    }
  }

  // Send a call notification to a receiver using Firebase Cloud Messaging HTTP API
  static Future<void> sendCallNotification({
    required String receiverId,
    required String callerId,
    required String channelName,
    required String agoraToken,
    required bool isVideoCall,
  }) async {
    // Get receiver's device token from Firestore
    final receiverDoc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(receiverId)
            .get();
    final deviceToken = receiverDoc.data()?['deviceToken'];
    if (deviceToken == null) {
      print('Receiver device token not found!');
      return;
    }

    final postUrl = getBackendUrl();

    final notificationPayload = {
      "token": deviceToken,
      "title": 'Incoming ${isVideoCall ? 'Video' : 'Audio'} Call',
      "body": 'User $callerId is calling you',
      "data": {
        'type': 'call',
        'callerId': callerId,
        'channelName': channelName,
        'agoraToken': agoraToken,
        'isVideoCall': isVideoCall.toString(),
      },
    };

    try {
      final response = await http.post(
        postUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(notificationPayload),
      );

      if (response.statusCode == 200) {
        print('Call notification sent successfully');
        print('Response body: ${response.body}');
      } else {
        print(
          'Failed to send call notification. Status code: ${response.statusCode}',
        );
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error sending call notification: $e');
    }
  }
}
