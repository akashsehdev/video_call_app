import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
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
    await Firebase.initializeApp();
    debugPrint('🔄 Background FCM: ${message.messageId}');
    final data = message.data;
    if (data.containsKey('channelId')) {
      await FlutterCallkitIncoming.showCallkitIncoming(
        CallKitParams(
          id: data['channelId'],
          nameCaller: data['callerName'] ?? 'Unknown',
          appName: 'Video Call App',
          handle: 'Incoming Call',
          avatar: 'https://i.pravatar.cc/100',
          type: data['isVideoCall'] == 'true' ? 1 : 0,
          duration: 30000,
          extra: {
            'callerId': data['callerId'],
            'channelName': data['channelName'],
            'isVideoCall': data['isVideoCall'],
          },
          android: AndroidParams(
            isCustomNotification: true,
            isShowLogo: true,
            ringtonePath: 'system_ringtone_default',
            backgroundColor: '#0955fa',
          ),
          ios: IOSParams(iconName: 'CallKitIcon'),
        ),
      );
    }
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
    required String title,
    required String body,
    required String callerId,
    required String channelName,
    required bool isVideoCall,
  }) async {
    const String serverUrl =
        'http://localhost:3000/send-notification'; // Replace with deployed URL

    final response = await http.post(
      Uri.parse(serverUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'token': token,
        'title': title,
        'body': body,
        'callerId': callerId,
        'channelName': channelName,
        'isVideoCall': isVideoCall,
      }),
    );

    if (response.statusCode == 200) {
      debugPrint('✅ Call notification sent via server.');
    } else {
      debugPrint('❌ Failed to send call notification: ${response.body}');
    }
  }
}
