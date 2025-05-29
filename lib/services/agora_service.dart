// import 'package:video_call_app/services/fcm_service.dart';

// class AgoraService {
//   static Future<void> initiateCall({
//     required String callerId,
//     required String receiverId,
//     bool isVideoCall = true, // default video call
//   }) async {
//     print('Starting call from $callerId to $receiverId');

//     // 1. Generate channel name (e.g., concatenation of user IDs)
//     String channelName = 'call_${callerId}_$receiverId';

//     // 2. Generate Agora token - usually done by calling your backend or token server
//     // For demo, use empty string or dummy token, replace with your token generation logic
//     String agoraToken = await _getAgoraToken(channelName, callerId);

//     // 3. Send FCM notification to receiver with call details
//     await FCMService.sendCallNotification(
//       receiverId: receiverId,
//       callerId: callerId,
//       channelName: channelName,
//       agoraToken: agoraToken,
//       isVideoCall: isVideoCall,
//     );

//     // 4. Join Agora channel as caller - your app needs to implement this part (not shown here)
//     // For example: await AgoraClient.joinChannel(token: agoraToken, channel: channelName, uid: callerId);
//   }

//   static Future<String> _getAgoraToken(
//     String channelName,
//     String userId,
//   ) async {
//     // TODO: Replace with your token generation logic
//     // This usually calls your backend API which creates a token for this channel and user ID
//     return '';
//   }
// }

import 'package:flutter/material.dart';
import 'package:video_call_app/services/fcm_service.dart';
import 'package:video_call_app/screens/call_screen.dart';
import 'package:video_call_app/utils/constants.dart';

class AgoraService {
  static const String agoraAppId =
      Constants.agoraAppId; // Replace with your actual App ID
  static const String tempToken =
      Constants.agoraToken; // Replace with token from Agora Console

  static Future<void> initiateCall({
    required BuildContext context,
    required String callerId,
    required String receiverId,
    bool isVideoCall = true,
  }) async {
    print('Starting call from $callerId to $receiverId');

    // 1. Generate channel name
    String channelName = 'call_${callerId}_$receiverId';

    // 2. Use the temporary token
    String agoraToken = tempToken;

    // 3. Send FCM notification with call details
    await FCMService.sendCallNotification(
      receiverId: receiverId,
      callerId: callerId,
      channelName: channelName,
      agoraToken: agoraToken,
      isVideoCall: isVideoCall,
    );

    // 4. Join Agora channel (as caller)
    // In agora_service.dart
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => CallScreen(
              channelId: channelName,
              token: agoraToken,
              userId: callerId,
            ),
      ),
    );
  }
}
