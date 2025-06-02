# video_call_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


```md
# Flutter Video Call App

## Features
- One-to-one video call using Agora
- Incoming call popup with full-screen UI
- Call accepts/rejects like WhatsApp (foreground/background)

## Setup
1. Replace `agoraAppId` and `agoraToken` in `constants.dart`
2. Add Firebase setup and FCM (google-services.json)
3. Run on 2 devices/emulators
4. Simulate call to `user_b`
5. Change channelId, agoraAppId, primaryAgoraCertificate, agoraToken and backendUrl in the Constants.dart
6. backendUrl is the local ipaddress {use 'ipconfig getifaddr en0' if on mac}

##Permissions
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
    <uses-permission android:name="android.permission.SYSTEM_ALERT_WINDOW"/>
    <uses-permission android:name="android.permission.USE_FULL_SCREEN_INTENT"/>
    <uses-permission android:name="android.permission.CAMERA" />
    <uses-permission android:name="android.permission.RECORD_AUDIO" />
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
    <uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE_PHONE_CALL" />
    <uses-permission android:name="android.permission.MANAGE_OWN_CALLS" />

##inside application
<service android:name="com.hiennguyen.flutter_callkit_incoming.CallkitIncomingService"
        android:exported="false"/>

## Dependencies
- firebase_core: ^3.13.1
- firebase_messaging: ^15.2.6
- agora_rtc_engine: ^6.5.2
- shared_preferences: ^2.5.3
- flutter_callkit_incoming: ^2.5.2
- cloud_firestore: ^5.6.8
- permission_handler: ^12.0.0+1
- firebase_auth: ^5.5.4
- google_fonts: ^6.2.1
- uuid: ^4.5.1
- http: ^1.4.0
- intl: ^0.20.2
- device_info_plus: ^11.4.0
```

---
