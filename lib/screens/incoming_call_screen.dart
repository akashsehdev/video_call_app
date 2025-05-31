import 'package:flutter/material.dart';
import 'package:video_call_app/screens/call_screen.dart';
import 'package:video_call_app/utils/constants.dart';

class IncomingCallScreen extends StatelessWidget {
  final String callerId;
  final String channelId;
  final String agoraToken;
  final bool isVideoCall;
  final String receiverId;

  IncomingCallScreen({
    required this.callerId,
    required this.channelId,
    required this.agoraToken,
    required this.isVideoCall,
    required this.receiverId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('User $callerId is calling you...'),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => CallScreen(
                          channelId: channelId,
                          userId:
                              receiverId, // Use callerId as userId or pass actual receiverId
                          token: agoraToken,
                          isCaller: false,
                        ),
                  ),
                );
              },
              child: Text('Accept'),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // Optionally notify backend about decline here
              },
              child: Text('Decline'),
            ),
          ],
        ),
      ),
    );
  }
}
