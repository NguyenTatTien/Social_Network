import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:do_an_tot_nghiep/DAO/DAOHepper.dart';
import 'package:do_an_tot_nghiep/Models/Call.dart';
import 'package:do_an_tot_nghiep/Views/CallScreen.dart';
import 'package:do_an_tot_nghiep/Views/Design.dart';
import 'package:do_an_tot_nghiep/Views/color_utils.dart';
import 'package:do_an_tot_nghiep/localization/localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:flutter_svg/svg.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wakelock/wakelock.dart';



class CallUpScreen extends StatelessWidget {
  // final ResCallRequestModel? resCallRequestModel;
  // final ResCallAcceptModel? resCallAcceptModel;
  final bool isForOutGoing=true;
   late final Call call;
    CallUpScreen(this.call);
  // PickUpScreen(
  //     {this.resCallRequestModel,
  //     this.resCallAcceptModel,
  //     this.isForOutGoing = false});
//   @override
//   _CallUpScreenState createState() => _CallUpScreenState(this.call);
// }

// class _CallUpScreenState extends State<CallUpScreen> {
//   Timer? _timer;
//   late final Call call;
//   _CallUpScreenState(this.call);
  // @override
  // void initState() {
  //   super.initState();
  //   Wakelock.enable(); // Turn on wakelock feature till call is running
  //   //To Play Ringtone
  //   FlutterRingtonePlayer.play(
  //       android: AndroidSounds.ringtone,
  //       ios: IosSounds.electronic,
  //       looping: true,
  //       volume: 0.5,
  //       asAlarm: false);
  //   _timer = Timer(const Duration(milliseconds: 60 * 1000), _endCall(context));
  // }

  // @override
  // void dispose() {
  //   //To Stop Ringtone
  //   FlutterRingtonePlayer.stop();
  //   _timer?.cancel();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
   // getScreenSize(context);
    return Scaffold(
   
      body: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.1, 1],
            colors: [Color(0xff6f37fc), Color(0xff5cf6ff)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
          Text(
             "Đang gọi...",
              style: TextStyle(
                  color: ColorUtils.whiteColor,
                  fontSize: 25,
                  fontWeight: FontWeight.w400),
            ),
            SizedBox(height: 50),
            _getImageUrlWidget(),
            SizedBox(height: 20),
            Text("Tiến Nguyễn",
                style: TextStyle(
                    color: ColorUtils.whiteColor,
                    fontSize: 24,
                    fontWeight: FontWeight.w400)),
          SizedBox(height:  MediaQuery.of(context).size.width * 1/3),
         Row(

              mainAxisAlignment: isForOutGoing?MainAxisAlignment.spaceAround:MainAxisAlignment.center,
              children: <Widget>[
               _callingButtonWidget(context, false),
                isForOutGoing
                    ? _callingButtonWidget(context, true)
                    : SizedBox(),
              ],
            ),
            
          ],
        ),
      ),
    );
  }

  //To Display Profile Image Of User
  _getImageUrlWidget() => ClipOval(
          child: CircleAvatar(
        backgroundColor: ColorUtils.whiteColor,
        radius: 100,
        child: CachedNetworkImage(
            fit: BoxFit.cover,
            width: 200,
            height: 200,
            placeholder: (context, url) => Center(
                  child: SizedBox(
                    height: 40,
                    width: 40,
                    child: CircularProgressIndicator(
                      backgroundColor: ColorUtils.accentColor,
                    ),
                  ),
                ),
            errorWidget: (context, url, error) => SvgPicture.asset(
                  FileConstants.icUserPlaceholder,
                  color: ColorUtils.primaryColor.withAlpha(200),
                ),
            imageUrl: ""), // Any ImageUrl
      ));

  //Reusable Accept & Reject Call Ui/Ux
  _callingButtonWidget(BuildContext context, bool isCall) => RawMaterialButton(
      onPressed: ()async {
        
        if (isCall) {
          //_timer?.cancel();
         Navigator.push(context, MaterialPageRoute(builder: (context)=>CallScreen(call)));
        //  pickUpCallPressed(context);
        } else {
          await endCall(call);
        }
      },
      child: Icon(isCall ? Icons.call : Icons.call_end,
          color: Colors.white, size: 35),
      shape: CircleBorder(),
      elevation: 2.0,
      fillColor: isCall ? Colors.green : Colors.redAccent,
      padding: const EdgeInsets.all(15));

  //Call This Method When User Pressed On Accept Call Button
 
  }

  //Call This Method When User Pressed On Reject Call Button
  // _endCall(BuildContext context) async {
  //   Wakelock.disable(); // Turn off wakelock feature after call end
  //   FlutterRingtonePlayer.stop(); // To Stop Ringtone
  //   //Emit Reject Call Event Into Socket
  //   // emit(
  //   //     SocketConstants.rejectCall,
  //   //     ({
  //   //       ArgParams.connectId: widget.isForOutGoing
  //   //           ? widget.resCallAcceptModel?.otherUserId
  //   //           : widget.resCallRequestModel?.id,
  //   //     }));
  //    Navigator.of(context).pop();
  // }

class FileConstants {
  static const String icUserPlaceholder =
      'assets/images/ic_user_placeholder.svg';
  static const String icTimer = 'assets/images/ic_timer.svg';
}
