
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:do_an_tot_nghiep/DAO/DAOHepper.dart';
import 'package:do_an_tot_nghiep/Models/Call.dart';
import 'package:do_an_tot_nghiep/Views/pickupScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class PickupLayout extends StatelessWidget {
  final Widget scaffold;
  
  PickupLayout({required this.scaffold});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(builder: (context, snapshot)
    {
      if(snapshot.hasData && snapshot.data!.data() !=null){
         Call call = Call.fromJson(snapshot.data!.data() as Map<String, dynamic>);
        if(!call.hasDialled!){
            return PickupScreen(call);
         }else{
           return scaffold;
         }
         
      }
      return scaffold;
    },stream: callStream(FirebaseAuth.instance.currentUser!.uid),);
  }
}