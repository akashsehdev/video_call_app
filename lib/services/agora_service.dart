import 'dart:convert';

import 'package:permission_handler/permission_handler.dart';
import 'package:video_call_app/services/call_log_service.dart';
import 'package:video_call_app/services/fcm_service.dart';
import 'package:video_call_app/utils/constants.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:http/http.dart' as http;

class AgoraTokenService {
  final String backendUrl;

  AgoraTokenService({required this.backendUrl});

  
  Future<String?> fetchToken(String channelName, String userAccount) async {
    final url = Uri.parse(
      '$backendUrl/token?channelName=$channelName&userAccount=$userAccount',
    );

    try {
      print('Fetching token from URL: $url');
      final response = await http.get(url);

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Token fetched: ${data['token']}');
        return data['token'] as String?;
      } else {
        print(
          'Failed to fetch token: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Error fetching token: $e');
    }

    return null;
  }
}

class AgoraService {
  static RtcEngine? _engine;

  /// Requests microphone and camera permissions.
  /// Returns true if all permissions are granted, false otherwise.
  static Future<bool> _handlePermissions() async {
    final statuses = await [Permission.microphone, Permission.camera].request();
    final allGranted = statuses.values.every((status) => status.isGranted);
    return allGranted;
  }

  /// Initializes the Agora RTC engine.
  /// Returns true if initialization succeeded, false otherwise.
  static Future<bool> initializeAgoraEngine() async {
    try {
      _engine = createAgoraRtcEngine();

      await _engine!.initialize(
        const RtcEngineContext(appId: Constants.agoraAppId),
      );

      await _engine!.enableVideo();

      _engine!.registerEventHandler(
        RtcEngineEventHandler(
          onJoinChannelSuccess: (connection, elapsed) {
            print(
              "Joined channel ${connection.channelId} with uid ${connection.localUid}",
            );
          },
          onUserJoined: (connection, remoteUid, elapsed) {
            print("Remote user $remoteUid joined");
          },
          onUserOffline: (connection, remoteUid, reason) {
            print("Remote user $remoteUid left");
          },
        ),
      );

      return true;
    } catch (e) {
      print("Agora engine initialization failed: $e");
      return false;
    }
  }

  /// Starts a call by:
  /// 1. Checking permissions
  /// 2. Initializing the Agora engine
  /// 3. Sending FCM call notification
  /// Returns true if all steps succeeded, false otherwise.
  static Future<bool> initiateCall({
    required String callerId,
    required String receiverId,
    bool isVideoCall = true,
  }) async {
    final channelId = 'channel_${DateTime.now().millisecondsSinceEpoch}';

    // Log the call (move this here)
    // await CallLogService.logCall("outgoing", channelId);

    // Inside initiateCall() just before/after initiating the Agora call
    await CallLogService.logCall(
      callerId: callerId,
      receiverId: receiverId,
      isVideoCall: isVideoCall,
      timestamp: DateTime.now(),
    );

    // TODO: Add your Agora SDK call initiation code here

    print('Agora call initiated from $callerId to $receiverId on $channelId');

    print('Starting call from $callerId to $receiverId');

    // Step 1: Check permissions
    final permissionsGranted = await _handlePermissions();
    if (!permissionsGranted) {
      print("Permissions not granted.");
      return false;
    }

    // Step 2: Initialize Agora engine
    final engineInitialized = await initializeAgoraEngine();
    if (!engineInitialized) {
      print("Failed to initialize Agora engine.");
      return false;
    }

    // Step 3: Prepare call details
    String channelName = 'call_${callerId}_$receiverId';
    // final channelName =
    //     'video_call_app'; // Should be unique or generated properly
    final agoraToken =
        Constants.agoraToken; // Should come from your backend ideally

    // Step 4: Send push notification for incoming call
    try {
      await FCMService.sendCallNotification(
        receiverId: receiverId,
        callerId: callerId,
        channelName: channelName,
        agoraToken: agoraToken!,
        isVideoCall: isVideoCall,
      );
    } catch (e) {
      print('Failed to send call notification: $e');
      return false;
    }

    return true;
  }
}
