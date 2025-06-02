import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_call_app/screens/call_screen.dart';
import 'package:video_call_app/utils/constants.dart';
import '../services/agora_service.dart';

class CallUserScreen extends StatelessWidget {
  final String callerId;
  final String receiverId;
  final String receiverName;

  const CallUserScreen({
    super.key,
    required this.callerId,
    required this.receiverId,
    required this.receiverName,
  });

  void _startCall(BuildContext context, {required bool isVideoCall}) async {
    final channelId = 'call_${[callerId, receiverId].join("_")}';

    // Step 1: Fetch token first
    // Constants.agoraToken = await AgoraTokenService(
    //   backendUrl: Constants.backendUrl, // <-- adjust based on your environment
    // ).fetchToken(channelId, callerId);
    Constants.agoraToken = await AgoraTokenService(
      backendUrl: Constants.backendUrl, // <-- adjust based on your environment
      // 'http://192.168.1.8:3000', // <-- adjust based on your environment
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
              token: Constants.agoraToken!, // ✅ Now it's safe
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Calling Screen",
          style: GoogleFonts.montserrat(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 0.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Call $receiverName',
                style: GoogleFonts.montserrat(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '"You can call this user $receiverName"',
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),

              const SizedBox(height: 200),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () => _startCall(context, isVideoCall: false),
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        border: Border.all(width: 0.5, color: Colors.grey),
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: const Icon(Icons.call, color: Colors.green),
                    ),
                  ),

                  GestureDetector(
                    onTap: () => _startCall(context, isVideoCall: true),
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        border: Border.all(width: 0.5, color: Colors.grey),
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: const Icon(
                        Icons.video_call,
                        size: 28,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  // ElevatedButton(
                  //   onPressed: () => _startCall(context, isVideoCall: false),
                  //   child: Icon(Icons.call, size: 30),
                  // ),
                  // ElevatedButton(
                  //   onPressed: () => _startCall(context, isVideoCall: true),
                  //   child: Icon(Icons.videocam, size: 30),
                  // ),
                ],
              ),
            ],
          ),
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
