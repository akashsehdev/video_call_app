import 'package:flutter/material.dart';
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
    // Call your AgoraService with appropriate parameters
    await AgoraService.initiateCall(
      context: context,
      callerId: callerId,
      receiverId: receiverId,
      isVideoCall: isVideoCall,
    );
    // You can add navigation or loading UI as needed
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
