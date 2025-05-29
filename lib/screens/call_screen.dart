import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:video_call_app/utils/constants.dart';

class CallScreen extends StatefulWidget {
  final String channelId;
  final String userId; // your UID in Agora channel
  final String
  token; // Agora Token, can be null if using app certificate disabled

  const CallScreen({
    Key? key,
    required this.channelId,
    required this.userId,
    required this.token,
  }) : super(key: key);

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  late final RtcEngine _engine;
  final List<int> _remoteUsers = [];
  bool _muted = false;

  @override
  void initState() {
    super.initState();
    initializeAgora();
  }

  Future<void> initializeAgora() async {
    _engine = createAgoraRtcEngine();
    await _engine.initialize(
      const RtcEngineContext(
        appId: Constants.agoraAppId, // Replace with your Agora App ID
      ),
    );

    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (connection, elapsed) {
          debugPrint('Joined channel: ${connection.channelId}');
        },
        onUserJoined: (connection, remoteUid, elapsed) {
          setState(() {
            _remoteUsers.add(remoteUid);
          });
        },
        onUserOffline: (connection, remoteUid, reason) {
          setState(() {
            _remoteUsers.remove(remoteUid);
          });
        },
        onLeaveChannel: (connection, stats) {
          setState(() {
            _remoteUsers.clear();
          });
        },
      ),
    );

    await _engine.enableVideo();
    await _engine.startPreview();

    await _engine.joinChannelWithUserAccount(
      token: widget.token,
      channelId: widget.channelId,
      userAccount: widget.userId,
      options: const ChannelMediaOptions(),
    );
  }

  @override
  void dispose() {
    _engine.leaveChannel();
    _engine.release();
    super.dispose();
  }

  void _onToggleMute() {
    setState(() {
      _muted = !_muted;
      _engine.muteLocalAudioStream(_muted);
    });
  }

  void _onSwitchCamera() {
    _engine.switchCamera();
  }

  void _onEndCall() {
    Navigator.pop(context);
  }

  Widget _renderLocalPreview() {
    return AgoraVideoView(
      controller: VideoViewController(
        rtcEngine: _engine,
        canvas: const VideoCanvas(uid: 0),
      ),
    );
  }

  Widget _renderRemoteVideo(int uid) {
    return AgoraVideoView(
      controller: VideoViewController.remote(
        rtcEngine: _engine,
        canvas: VideoCanvas(uid: uid),
        connection: RtcConnection(channelId: widget.channelId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child:
                _remoteUsers.isNotEmpty
                    ? _renderRemoteVideo(_remoteUsers[0])
                    : Center(
                      child: Text(
                        'Waiting for user to join...',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ),
          ),
          Positioned(
            top: 40,
            right: 20,
            width: 120,
            height: 160,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white),
              ),
              child: _renderLocalPreview(),
            ),
          ),
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
                  icon: const Icon(Icons.call_end, color: Colors.red),
                  onPressed: _onEndCall,
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
