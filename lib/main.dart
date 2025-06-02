//3rd testing working properly
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/entities/android_params.dart';
import 'package:flutter_callkit_incoming/entities/call_event.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming/entities/ios_params.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_call_app/screens/home_screen.dart';
import 'package:video_call_app/screens/incoming_call_screen.dart';
import 'package:video_call_app/services/agora_service.dart';
import 'package:video_call_app/utils/constants.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('📦 Background message: ${message.messageId}');
  // Background message processing (e.g., save call data locally)
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Register background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Listen to FlutterCallkitIncoming events (accept, decline, etc)
  FlutterCallkitIncoming.onEvent.listen(_handleCallKitEvent);

  // Listen for foreground messages with type 'call'
  FirebaseMessaging.onMessage.listen((message) {
    if (message.data['type'] == 'call') {
      _showIncomingCall(message.data);
    }
  });

  // Listen when app is opened from notification tap
  FirebaseMessaging.onMessageOpenedApp.listen((message) {
    if (message.data['type'] == 'call') {
      _showIncomingCallScreen(message.data);
    }
  });

  // Handle app launch via notification tap
  final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
  if (initialMessage != null && initialMessage.data['type'] == 'call') {
    _showIncomingCallScreen(initialMessage.data);
  }

  runApp(const MyApp());
}

void _handleCallKitEvent(CallEvent? event) async {
  if (event == null) return;

  print("📞 CallKit event: ${event.event}");
  switch (event.event) {
    case Event.actionCallAccept:
      final extraRaw = event.body['extra'];
      if (extraRaw is Map) {
        final data = Map<String, dynamic>.from(extraRaw);
        _showIncomingCallScreen(data);
      }
      break;

    case Event.actionCallDecline:
    case Event.actionCallEnded:
    case Event.actionCallTimeout:
      // Optionally handle decline, end, timeout events here
      break;

    default:
      break;
  }
}

Future<void> _showIncomingCall(Map<String, dynamic> data) async {
  // final prefs = await SharedPreferences.getInstance();
  // final receiverId = prefs.getString('userId') ?? 'Unknown';

  final params = CallKitParams(
    id: data['channelId'] ?? '',
    nameCaller: data['callerId'] ?? 'Unknown Caller',
    appName: 'Video Call App',
    avatar: 'https://i.pravatar.cc/100',
    handle: 'Incoming Call',
    type: (data['isVideoCall']?.toString() == 'true') ? 1 : 0,
    duration: 30000,
    textAccept: 'Accept',
    textDecline: 'Decline',
    extra: {
      'callerId': data['callerId'],
      'agoraToken': data['agoraToken'],
      'channelName': data['channelName'],
      'isVideoCall': data['isVideoCall'],
    },
    android: AndroidParams(
      isCustomNotification: true,
      isShowLogo: true,
      isShowCallID: true,
      ringtonePath: 'system_ringtone_default',
      backgroundColor: '#0955fa',
      backgroundUrl: 'system_background_default',
    ),
    ios: IOSParams(iconName: 'CallKitIcon', handleType: 'generic'),
  );

  await FlutterCallkitIncoming.showCallkitIncoming(params);
}

void _showIncomingCallScreen(Map<String, dynamic> data) {
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    try {
      final callerId = data['callerId'] ?? 'Unknown';
      final channelId = data['channelName'] ?? 'default_channel';
      final isVideoCall = (data['isVideoCall']?.toString() == 'true');

      final prefs = await SharedPreferences.getInstance();
      final receiverId = prefs.getString('userId') ?? 'Unknown';

      final tokenService = AgoraTokenService(backendUrl: Constants.backendUrl);
      final agoraToken = await tokenService.fetchToken(channelId, receiverId);

      if (agoraToken == null) {
        print('Error: Agora token is null. Cannot show incoming call screen.');
        return;
      }

      // Prevent pushing duplicate IncomingCallScreen if already on it
      bool isCurrentIncomingCallScreen = false;
      navigatorKey.currentState?.popUntil((route) {
        if (route.settings.name == IncomingCallScreen.routeName) {
          isCurrentIncomingCallScreen = true;
        }
        return true;
      });

      if (!isCurrentIncomingCallScreen) {
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder:
                (_) => IncomingCallScreen(
                  receiverId: receiverId,
                  callerId: callerId,
                  channelId: channelId,
                  agoraToken: agoraToken,
                  isVideoCall: isVideoCall,
                ),
            settings: RouteSettings(name: IncomingCallScreen.routeName),
          ),
        );
      }
    } catch (e, stackTrace) {
      print('Error showing incoming call screen: $e');
      print(stackTrace);
    }
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Video Call App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: const HomeScreen(),
    );
  }
}
