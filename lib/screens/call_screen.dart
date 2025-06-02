import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_call_app/utils/constants.dart';

class CallScreen extends StatefulWidget {
  final String channelId;
  final String userId; // Agora userAccount
  final String token; // Agora Token
  final bool? isCaller;

  const CallScreen({
    super.key,
    required this.channelId,
    required this.userId,
    required this.token,
    this.isCaller,
  });

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  late final RtcEngine _engine;
  final List<int> _remoteUsers = [];
  final Set<int> _activeVideoUsers = {};
  bool _muted = false;
  bool _isInitialized = false;
  bool _speakerOn = true;
  bool _cameraOn = true;
  // int? _localUid;

  @override
  void initState() {
    super.initState();
    initializeAgora();
  }

  Future<void> initializeAgora() async {
    await [Permission.camera, Permission.microphone].request();

    _engine = createAgoraRtcEngine();

    await _engine.initialize(
      const RtcEngineContext(appId: Constants.agoraAppId),
    );

    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (connection, elapsed) {
          debugPrint('✅ Local User Joined: ${connection.localUid}');
          // setState(() {
          //   _localUid = connection.localUid;  // Save the actual local UID here
          // });
        },
        onUserJoined: (connection, remoteUid, elapsed) {
          debugPrint('👤 Remote user joined: $remoteUid');
          setState(() {
            _remoteUsers.add(remoteUid);
          });
        },
        onUserOffline: (connection, remoteUid, reason) {
          debugPrint('❌ Remote user left: $remoteUid');
          setState(() {
            _remoteUsers.remove(remoteUid);
          });
        },
        onError: (errCode, msg) {
          debugPrint('❗ Agora Error: $errCode | $msg');
        },
      ),
    );

    await _engine.enableVideo();
    await _engine.startPreview();

    await _engine.joinChannelWithUserAccount(
      // token: Constants.agoraToken!,
      token: widget.token,
      channelId: widget.channelId,
      userAccount: widget.userId,
      options: ChannelMediaOptions(
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ),
    );

    setState(() {
      _isInitialized = true;
    });
  }

  Widget _buildRemoteVideo() {
    if (_remoteUsers.isEmpty) {
      return const Center(
        child: Text(
          'Waiting for remote user...',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return AgoraVideoView(
      controller: VideoViewController.remote(
        rtcEngine: _engine,
        canvas: VideoCanvas(uid: _remoteUsers.first),
        connection: RtcConnection(channelId: widget.channelId),
      ),
    );
  }

  void _onToggleMute() {
    setState(() {
      _muted = !_muted;
    });
    _engine.muteLocalAudioStream(_muted);
  }

  void _onSwitchCamera() {
    _engine.switchCamera();
  }

  void _onEndCall() {
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _leaveAndReleaseEngine();
    super.dispose();
  }

  void _leaveAndReleaseEngine() async {
    await _engine.leaveChannel();
    await _engine.release();
  }

  void _onToggleSpeaker() {
    setState(() {
      _speakerOn = !_speakerOn;
    });
    _engine.setEnableSpeakerphone(_speakerOn);
  }

  void _onToggleCamera() {
    setState(() {
      _cameraOn = !_cameraOn;
    });
    if (_cameraOn) {
      _engine.enableLocalVideo(true);
    } else {
      _engine.enableLocalVideo(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 📹 Remote video
          Positioned.fill(child: _buildRemoteVideo()),

          // 🧑‍🦱 Local preview
          Positioned(
            top: 40,
            right: 20,
            width: 120,
            height: 160,
            child: AgoraVideoView(
              controller: VideoViewController(
                rtcEngine: _engine,
                canvas: const VideoCanvas(uid: 0),
              ),
            ),
          ),

          // 🎛️ Controls
          Positioned(
            bottom: 50,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: Icon(
                    _muted ? Icons.mic_off : Icons.mic,
                    color: Colors.white,
                  ),
                  onPressed: _onToggleMute,
                ),
                IconButton(
                  icon: Icon(
                    _cameraOn ? Icons.videocam : Icons.videocam_off,
                    color: Colors.white,
                  ),
                  onPressed: _onToggleCamera,
                ),
                IconButton(
                  icon: const Icon(Icons.call_end, color: Colors.red),
                  onPressed: _onEndCall,
                ),
                IconButton(
                  icon: Icon(
                    _speakerOn ? Icons.volume_up : Icons.hearing_disabled,
                    color: Colors.white,
                  ),
                  onPressed: _onToggleSpeaker,
                ),
                IconButton(
                  icon: const Icon(Icons.switch_camera, color: Colors.white),
                  onPressed: _onSwitchCamera,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
