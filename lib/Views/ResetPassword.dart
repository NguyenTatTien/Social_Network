import 'package:do_an_tot_nghiep/Models/User.dart';
import 'package:do_an_tot_nghiep/Services/AuthService.dart';
import 'package:do_an_tot_nghiep/Views/Design.dart';
import 'package:do_an_tot_nghiep/Views/Navigation.dart';
import 'package:do_an_tot_nghiep/Views/bezierContainer.dart';
import 'package:do_an_tot_nghiep/Views/mainapp.dart';
import 'package:do_an_tot_nghiep/Views/mainpage.dart';
import 'package:do_an_tot_nghiep/Views/signup.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:sql_conn/sql_conn.dart';


class ResetPasswor extends StatefulWidget {
  const ResetPasswor({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  // ignore: library_private_types_in_public_api
  _ResetPassworState createState() => _ResetPassworState();
}

class _ResetPassworState extends State<ResetPasswor> {
  
  var controllerEmail = TextEditingController();
  var controllerPassword = TextEditingController();
  @override

  Widget _backButton() {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.only(left: 0, top: 10, bottom: 10),
              child: const Icon(Icons.keyboard_arrow_left, color: Colors.black),
            ),
            const Text('Back',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500))
          ],
        ),
      ),
    );
  }

  Widget _entryField(String title, var controller,{bool isPassword = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: 
         
          
          TextField(
              controller: controller,
              obscureText: isPassword,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  fillColor: const Color(0xfff3f3f4),
                  filled: true,hintText: title))
       
    );
  }

  Widget _submitButton() {
     return 
   
   InkWell(onTap: (){
      FirebaseAuth.instance.sendPasswordResetEmail(email: controllerEmail.text).then((value) => Navigator.of(context).pop());    // ignore: avoid_print
    },child: Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(vertical: 15),
      alignment: Alignment.center,
      decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(5)),
          boxShadow: <BoxShadow>[
            BoxShadow(
                color: Colors.grey.shade200,
                offset: const Offset(2, 4),
                blurRadius: 5,
                spreadRadius: 2)
          ],
          gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Color(0xffa26ce4), Color(0xff9900cc)])),
      child: const Text(
        'Reset Password',
        style: TextStyle(fontSize: 20, color: Colors.white),
      ),
    ),);
      
    
  }
  Widget _title() {
    return RichText(
      textAlign: TextAlign.center,
      text: const TextSpan(
          text: 'Re',
          style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w700,
              color: mainColor
          ),
          children: [
            TextSpan(
              text: 'set',
              style: TextStyle(color: Colors.black, fontSize: 30),
            ),
            TextSpan(
              text: 'Password',
              style: TextStyle(color: mainColor, fontSize: 30),
            ),
          ]),
    );
  }
  Widget _emailPasswordWidget() {
    return Column(
      children: <Widget>[
        _entryField("Nhập Email",controllerEmail),
        
      ],
    );
  }
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    
    return Scaffold(
        // ignore: sized_box_for_whitespace
        body: Container(
      height: height,
      child: Stack(
        children: <Widget>[
          Positioned(
              top: -height * .15,
              right: -MediaQuery.of(context).size.width * .4,
              child: const BezierContainer()),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: height * .2),
                  _title(),
                  const SizedBox(height: 50),
                  _emailPasswordWidget(),
                  _submitButton(),
                ],
              ),
            ),
          ),
          Positioned(top: 40, left: 0, child: _backButton()),
        ],
      ),
    ));
  }
}
