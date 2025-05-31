import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_callkit_incoming/entities/android_params.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming/entities/ios_params.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:video_call_app/main.dart';
import 'package:video_call_app/screens/call_screen.dart';
import 'package:video_call_app/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:video_call_app/utils/constants.dart';

class CallService {
  // Singleton setup
  static final CallService _instance = CallService._internal();
  factory CallService() => _instance;
  CallService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Call this method when your app starts or user logs in
  Future<void> initialize(String userId) async {
    // Update current user's FCM token in Firestore
    await _updateUserFcmToken(userId);

    FlutterCallkitIncoming.onEvent.listen((event) async {
      if (event == null) return;

      final Map<String, dynamic> data = event.body['extra'] ?? {};

      switch (event.event) {
        case 'CALL_ACCEPT':
          final String channelId = data['channelId'];
          final String callerId = data['callerId'];
          final String callerName = data['callerName'] ?? 'Unknown';

          // Start the Agora call logic
          _startAgoraCall(
            channelId: channelId,
            callerId: callerId,
            isCaller: false,
          );

          // Navigate to call screen
          navigatorKey.currentState?.push(
            MaterialPageRoute(
              builder:
                  (_) => CallScreen(
                    channelId: channelId,
                    token: Constants.agoraToken!,
                    userId: userId,
                  ),
            ),
          );
          break;

        case 'CALL_DECLINE':
        case 'CALL_ENDED':
          final String? channelId = data['channelId'];
          if (channelId != null) {
            await _endCall(channelId);
          }
          break;

        default:
          debugPrint('Unhandled CallKit event: ${event.event}');
          break;
      }
    });
  }

  /// Update the current user's FCM token in Firestore
  Future<void> _updateUserFcmToken(String userId) async {
    try {
      String? token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await _firestore.collection("users").doc(userId).set({
          "fcmToken": token,
        }, SetOptions(merge: true));
        print("FCM token updated for user $userId");
      }
    } catch (e) {
      print("Error updating FCM token: $e");
    }
  }

  /// Initiate a call using CallKit and send FCM notification
  Future<void> makeCall({
    required String callerId,
    required String receiverId,
    required String receiverToken,
  }) async {
    final String channelId = _generateChannelId();

    final params = CallKitParams(
      id: channelId,
      nameCaller: callerId,
      appName: 'VideoCallApp',
      avatar: 'https://i.imgur.com/3s0a6fh.png',
      handle: receiverId,
      type: 0,
      duration: 30000,
      textAccept: 'Accept',
      textDecline: 'Decline',
      extra: {
        'channelId': channelId,
        'callerId': callerId,
        'receiverId': receiverId,
      },
      headers: {},
      android: const AndroidParams(
        isCustomNotification: true,
        isShowLogo: true,
        ringtonePath: 'system_ringtone_default',
        backgroundColor: '#0955fa',
        backgroundUrl: 'https://i.imgur.com/3s0a6fh.png',
        actionColor: '#4CAF50',
      ),
      ios: const IOSParams(
        iconName: 'CallKitIcon',
        handleType: '',
        supportsVideo: true,
        audioSessionMode: 'default',
        audioSessionActive: true,
        supportsDTMF: true,
        supportsHolding: true,
        supportsGrouping: false,
        supportsUngrouping: false,
      ),
    );

    // Show incoming call UI
    // await FlutterCallkitIncoming.showCallkitIncoming(params);
    await FlutterCallkitIncoming.showCallkitIncoming(
      CallKitParams(
        id: channelId,
        nameCaller: callerId,
        appName: 'MyApp',
        // ... other parameters
      ),
    );

    // Send push notification via FCM
    await NotificationService().sendCallNotification(
      token: receiverToken,
      title: 'Incoming Call',
      body: 'You have an incoming video call',
      callerId: callerId,
      channelName: channelId,
      isVideoCall: true,
    );

    // Save call info in Firestore
    await _firestore.collection('calls').doc(channelId).set({
      'callerId': callerId,
      'receiverId': receiverId,
      'channelId': channelId,
      'status': 'calling',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// Navigate to the Agora call screen
  void _startAgoraCall({
    required String channelId,
    required String callerId,
    required bool isCaller,
  }) {
    Navigator.of(NotificationService.navigatorKey.currentContext!).pushNamed(
      '/call',
      arguments: {
        'channelId': channelId,
        'callerId': callerId,
        'isCaller': isCaller,
      },
    );
  }

  /// End the call and update Firestore
  Future<void> _endCall(String channelId) async {
    await FlutterCallkitIncoming.endCall(channelId);
    await _firestore.collection('calls').doc(channelId).update({
      'status': 'ended',
    });
  }

  /// Generate a random numeric channel ID
  String _generateChannelId() {
    return Random().nextInt(999999).toString();
  }
}
