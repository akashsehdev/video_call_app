import 'package:flutter/material.dart';
import 'package:video_call_app/screens/call_screen.dart';
import 'package:video_call_app/utils/constants.dart';
import '../services/agora_service.dart';

class CallUserScreen extends StatelessWidget {
  final String callerId;
  final String receiverId;
  final String receiverName;

  const CallUserScreen({
    Key? key,
    required this.callerId,
    required this.receiverId,
    required this.receiverName,
  }) : super(key: key);

  void _startCall(BuildContext context, {required bool isVideoCall}) async {
    final channelId = 'call_${[callerId, receiverId].join("_")}';

    // Step 1: Fetch token first
    Constants.agoraToken = await AgoraTokenService(
      backendUrl:
          'http://192.168.1.45:3000', // <-- adjust based on your environment
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

    // // Then navigate (no token needed if your CallScreen reads it from Firestore or server)
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder:
    //         (_) => CallScreen(
    //           channelId: channelId,
    //           userId: callerId,
    //           token:
    //               Constants.agoraToken!, // or fetch from Firestore in CallScreen
    //         ),
    //   ),
    // );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => CallScreen(
              channelId: channelId,
              userId: callerId,
              token: Constants.agoraToken!, // ✅ Now it's safe
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Call $receiverName")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Call $receiverName', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: const Icon(Icons.call),
              label: const Text("Audio Call"),
              onPressed: () => _startCall(context, isVideoCall: false),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.videocam),
              label: const Text("Video Call"),
              onPressed: () => _startCall(context, isVideoCall: true),
            ),
          ],
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:video_call_app/screens/call_screen.dart';
// import 'package:video_call_app/utils/constants.dart';
// import '../services/agora_service.dart';

// class CallUserScreen extends StatelessWidget {
//   final String callerId;
//   final String receiverId;
//   final String receiverName;

//   const CallUserScreen({
//     super.key,
//     required this.callerId,
//     required this.receiverId,
//     required this.receiverName,
//   });

//   void _startCall(BuildContext context, {required bool isVideoCall}) async {
//     bool success = await AgoraService.initiateCall(
//       callerId: callerId,
//       receiverId: receiverId,
//       isVideoCall: isVideoCall,
//     );

//     if (success && context.mounted) {
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder:
//               (_) => CallScreen(
//                 channelId: 'video_call_app',
//                 token: Constants.agoraToken,
//                 userId: callerId,
//                 // isVideoCall: isVideoCall,
//               ),
//         ),
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to start call. Please try again.')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Call $receiverName")),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text('Call $receiverName', style: TextStyle(fontSize: 24)),
//             const SizedBox(height: 30),
//             ElevatedButton.icon(
//               icon: const Icon(Icons.call),
//               label: const Text("Audio Call"),
//               onPressed: () => _startCall(context, isVideoCall: false),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton.icon(
//               icon: const Icon(Icons.videocam),
//               label: const Text("Video Call"),
//               onPressed: () => _startCall(context, isVideoCall: true),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
