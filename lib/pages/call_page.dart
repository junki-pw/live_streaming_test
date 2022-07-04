import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/rtc_engine.dart';

import 'dart:async';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as rtc_local_view;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as rtc_remote_view;

import '../utils/appId.dart';

class CallPage extends StatefulWidget {
  const CallPage({Key? key, this.channelName, this.role}) : super(key: key);
  final String? channelName;
  final ClientRole? role;

  @override
  State<CallPage> createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  final _users = <int>[];
  final _infoStrings = <String>[];
  bool muted = false;
  bool viewPanel = false;
  late RtcEngine _engine;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  @override
  void dispose() {
    _users.clear();
    _engine.leaveChannel();
    _engine.destroy();
    super.dispose();
  }

  Future<void> initialize() async {
    /// _initAgoraRtcEngine
    _engine = await RtcEngine.create(appId);
    await _engine.enableVideo();
    await _engine.setChannelProfile(ChannelProfile.LiveBroadcasting);
    await _engine.setClientRole(widget.role!);

    /// addAgoraEventHandlers
    _addAgoraEventHandlers();
    VideoEncoderConfiguration configuration = VideoEncoderConfiguration();
    configuration.dimensions = VideoDimensions(width: 1920, height: 1080);
    await _engine.setVideoEncoderConfiguration(configuration);
    await _engine.joinChannel(token, widget.channelName!, null, 0);
  }

  void _addAgoraEventHandlers() {
    _engine.setEventHandler(RtcEngineEventHandler(
      error: (code) {
        setState() {
          print('errorが発生しました');
        }
      },
      joinChannelSuccess: (channel, uid, elapsed) {},
      leaveChannel: (stats) {
        _users.clear();
        setState(() {});
      },
      userJoined: (uid, elapsed) {
        setState(() {
          _users.add(uid);
        });
      },
      userOffline: (uid, elapsed) {
        print('オフラインです');
      },
      firstRemoteVideoFrame: (uid, width, height, elapsed) {
        setState(() {});
      },
    ));
  }

  Widget _viewRows() {
    final List<StatefulWidget> list = [];

    if (widget.role == ClientRole.Broadcaster) {
      list.add(const rtc_local_view.SurfaceView());
    }

    for (var uid in _users) {
      list.add(rtc_remote_view.SurfaceView(
        uid: uid,
        channelId: widget.channelName!,
      ));
    }

    final views = list;

    return Column(
      children: List.generate(
        views.length,
        (index) => Expanded(
          child: views[index],
        ),
      ),
    );
  }

  Widget _toolbar() {
    if (widget.role == ClientRole.Audience) return const SizedBox();
    return Container(
      alignment: Alignment.bottomCenter,
      padding: EdgeInsets.symmetric(vertical: 48),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () {
              _engine.muteLocalAudioStream(muted);
            },
            child: Text('test1'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('test2'),
          ),
          ElevatedButton(
            onPressed: () {
              _engine.switchCamera();
            },
            child: Text('test3'),
          ),
        ],
      ),
    );
  }

  Widget _panel() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 48),
      alignment: Alignment.bottomCenter,
      child: FractionallySizedBox(
        heightFactor: 0.5,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 48),
          child: ListView.builder(
            reverse: true,
            itemCount: 1,
            itemBuilder: (context, index) {
              return Container(
                color: Colors.green,
                child: Text('test message'),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _viewRows(),
          _panel(),
          _toolbar(),
          Positioned(
            bottom: 40,
            child: Text(
              'ライブ中',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 72,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
