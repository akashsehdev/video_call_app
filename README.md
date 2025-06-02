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
##screen shots
User List
![WhatsApp Image 2025-06-02 at 17 20 09](https://github.com/user-attachments/assets/f6605922-b0bb-497d-9c3f-3bf7196225f2)

Login as user A
![WhatsApp Image 2025-06-02 at 17 20 10](https://github.com/user-attachments/assets/15ff36a8-e5ef-4312-9687-0be4e514616b)

Login as user B
<img width="437" alt="Screenshot 2025-06-02 at 5 22 13 PM" src="https://github.com/user-attachments/assets/165a0ca5-79f1-4425-acae-c06fb4ef4374" />

Login to check history
![WhatsApp Image 2025-06-02 at 17 20 09 (2)](https://github.com/user-attachments/assets/ec1fb5e3-bc0a-4b38-b429-389fd239f566)

After login user A history
![WhatsApp Image 2025-06-02 at 17 20 10 (1)](https://github.com/user-attachments/assets/40be35c7-ffdb-438d-b5b4-1a6f9ec71388)

Calling user B
![WhatsApp Image 2025-06-02 at 17 20 10 (2)](https://github.com/user-attachments/assets/e5f24196-d31f-4acc-9b7b-7fc56ae8584b)

Calling Screen
![WhatsApp Image 2025-06-02 at 17 20 09 (1)](https://github.com/user-attachments/assets/890e670e-1ea8-465b-8c04-dbdb92767386)

User B Receiving Screen with notification
<img width="449" alt="Screenshot 2025-06-02 at 5 24 40 PM" src="https://github.com/user-attachments/assets/0a545800-c41b-4f78-80d1-cd692e91c0ea" />

Incoming Screen
![WhatsApp Image 2025-06-02 at 16 29 41](https://github.com/user-attachments/assets/36634242-b7b6-4a99-b609-843ace2917bc)

Caller and Receiver Screen
![WhatsApp Image 2025-06-02 at 15 56 26](https://github.com/user-attachments/assets/7ca754e6-e160-451a-903b-35bef3f14d38)


Thanks!
---
