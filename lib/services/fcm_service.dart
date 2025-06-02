//working properly
import 'dart:convert';
import 'dart:io'; // For Platform check
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/entities/call_event.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:http/http.dart' as http;
import 'package:video_call_app/main.dart';
import 'package:video_call_app/screens/call_screen.dart';
import 'package:video_call_app/services/agora_service.dart';
import 'package:video_call_app/utils/constants.dart';

class FCMService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // Initialize FCM and get token for the user
  static Future<String?> initFCM(String userId) async {
    await _messaging.requestPermission();

    String? token = await _messaging.getToken();
    print("FCM Token for $userId: $token");

    // Save FCM token to Firestore under user's document
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'deviceToken': token,
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Message clicked!: ${message.messageId}');
      print('🚀 onMessageOpenedApp: ${message.data}');

      // Add your notification tap handling here
    });

    return token;
  }

  void _setupCallKitListeners() {
    FlutterCallkitIncoming.onEvent.listen((event) {
      final eventData = event?.body;
      final extra = eventData?['extra'];

      switch (event?.event) {
        case Event.actionCallAccept:
          print('Call Accepted');

          // Make sure you have a way to access your navigator context
          // You can use a global key or pass context to the service when setting up listener

          // Example: If you have a global navigatorKey:
          final context = navigatorKey.currentState?.overlay?.context;
          if (context == null) {
            print('No context available for navigation');
            return;
          }

          CallHandlerService.startCall(
            context: context,
            callerId: extra?['callerId'] ?? '',
            receiverId: extra?['receiverId'] ?? '',
            isVideoCall: extra?['isVideoCall'] == 'true',
          );
          break;

        case Event.actionCallDecline:
          print('Call Declined');
          break;

        case Event.actionCallEnded:
          print('Call Ended');
          break;

        case Event.actionCallTimeout:
          print('Call Timed Out');
          break;

        case Event.actionCallCallback:
          print('Call Callback clicked');
          break;

        case Event.actionCallStart:
          print('Call Started');
          break;

        default:
          print('Other event: ${event?.event}');
      }
    });
  }

  // Helper method to get the correct backend URL depending on device/emulator
  static Uri getBackendUrl() {
    if (Platform.isAndroid) {
      // Android emulator special localhost alias
      return Uri.parse('${Constants.backendUrl}/send-notification');
      // return Uri.parse('http://192.168.1.8:3000/send-notification');
    } else {
      // For iOS simulator or physical devices (adjust your PC IP accordingly)
      return Uri.parse('${Constants.backendUrl}/send-notification');
      // return Uri.parse('http://192.168.1.8:3000/send-notification');
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

class CallHandlerService {
  static Future<void> startCall({
    required BuildContext context,
    required String callerId,
    required String receiverId,
    required bool isVideoCall,
  }) async {
    final channelId = 'call_${[callerId, receiverId].join("_")}';

    Constants.agoraToken = await AgoraTokenService(
      backendUrl: Constants.backendUrl,
    ).fetchToken(channelId, callerId);

    if (Constants.agoraToken == null) {
      print("Token is null, cannot proceed");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch token. Please try again.')),
      );
      return;
    }

    await AgoraService.initiateCall(
      callerId: callerId,
      receiverId: receiverId,
      isVideoCall: isVideoCall,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => CallScreen(
              channelId: channelId,
              userId: callerId,
              token: Constants.agoraToken!,
            ),
      ),
    );
  }
}
