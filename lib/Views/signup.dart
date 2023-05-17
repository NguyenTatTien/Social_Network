import 'dart:async';
import 'dart:io';


import 'package:do_an_tot_nghiep/DAO/DAOHepper.dart';
import 'package:do_an_tot_nghiep/Models/User.dart';
import 'package:do_an_tot_nghiep/Views/Design.dart';
import 'package:do_an_tot_nghiep/Views/VerityEmail.dart';
import 'package:do_an_tot_nghiep/Views/bezierContainer.dart';
import 'package:do_an_tot_nghiep/Views/loginPage.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';



class SignUpPage extends StatefulWidget {
  // ignore: prefer_const_constructors_in_immutables
  SignUpPage({Key ?key, this.title}) : super(key: key);
  
  final String? title;

  @override
  // ignore: library_private_types_in_public_api
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  var controllerConfirmPassword = TextEditingController();
  var controllerEmail = TextEditingController();
  var controllerPassword = TextEditingController();
  var controllerFirstName = TextEditingController();
  var controllerLastName = TextEditingController();
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
            const Text('Quay lại',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500))
          ],
        ),
      ),
    );
  }

  Widget _entryField(String title,var controller, {bool isPassword = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: 
          TextField(
              controller:controller ,
              obscureText: isPassword,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  fillColor: const Color(0xfff3f3f4),
                  filled: true,hintText: title))
        
      
    );
  }
  // ignore: non_constant_identifier_names
   Future SignUp() async{
    if(controllerEmail.text!=""&&controllerFirstName.text!=""&&controllerLastName.text!=""&&controllerConfirmPassword.text!=""&&controllerPassword.text!=""){
      if(EmailValidator.validate(controllerEmail.text)){
        if(controllerPassword.text==controllerConfirmPassword.text){
            if(await checkUserByEmail(controllerEmail.text)){
              Fluttertoast.showToast(msg: "Email này đã được sử dụng!");
            }
            else{
              try{
                var usercreate = await firebase_auth.FirebaseAuth.instance.createUserWithEmailAndPassword(email: controllerEmail.text.trim(), password: controllerPassword.text.trim());
                User user = User(id: usercreate.user!.uid,firstName:controllerFirstName.text,lastName: controllerLastName.text,email:controllerEmail.text,password: controllerPassword.text,createDate:DateTime.now(),phoneNumber: "",image: "https://firebasestorage.googleapis.com/v0/b/project-cb943.appspot.com/o/image%2FlogoPreson%2FUnknown_person.jpg?alt=media&token=061d880a-9464-41e4-af7e-c259aedcaef7",status: false);
                CreateData("User",user);
                await Navigator.push(context, MaterialPageRoute(builder: (context)=> VerityEmail()));
        
              }
              catch(e){
                Fluttertoast.showToast(msg: "Email không tồn tại!");
                this.dispose();
              }
            }
            // var usercreate = await firebase_auth.FirebaseAuth.instance.createUserWithEmailAndPassword(email: controllerEmail.text.trim(), password: controllerPassword.text.trim());
            // User user = User(id: usercreate.user!.uid,firstName:controllerFirstName.text,lastName: controllerLastName.text,email:controllerEmail.text,password: controllerPassword.text,createDate:DateTime.now(),phoneNumber: "",image: "https://firebasestorage.googleapis.com/v0/b/project-cb943.appspot.com/o/image%2FlogoPreson%2FUnknown_person.jpg?alt=media&token=061d880a-9464-41e4-af7e-c259aedcaef7",status: false);
            // CreateData("User",user);
      }
        else{
          Fluttertoast.showToast(msg: "Vui lòng nhập lại mật khẩu chính xác!");
        }
      }
      else{
         Fluttertoast.showToast(msg: "Vui lòng nhập đúng định dạng email!");
      }
    }
    else{
      Fluttertoast.showToast(msg: "Vui lòng nhập đầy đủ thông tin!");
    }
   
  }
  Widget _submitButton() {
    return InkWell(onTap: (){
     SignUp();
    },child: Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(vertical: 15),
      alignment: Alignment.center,
      decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(5)),
          boxShadow: <BoxShadow>[
            BoxShadow(
                color: Colors.grey.shade200,
                offset: Offset(2, 4),
                blurRadius: 5,
                spreadRadius: 2)
          ],
          gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Color(0xffa26ce4), Color(0xff9900cc)])),

      child: const Text(
        'Đăng ký',
        style: TextStyle(fontSize: 20, color: Colors.white),
      ),
    ),);
  }

  Widget _loginAccountLabel() {
    return InkWell(
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => LoginPage()));
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 20),
        //padding: EdgeInsets.all(15),
        alignment: Alignment.bottomCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const <Widget>[
            Text(
              'Bạn đã có tài khoản chưa?',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              'Đăng nhập',
              style: TextStyle(
                  color: mainColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _title() {
    // return RichText(
    //   textAlign: TextAlign.center,
    //   text: const TextSpan(
    //       text: 'S',
    //       style: TextStyle(
    //           fontSize: 30,
    //           fontWeight: FontWeight.w700,
    //           color: mainColor
    //       ),

    //       children: [
    //         TextSpan(
    //           text: 'ign',
    //           style: TextStyle(color: Colors.black, fontSize: 30),
    //         ),
    //         TextSpan(
    //           text: 'up',
    //           style: TextStyle(color: mainColor, fontSize: 30),
    //         ),
    //       ]),
    // );
    return Image.asset("assets/images/logo.png",width: 120,height: 120,);
  }

  Widget _emailPasswordWidget() {
    return Column(
      children: <Widget>[
        Row(children: [
           Expanded(child:Container(margin: EdgeInsets.only(right: 5),child:_entryField("Tên",controllerFirstName)),flex: 1,),
          
           Expanded(child:Container(margin: EdgeInsets.only(left: 5),child:_entryField("Họ",controllerLastName)),flex: 1,),
        ],),
        _entryField("Email",controllerEmail),
        _entryField("Mật khẩu",controllerPassword, isPassword: true),
        _entryField("Nhập lại mật khẩu",controllerConfirmPassword,isPassword: true),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SizedBox(
        height: height,
        child: Stack(
          children: <Widget>[
            Positioned(
              top: -MediaQuery.of(context).size.height * .15,
              right: -MediaQuery.of(context).size.width * .4,
              child: BezierContainer(),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(height: height * .2),
                    _title(),
                    const SizedBox(
                      height: 50,
                    ),
                    _emailPasswordWidget(),
                    const SizedBox(
                      height: 20,
                    ),
                    _submitButton(),
                    _loginAccountLabel(),
                  ],
                ),
              ),
            ),
            Positioned(top: 40, left: 0, child: _backButton()),
          ],
        ),
      ),
    );
  }
}
