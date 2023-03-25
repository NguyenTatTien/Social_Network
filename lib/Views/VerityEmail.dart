import 'dart:async';

import 'package:do_an_tot_nghiep/DAO/DAOHepper.dart';
import 'package:do_an_tot_nghiep/Models/User.dart';
import 'package:do_an_tot_nghiep/Views/Navigation.dart';
import 'package:do_an_tot_nghiep/Views/loginPage.dart';
import 'package:do_an_tot_nghiep/Views/signup.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:fluttertoast/fluttertoast.dart';

class VerityEmail extends StatefulWidget {
  VerityEmail();

  @override
  State<VerityEmail> createState() => _VerityEmailState();
}

class _VerityEmailState extends State<VerityEmail> {
  bool isEmailVerified = false;
  Timer? timer;
  bool canResenEmail = false;
  
  _VerityEmailState();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isEmailVerified = auth.FirebaseAuth.instance.currentUser!.emailVerified;
    
    if(!isEmailVerified){
      sendVerificationEmail();
      Timer.periodic(Duration(seconds: 3), (timer)=>checkEmailVerified());
    }
  }
  @override
  void dispose() {
    // TODO: implement dispose
    timer?.cancel();
    super.dispose();
  }
  Future checkEmailVerified()async{
   
    await auth.FirebaseAuth.instance.currentUser!.reload();
    setState(() {
      isEmailVerified = auth.FirebaseAuth.instance.currentUser!.emailVerified;
    });
    
    if(isEmailVerified)
    {
      
      timer?.cancel();
    }
    
  }

  Future sendVerificationEmail() async{
    try{
      
      final user = auth.FirebaseAuth.instance.currentUser!;
    await user.sendEmailVerification();
   
    
    setState(() {
      canResenEmail = false;
    });
    await Future.delayed(Duration(seconds: 5));
    setState(() {
      canResenEmail = true;
    });
    
    }catch(e){
      print(e.toString());
    }
  }
  @override
  Widget build(BuildContext context) => isEmailVerified
  ? NavigatorView()
  : Scaffold(
    body: Padding(padding: EdgeInsets.all(16),child: Column( mainAxisAlignment: MainAxisAlignment.center,children: [
      Text('Vui lòng vào email đễ xác thực tài khoản!',style: TextStyle(fontSize: 20),textAlign: TextAlign.center,),
      SizedBox(height: 24,),
      ElevatedButton.icon(onPressed:canResenEmail? sendVerificationEmail:null, icon: Icon(Icons.email,size: 32,), label: Text("Gửi lại Email",style: TextStyle(fontSize: 24),),style: ElevatedButton.styleFrom(minimumSize: Size.fromHeight(50)),),
      SizedBox(height: 8,),
      ElevatedButton(onPressed:(){auth.FirebaseAuth.instance.signOut();Navigator.pop(context);}, child: Text("Thoát",style: TextStyle(fontSize: 24),),style: ElevatedButton.styleFrom(minimumSize: Size.fromHeight(50)),),
    ]),),
  );
}