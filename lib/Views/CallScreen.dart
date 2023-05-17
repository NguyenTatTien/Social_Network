import 'dart:async';
import 'dart:math';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:do_an_tot_nghiep/Configs/config_agora.dart';
import 'package:do_an_tot_nghiep/DAO/DAOHepper.dart';
import 'package:do_an_tot_nghiep/Models/Call.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:permission_handler/permission_handler.dart';

import 'call_controller.dart';
const appId = "a35bd31643ed4b2eaac59090e8f0c3e7";
const token = "007eJxTYPgyuzjjalyoaWvkpe+mC5sYr3rJK1y8c0h3b+KBDfa8chsVGBKNTZNSjA3NTIxTU0ySjFITE5NNLQ0sDVIt0gySjVPNZ1impDQEMjJEutcwMEIhiM/KUJaZkprPwAAAhMAfmw==";
const channel = "video";
class CallScreen extends StatefulWidget {
  final Call call;
  CallScreen(this.call);

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  int? _remoteUid;
  bool _localUserJoined = false;
  late RtcEngine _engine;
  late var callCon;
  bool micStatus = false;
  @override
  void initState() {
    super.initState();
    initAgora();
   
  }

  Future<void> initAgora() async {
    // retrieve permissions
    await [Permission.microphone, Permission.camera].request();

    //create the engine
    _engine = createAgoraRtcEngine();
    await _engine.initialize(const RtcEngineContext(
      appId: appId,
      channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
    ));

    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          debugPrint("local user ${connection.localUid} joined");
          setState(() {
            _localUserJoined = true;
          });
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          debugPrint("remote user $remoteUid joined");
          setState(() {
            _remoteUid = remoteUid;
          });
        },
        onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
          debugPrint("remote user $remoteUid left channel");
          setState(() {
            _remoteUid = null;
          });
        },
        onTokenPrivilegeWillExpire: (RtcConnection connection, String token) {
          debugPrint('[onTokenPrivilegeWillExpire] connection: ${connection.toJson()}, token: $token');
        },
      ),
    );

    await _engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    await _engine.enableVideo();
    await _engine.startPreview();

    await _engine.joinChannel(
      token: token,
      channelId: channel,
      uid: 0,
      options: const ChannelMediaOptions(),
    );
     callCon = Get.put(CallController(_engine));
  }

  // Create UI with local view and remote view
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: Stack(
        children: [
          Center(
            child: _remoteVideo(),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 100,
              height: 150,
              child: Center(
                child: _localUserJoined
                    ? AgoraVideoView(
                        controller: VideoViewController(
                          rtcEngine: _engine,
                          canvas: const VideoCanvas(uid: 0),
                        ),
                      )
                    : const CircularProgressIndicator(),
              ),
            ),
          ),
           Container(
            alignment: Alignment.bottomCenter,margin: EdgeInsets.only(bottom: 10),child:Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          CircleAvatar(
            backgroundColor: Colors.blue,
                      child: IconButton(
              icon: micStatus ? Icon(Icons.mic_off, color: Colors.white,) : Icon(Icons.mic, color: Colors.white) , 
              onPressed: toggleMute,
            ),
          ),
          CircleAvatar(
            backgroundColor: Colors.red,
            child: IconButton(
              icon: Icon(Icons.call_end, color: Colors.white,), 
              onPressed: disconnectCall,
            )
          ),
          CircleAvatar(
            backgroundColor: Colors.blue,
            radius: 20,
            child: IconButton(
              icon: Icon(Icons.switch_camera, color: Colors.white,), 
              onPressed: toggleCamera,

            )
          ),
        ],
      ),)
        ],
      ),
    );
  }
    void toggleMute(){
    setState(() {
      micStatus = !micStatus;
    });
    _engine.muteLocalAudioStream(micStatus);
  }
  void toggleCamera(){
    _engine.switchCamera();
  }
  void disconnectCall(){
    Navigator.pop(context);
  }

  // Display remote user's video
  Widget _remoteVideo() {
    if (_remoteUid != null) {
      return AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: _engine,
          canvas: VideoCanvas(uid: _remoteUid),
          connection: const RtcConnection(channelId: channel),
        ),
      );
    } else {
      return const Text(
        'Vui lòng, chờ kết nối!',
        textAlign: TextAlign.center,
      );
    }
  }
}