import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_callkit_incoming/entities/android_params.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming/entities/ios_params.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';

import 'package:http/http.dart' as http;

class NotificationService {
  // Global navigator key to be used for navigation from notifications
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  // Singleton instance
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// Initialize Firebase Messaging and set up listeners
  Future<void> initialize() async {
    await _requestPermissions();

    // Foreground message handler
    FirebaseMessaging.onMessage.listen(_onMessageReceived);

    // Notification tap (app in background or foreground)
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);

    // Background message handler registration
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  /// Request notification permissions (iOS/Android)
  Future<void> _requestPermissions() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    debugPrint('User granted permission: ${settings.authorizationStatus}');
  }

  Future<void> _showIncomingCall(Map<String, dynamic> data) async {
    final params = CallKitParams(
      id: data['channelId'],
      nameCaller: data['callerName'] ?? 'Unknown Caller',
      appName: 'Video Call App',
      avatar: 'https://i.pravatar.cc/100', // Optional avatar URL
      handle: 'Incoming Call',
      type: data['isVideoCall'] == 'true' ? 1 : 0, // 0 = audio, 1 = video
      duration: 30000,
      textAccept: 'Accept',
      textDecline: 'Decline',
      // textMissedCall: 'Missed call',
      // textCallback: 'Call back',
      extra: {
        'callerId': data['callerId'],
        'agoraToken': data['agoraToken'],
        'channelName': data['channelName'],
      },
      android: AndroidParams(
        isCustomNotification: true,
        isShowLogo: true,
        isShowCallID: true,
        ringtonePath: 'system_ringtone_default',
        backgroundColor: '#0955fa',
        backgroundUrl: 'system_background_default',
      ),
      ios: IOSParams(iconName: 'CallKitIcon', handleType: 'generic'),
    );

    await FlutterCallkitIncoming.showCallkitIncoming(params);
  }

  /// Retrieves the FCM device token
  Future<String?> getToken() async {
    return await _messaging.getToken();
  }

  /// Handles incoming foreground messages
  void _onMessageReceived(RemoteMessage message) {
    debugPrint('Foreground message received: ${message.messageId}');
    _handleMessageData(message.data);
  }

  /// Handles notification taps when the app is opened from background/foreground
  void _onMessageOpenedApp(RemoteMessage message) {
    debugPrint('Notification clicked: ${message.messageId}');
    _handleMessageData(message.data);
  }

  /// Background message handler
  static Future<void> _firebaseMessagingBackgroundHandler(
    RemoteMessage message,
  ) async {
    debugPrint('Handling background message: ${message.messageId}');
    // You can perform background processing here if needed
  }

  /// Process notification data payload
  // void _handleMessageData(Map<String, dynamic> data) {
  //   if (data.containsKey('channelId') && data.containsKey('callerId')) {
  //     // TODO: Add your call screen launching or CallKit logic here
  //     debugPrint('Incoming call from callerId: ${data['callerId']} on channelId: ${data['channelId']}');
  //   }
  // }
  void _handleMessageData(Map<String, dynamic> data) {
    if (data.containsKey('channelId') && data.containsKey('callerId')) {
      debugPrint(
        'Incoming call from callerId: ${data['callerId']} on channelId: ${data['channelId']}',
      );
      // ✅ Show incoming call UI
      _showIncomingCall(data); // Add this line
    }
  }

  /// Sends a call notification to a specific device token using FCM HTTP API
  Future<void> sendCallNotification({
    required String token,
    required String callerId,
    required String channelId,
  }) async {
    const String serverKey = 'YOUR_SERVER_KEY_FROM_FIREBASE_PROJECT_SETTINGS';

    final Map<String, dynamic> message = {
      'to': token,
      'data': {'type': 'call', 'callerId': callerId, 'channelId': channelId},
      'priority': 'high',
    };

    final response = await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverKey',
      },
      body: jsonEncode(message),
    );

    if (response.statusCode == 200) {
      debugPrint('✅ Push notification sent successfully');
    } else {
      debugPrint('❌ Failed to send notification: ${response.body}');
    }
  }
}
