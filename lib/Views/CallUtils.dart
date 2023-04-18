// import 'dart:math';

// import 'package:do_an_tot_nghiep/DAO/DAOHepper.dart';
// import 'package:do_an_tot_nghiep/Models/Call.dart';
// import 'package:do_an_tot_nghiep/Models/User.dart';
// import 'package:do_an_tot_nghiep/Views/CallScreen.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart';

// class CallUtils{
//   static dial({
//     required User from,
//     required User to,
//     context
//   }) async{
//     Call call = Call(
//       callerId:  from.id,
//       callerName: ("${from.firstName!} ${from.lastName!}"),
//       callerPic: from.image,
//       receiverId: to.id,
//       receiverName: ("${to.firstName!} ${to.lastName!}"),
//       receiverPic: to.image,
//       channelId: Random().nextInt(1000).toString()
//     );
//     bool callMade = await makeCall(call);
//     call.hasDialled = true;
//     if(callMade){
//       Navigator.push(context, MaterialPageRoute(builder: (context)=>CallScreen(call)));
//     }
//   }
// }