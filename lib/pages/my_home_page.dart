import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:influ/pages/call_page.dart';

import 'package:permission_handler/permission_handler.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _channelController = TextEditingController();
  bool _validateError = false;

  @override
  void dispose() {
    super.dispose();
    _channelController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        children: [
          TextField(
            controller: _channelController,
            decoration: InputDecoration(
              errorText: _validateError ? 'エラーが発生しました' : null,
            ),
          ),
          ElevatedButton(
            onPressed: () => onJoin(ClientRole.Broadcaster),
            child: Text('配信者'),
          ),
          ElevatedButton(
            onPressed: () => onJoin(ClientRole.Audience),
            child: Text('視聴者'),
          ),
        ],
      ),
    );
  }

  Future<void> onJoin(ClientRole _role) async {
    await [Permission.camera, Permission.microphone].request();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CallPage(
          channelName: _channelController.text,
          role: _role,
        ),
      ),
    );
  }
}
