// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_callkit_incoming/entities/android_params.dart';
// import 'package:flutter_callkit_incoming/entities/call_event.dart';
// import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
// import 'package:flutter_callkit_incoming/entities/ios_params.dart';
// import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';

// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:video_call_app/main.dart';
// import 'package:video_call_app/screens/call_screen.dart';
// import 'package:video_call_app/screens/incoming_call_screen.dart';
// import 'package:video_call_app/utils/constants.dart';

// class NotificationService {
//   // Global navigator key to be used for navigation from notifications
//   // static final GlobalKey<NavigatorState> navigatorKey =
//   //     GlobalKey<NavigatorState>();

//   // Singleton instance
//   static final NotificationService _instance = NotificationService._internal();
//   factory NotificationService() => _instance;
//   NotificationService._internal();

//   final FirebaseMessaging _messaging = FirebaseMessaging.instance;

//   /// Initialize Firebase Messaging and set up listeners
//   Future<void> initialize() async {
//     await _requestPermissions();
//     // Background message handler registration
//     FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

//     // Notification tap (app in background or foreground)
//     FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);

//     // Foreground message handler
//     FirebaseMessaging.onMessage.listen(_onMessageReceived);
//     bool _hasHandledCall = false;

//     //notification screen
//     FlutterCallkitIncoming.onEvent.listen((event) async {
//       print("📞 Call Event Triggered: ${event!.event}");
//       switch (event.event) {
//         // case Event.actionCallAccept:
//         //   final data = event.body['extra'];
//         //   print('Just agora token: ${data['agoraToken']}');
//         //   print('Just called id: ${data['callerId']}');
//         //   print('Just channel name: ${data['channelName']}');
//         //   navigatorKey.currentState?.push(
//         //     MaterialPageRoute(
//         //       builder:
//         //           (_) => CallScreen(
//         //             channelId: data['channelName'],
//         //             userId: data['callerId'],
//         //             token: data['agoraToken'],
//         //             isCaller: false,
//         //           ),
//         //     ),
//         //   );
//         //   break;

//         case Event.actionCallAccept:
//           _hasHandledCall = true;
//           final data = event.body['extra'];
//           final prefs = await SharedPreferences.getInstance();
//           final receiverId = prefs.getString('userId') ?? 'Unknown';
//           print('Just receiver Id:${receiverId}');
//           print('Just agora token: ${data['agoraToken']}');
//           print('Just called id: ${data['callerId']}');
//           print('Just channel name: ${data['channelName']}');
//           ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
//             SnackBar(content: Text('Call accepted from notification')),
//           );
//           navigatorKey.currentState?.push(
//             MaterialPageRoute(
//               builder:
//                   (_) => IncomingCallScreen(
//                     receiverId: receiverId,
//                     callerId: data['callerId'],
//                     channelId: data['channelName'],
//                     agoraToken: data['agoraToken'],
//                     isVideoCall: data['isVideoCall'] == 'true',
//                   ),
//             ),
//           );

//           break;

//         case Event.actionCallDecline:
//           _hasHandledCall = false;
//           // Handle decline
//           break;

//         case Event.actionCallEnded:
//           // Handle end
//           break;

//         case Event.actionCallTimeout:
//           // Handle timeout
//           break;

//         default:
//           break;
//       }
//     });
//   }

//   /// Request notification permissions (iOS/Android)
//   Future<void> _requestPermissions() async {
//     NotificationSettings settings = await _messaging.requestPermission(
//       alert: true,
//       badge: true,
//       sound: true,
//     );
//     debugPrint('User granted permission: ${settings.authorizationStatus}');
//   }

//   void setupInteractedMessage() async {
//     FirebaseMessaging messaging = FirebaseMessaging.instance;

//     // Handle when app is in terminated state
//     RemoteMessage? initialMessage = await messaging.getInitialMessage();
//     if (initialMessage != null) {
//       _handleMessageNavigation(initialMessage);
//     }

//     // Foreground (app opened from notification)
//     // FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageNavigation);

//     // While app is in foreground (optional local notification)
//     // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//     //   // Optionally show a local notification
//     //   // showLocalNotification(message);
//     // });
//   }

//   void _handleMessageNavigation(RemoteMessage message) {
//     final data = message.data;

//     if (data['type'] == 'call') {
//       // Navigate to Incoming Call Screen
//       navigatorKey.currentState?.push(
//         MaterialPageRoute(
//           builder:
//               (_) => IncomingCallScreen(
//                 receiverId: data['receiverId'] ?? '',
//                 callerId: data['callerId'],
//                 channelId: data['channelName'],
//                 agoraToken: data['agoraToken'],
//                 isVideoCall: data['isVideoCall'] == 'true',
//               ),
//         ),
//       );
//     } else {
//       // Navigate to some default screen or do nothing
//       print("Unhandled notification type: ${data['type']}");
//     }
//   }

//   Future<void> _showIncomingCall(Map<String, dynamic> data) async {
//     final prefs = await SharedPreferences.getInstance();
//     final receiverId = prefs.getString('userId') ?? 'Unknown';
//     final params = CallKitParams(
//       id: data['channelId'],
//       // nameCaller: data['callerName'] ?? 'Unknown Caller',
//       nameCaller: receiverId,
//       appName: 'Video Call App',
//       avatar: 'https://i.pravatar.cc/100',
//       handle: 'Incoming Call',
//       type: data['isVideoCall'] == 'true' ? 1 : 0,
//       duration: 30000,
//       textAccept: 'Accept',
//       textDecline: 'Decline',
//       extra: {
//         'callerId': data['callerId'],
//         'agoraToken': data['agoraToken'],
//         'channelName': data['channelName'],
//         'isVideoCall': data['isVideoCall'],
//       },
//       android: AndroidParams(
//         isCustomNotification: true,
//         isShowLogo: true,
//         isShowCallID: true,
//         ringtonePath: 'system_ringtone_default',
//         backgroundColor: '#0955fa',
//         backgroundUrl: 'system_background_default',
//       ),
//       ios: IOSParams(iconName: 'CallKitIcon', handleType: 'generic'),
//     );

//     await FlutterCallkitIncoming.showCallkitIncoming(params);
//   }

//   /// Retrieves the FCM device token
//   Future<String?> getToken() async {
//     return await _messaging.getToken();
//   }

//   /// Handles incoming foreground messages
//   void _onMessageReceived(RemoteMessage message) {
//     debugPrint('Foreground message received: ${message.messageId}');
//     if (message.data['type'] == 'call') {
//       _showIncomingCall(message.data);
//     }
//     // _handleMessageData(message.data);
//   }

//   /// Handles notification taps when the app is opened from background/foreground
//   void _onMessageOpenedApp(RemoteMessage message) {
//     debugPrint('Notification clicked: ${message.messageId}');
//     _handleMessageData(message.data);
//   }

//   /// Background message handler
//   static Future<void> _firebaseMessagingBackgroundHandler(
//     RemoteMessage message,
//   ) async {
//     await Firebase.initializeApp();
//     debugPrint('🔄 Background FCM: ${message.messageId}');
//     final data = message.data;
//     if (data.containsKey('channelId')) {
//       await FlutterCallkitIncoming.showCallkitIncoming(
//         CallKitParams(
//           id: data['channelId'],
//           nameCaller: data['callerName'] ?? 'Unknown',
//           appName: 'Video Call App',
//           handle: 'Incoming Call',
//           avatar: 'https://i.pravatar.cc/100',
//           type: data['isVideoCall'] == 'true' ? 1 : 0,
//           duration: 30000,
//           extra: {
//             'callerId': data['callerId'],
//             'channelName': data['channelName'],
//             'isVideoCall': data['isVideoCall'],
//           },
//           android: AndroidParams(
//             isCustomNotification: true,
//             isShowLogo: true,
//             ringtonePath: 'system_ringtone_default',
//             backgroundColor: '#0955fa',
//           ),
//           ios: IOSParams(iconName: 'CallKitIcon'),
//         ),
//       );
//     }
//   }

//   /// Process notification data payload
//   // void _handleMessageData(Map<String, dynamic> data) {
//   //   if (data.containsKey('channelId') && data.containsKey('callerId')) {
//   //     // TODO: Add your call screen launching or CallKit logic here
//   //     debugPrint('Incoming call from callerId: ${data['callerId']} on channelId: ${data['channelId']}');
//   //   }
//   // }
//   void _handleMessageData(Map<String, dynamic> data) {
//     if (data.containsKey('channelId') && data.containsKey('callerId')) {
//       debugPrint(
//         'Incoming call from callerId: ${data['callerId']} on channelId: ${data['channelId']}',
//       );
//       // ✅ Show incoming call UI
//       _showIncomingCall(data); // Add this line
//     }
//   }
// }
