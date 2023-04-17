import 'package:do_an_tot_nghiep/DAO/DAOHepper.dart';
import 'package:do_an_tot_nghiep/Models/Call.dart';
import 'package:do_an_tot_nghiep/Services/Premissiond.dart';
import 'package:do_an_tot_nghiep/Views/CallScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class PickupScreen extends StatelessWidget {
  late final Call call;
  PickupScreen(this.call);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(alignment: Alignment.center,padding: EdgeInsets.symmetric(vertical: 100),child: 
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Incoming",style: TextStyle(fontSize: 30),),
          SizedBox(height: 50,),
           Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image:  NetworkImage('${call.callerPic!}'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
          SizedBox(height: 15,),
          Text(call.callerName!,style:TextStyle(fontWeight: FontWeight.bold,fontSize: 20) ,),
          SizedBox(height: 75,),
          Row(mainAxisAlignment: MainAxisAlignment.center,children: [
            IconButton(onPressed: ()async{await endCall(call);}, icon: Icon(Icons.call_end),color: Colors.redAccent,),
            SizedBox(width: 25,),
             IconButton(onPressed: () async=> await Permissions.cameraAndMicrophonePermissionsGranted()?Navigator.push(context, MaterialPageRoute(builder: (context)=>CallScreen(call))):{}, icon: Icon(Icons.call),color: Colors.green,),
          ],)
        ],
        ),),
    );
  }
}