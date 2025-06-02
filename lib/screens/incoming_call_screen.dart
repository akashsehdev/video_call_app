import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_call_app/screens/call_screen.dart';

class IncomingCallScreen extends StatelessWidget {
  static const String routeName = '/incoming_call'; // <-- Add this line

  final String callerId;
  final String channelId;
  final String agoraToken;
  final bool isVideoCall;
  final String receiverId;

  const IncomingCallScreen({
    super.key,
    required this.callerId,
    required this.channelId,
    required this.agoraToken,
    required this.isVideoCall,
    required this.receiverId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Incoming Calls',
          style: GoogleFonts.montserrat(
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Center(
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: GoogleFonts.montserrat(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color:
                          Colors.black, // You must specify color for TextSpan
                    ),
                    children: [
                      TextSpan(text: '$callerId\n'),

                      TextSpan(
                        text: 'is calling you...',
                        style: GoogleFonts.montserrat(
                          fontSize: 20,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => CallScreen(
                                channelId: channelId,
                                userId: receiverId,
                                token: agoraToken,
                                isCaller: false,
                              ),
                        ),
                      );
                    },
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        border: Border.all(width: 0.5, color: Colors.grey),
                        borderRadius: BorderRadius.circular(60),
                      ),
                      child: const Icon(
                        Icons.call_rounded,
                        color: Colors.green,
                        size: 30,
                      ),
                    ),
                  ),
                  SizedBox(),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      // Optionally notify backend about decline here
                    },
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.2),
                        border: Border.all(width: 0.5, color: Colors.grey),
                        borderRadius: BorderRadius.circular(60),
                      ),
                      child: const Icon(
                        Icons.call_end_rounded,
                        color: Colors.red,
                        size: 30,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
