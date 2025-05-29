import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_callkit_incoming/entities/android_params.dart';
import 'package:flutter_callkit_incoming/entities/call_event.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming/entities/ios_params.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:video_call_app/services/notification_service.dart';
import 'package:flutter/material.dart';

class CallService {
  static final CallService _instance = CallService._internal();
  factory CallService() => _instance;
  CallService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> initialize() async {
    FlutterCallkitIncoming.onEvent.listen((event) async {
      final Map<String, dynamic> body = event!.body;
      switch (event.event) {
        case Event.actionCallAccept:
          _startAgoraCall(
            channelId: body['channelId'],
            callerId: body['callerId'],
            isCaller: false,
          );
          break;
        case Event.actionCallDecline:
          _endCall(body['channelId']);
          break;
        case Event.actionCallEnded:
          _endCall(body['channelId']);
          break;
        default:
          break;
      }
    });
  }

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

    await FlutterCallkitIncoming.showCallkitIncoming(params);

    // Send FCM push
    await NotificationService().sendCallNotification(
      token: receiverToken,
      callerId: callerId,
      channelId: channelId,
    );

    // Update Firestore
    await _firestore.collection('calls').doc(channelId).set({
      'callerId': callerId,
      'receiverId': receiverId,
      'channelId': channelId,
      'status': 'calling',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  void _startAgoraCall({
    required String channelId,
    required String callerId,
    required bool isCaller,
  }) {
    // Navigate to CallScreen
    Navigator.of(NotificationService.navigatorKey.currentContext!).pushNamed(
      '/call',
      arguments: {
        'channelId': channelId,
        'callerId': callerId,
        'isCaller': isCaller,
      },
    );
  }

  Future<void> _endCall(String channelId) async {
    await FlutterCallkitIncoming.endCall(channelId);
    await _firestore.collection('calls').doc(channelId).update({
      'status': 'ended',
    });
  }

  String _generateChannelId() {
    return Random().nextInt(999999).toString();
  }
}
