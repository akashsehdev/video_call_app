// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:video_call_app/screens/home_screen.dart';
// import 'package:video_call_app/screens/incoming_call_screen.dart';
// import 'package:video_call_app/services/notification_service.dart';
// import 'package:video_call_app/services/call_service.dart';

// final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   print('Handling a background message: ${message.messageId}');
//   // You can save call data here or trigger a local notification.
//   // But no UI interaction can be done here directly.
// }

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();

//   FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

//   await NotificationService().initialize();
//   await CallService().initialize();

//   // Set up Firebase Messaging handlers
//   FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//     print('Foreground message received: ${message.messageId}');
//     if (message.data['type'] == 'call') {
//       _showIncomingCallScreen(message.data);
//     }
//   });

//   FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//     print('Notification clicked: ${message.messageId}');
//     if (message.data['type'] == 'call') {
//       _showIncomingCallScreen(message.data);
//     }
//   });

//   // Check if app was opened from a terminated state via notification tap
//   FirebaseMessaging.instance.getInitialMessage().then((message) {
//     if (message != null && message.data['type'] == 'call') {
//       _showIncomingCallScreen(message.data);
//     }
//   });

//   runApp(MyApp());
// }

// void _showIncomingCallScreen(Map<String, dynamic> data) {
//   navigatorKey.currentState?.push(
//     MaterialPageRoute(
//       builder:
//           (_) => IncomingCallScreen(
//             callerId: data['callerId'],
//             channelId: data['channelName'],
//             agoraToken: data['agoraToken'],
//             isVideoCall: data['isVideoCall'] == 'true',
//           ),
//     ),
//   );
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       navigatorKey: navigatorKey,
//       title: 'Video Call App',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(primarySwatch: Colors.indigo),
//       home: const HomeScreen(),
//     );
//   }
// }

//2nd testing
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:video_call_app/screens/home_screen.dart';
// import 'package:video_call_app/screens/incoming_call_screen.dart';
// import 'package:video_call_app/services/notification_service.dart';
// import 'package:video_call_app/services/call_service.dart';

// final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp();
//   print('Handling a background message: ${message.messageId}');
//   // Handle background logic here if needed (no UI)
// }

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();

//   FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

//   await NotificationService().initialize(); // Initialize local notifications
//   await CallService().initialize();

//   // Set up foreground message handler with local notification display
//   FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//     print('Foreground message received: ${message.messageId}');

//     // Show local notification (delegated to NotificationService)
//     // NotificationService().showNotification(message);

//     // Handle call notification specially
//     if (message.data['type'] == 'call') {
//       _showIncomingCallScreen(message.data);
//     }
//   });

//   // Handle user tapping on a notification (app in background or terminated)
//   FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//     print('Notification clicked: ${message.messageId}');
//     if (message.data['type'] == 'call') {
//       _showIncomingCallScreen(message.data);
//     }
//   });

//   // Handle app opened from terminated state by tapping notification
//   final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
//   if (initialMessage != null && initialMessage.data['type'] == 'call') {
//     _showIncomingCallScreen(initialMessage.data);
//   }

//   runApp(const MyApp());
// }

// void _showIncomingCallScreen(Map<String, dynamic> data) {
//   navigatorKey.currentState?.push(
//     MaterialPageRoute(
//       builder:
//           (_) => IncomingCallScreen(
//             callerId: data['callerId'],
//             channelId: data['channelName'],
//             agoraToken: data['agoraToken'],
//             isVideoCall: data['isVideoCall'] == 'true',
//           ),
//     ),
//   );
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       navigatorKey: navigatorKey,
//       title: 'Video Call App',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(primarySwatch: Colors.indigo),
//       home: const HomeScreen(),
//     );
//   }
// }

//3rd testing
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_call_app/screens/home_screen.dart';
import 'package:video_call_app/screens/incoming_call_screen.dart';
import 'package:video_call_app/services/agora_service.dart';
import 'package:video_call_app/services/notification_service.dart';
import 'package:video_call_app/services/call_service.dart';
import 'package:video_call_app/utils/constants.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('📦 Background message: ${message.messageId}');
  // You can process background logic here (like storing to local DB)
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await NotificationService().initialize();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final userId = prefs.getString('userId');

  if (userId != null) {
    await CallService().initialize(userId);
  }

  debugPrint('User ID: ${userId}');

  // Run app first
  runApp(const MyApp());

  // Now safe to use navigatorKey
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    if (message.data['type'] == 'call') {
      _showIncomingCallScreen(message.data);
    }
  });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    if (message.data['type'] == 'call') {
      _showIncomingCallScreen(message.data);
    }
  });

  final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
  if (initialMessage != null && initialMessage.data['type'] == 'call') {
    _showIncomingCallScreen(initialMessage.data);
  }
}

// void _showIncomingCallScreen(Map<String, dynamic> data) async {
//   WidgetsBinding.instance.addPostFrameCallback((_) async {
//     try {
//       final callerId = data['callerId'] ?? 'Unknown';
//       final channelId = data['channelName'] ?? 'default_channel';
//       final agoraToken = Constants.agoraToken;
//       final isVideoCall =
//           (data['isVideoCall']?.toString() ?? 'false') == 'true';

//       print('📞 Incoming call from: $callerId');

//       // ✅ Fetch receiverId from SharedPreferences
//       final prefs = await SharedPreferences.getInstance();
//       final receiverId = prefs.getString('userId') ?? 'Unknown';

//       if (agoraToken != null) {
//         navigatorKey.currentState?.push(
//           MaterialPageRoute(
//             builder:
//                 (_) => IncomingCallScreen(
//                   receiverId: receiverId,
//                   callerId: callerId,
//                   channelId: channelId,
//                   agoraToken: agoraToken,
//                   isVideoCall: isVideoCall,
//                 ),
//           ),
//         );
//       } else {
//         print('Agora token is null. Cannot start call.');
//       }
//     } catch (e, stackTrace) {
//       print(' Error showing incoming call screen: $e');
//       print(stackTrace);
//     }
//   });
// }
void _showIncomingCallScreen(Map<String, dynamic> data) async {
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    try {
      final callerId = data['callerId'] ?? 'Unknown';
      final channelId = data['channelName'] ?? 'default_channel';
      // final agoraToken = Constants.agoraToken;
      

      final isVideoCall =
          (data['isVideoCall']?.toString() ?? 'false') == 'true';

      print('📞 Incoming call from: $callerId');

      final prefs = await SharedPreferences.getInstance();
      final receiverId = prefs.getString('userId') ?? 'Unknown';

      final tokenService = AgoraTokenService(backendUrl: Constants.backendUrl);
final agoraToken = await tokenService.fetchToken(channelId, receiverId);

      if (agoraToken == null) {
        print('Error: Agora token is null. Cannot show incoming call screen.');
        return;
      }

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
        ),
      );
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
