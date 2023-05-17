import 'dart:io';

import 'package:do_an_tot_nghiep/Models/User.dart';
import 'package:do_an_tot_nghiep/Services/AuthService.dart';
import 'package:do_an_tot_nghiep/Views/Design.dart';
import 'package:do_an_tot_nghiep/Views/Navigation.dart';
import 'package:do_an_tot_nghiep/Views/ResetPassword.dart';
import 'package:do_an_tot_nghiep/Views/bezierContainer.dart';
import 'package:do_an_tot_nghiep/Views/mainapp.dart';
import 'package:do_an_tot_nghiep/Views/mainpage.dart';
import 'package:do_an_tot_nghiep/Views/signup.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sql_conn/sql_conn.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  // ignore: library_private_types_in_public_api
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  
  var controllerEmail = TextEditingController();
  var controllerPassword = TextEditingController();
  @override

 
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

  Widget _submitButton(){
     return 
   
   InkWell(onTap: ()async{
   SharedPreferences prefs;
   try{
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: controllerEmail.text, password: controllerPassword.text).then((value) => {
            Navigator.push(context, MaterialPageRoute(builder: (context)=> const NavigatorView())),
           
         
    });
   }on FirebaseAuthException catch (e) {

      if (Platform.isAndroid) {
        switch (e.message) {
          case 'There is no user record corresponding to this identifier. The user may have been deleted.':
            Fluttertoast.showToast(msg: "Tài khoản không tồn tài!");
            break;
          case 'The password is invalid or the user does not have a password.':
            Fluttertoast.showToast(msg: "Mật khẩu không chính xác!");
            break;
          case 'A network error (such as timeout, interrupted connection or unreachable host) has occurred.':
             Fluttertoast.showToast(msg: "Mất kết nối, vui lòng kiểm tra mạng!");
            break;
          // ...
          default:
             Fluttertoast.showToast(msg: "Đăng nhập không thành công!");
        }
      } else if (Platform.isIOS) {
        switch (e.code) {
          case 'Error 17011':
            Fluttertoast.showToast(msg: "Tài khoản không tồn tài!");
            break;
          case 'Error 17009':
                Fluttertoast.showToast(msg: "Mật khẩu không chính xác!");
            break;
          case 'Error 17020':
            Fluttertoast.showToast(msg: "Mất kết nối, vui lòng kiểm tra mạng!");
            break;
          // ...
          default:
             Fluttertoast.showToast(msg: "Đăng nhập không thành công!");
        }
  }

   }
    // ignore: avoid_print
  
   
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
        'Đăng nhập',
        style: TextStyle(fontSize: 20, color: Colors.white),
      ),
    ),);
      
    
  }

  Widget _divider() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: const <Widget>[
          SizedBox(
            width: 20,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Divider(
                thickness: 1,
              ),
            ),
          ),
          Text('or'),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Divider(
                thickness: 1,
              ),
            ),
          ),
          SizedBox(
            width: 20,
          ),
        ],
      ),
    );
  }
  void loginByGoogle()async{
       await AuthService().googleLogin();
      if(FirebaseAuth.instance.currentUser!=null){
        Navigator.push(context, MaterialPageRoute(builder: (context)=> const NavigatorView()));
      }
  }
  Widget _googleButton() {
    // return InkWell(onTap: (){
    //     loginByGoogle();
      
    //   },child:Container(
    //   height: 50,
    //   margin: const EdgeInsets.symmetric(vertical: 20),
    //   decoration: const BoxDecoration(
    //     borderRadius: BorderRadius.all(Radius.circular(10)),
    //   ),
    //   child: Row(
    //     children: <Widget>[
    //       Expanded(
    //         flex: 1,
    //         child: Container(
    //           decoration: const BoxDecoration(
    //             color: Color.fromARGB(255, 234, 33, 6),
    //             borderRadius: BorderRadius.only(
    //                 bottomLeft: Radius.circular(5),
    //                 topLeft: Radius.circular(5)),
    //           ),
    //           alignment: Alignment.center,
    //           child: const Text('G',
    //               style: TextStyle(
    //                   color: Colors.white,
    //                   fontSize: 25,
    //                   fontWeight: FontWeight.w400)),
    //         ),
    //       ),
    //       Expanded(
    //         flex: 5,
    //         child: Container(
    //           decoration: const BoxDecoration(
    //             color: Color.fromARGB(255, 224, 224, 223),
    //             borderRadius: BorderRadius.only(
    //                 bottomRight: Radius.circular(5),
    //                 topRight: Radius.circular(5)),
    //           ),
    //           alignment: Alignment.center,
    //           child: const Text('Đăng nhập tài khoản Google',
    //               style: TextStyle(
    //                   color: Color.fromARGB(255, 14, 0, 0),
    //                   fontSize: 18,
    //                   fontWeight: FontWeight.w400)),
    //         ),
    //       ),
    //     ],
    //   ),
    // ));    
    return Container(width: MediaQuery.of(context).size.width,child:ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.white,
                  onPrimary: Colors.black,
                  
                ),
                
                onPressed: () {
                   loginByGoogle();
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Image(
                        image: AssetImage("assets/images/g-logo.png"),
                        height: 30.0,
                        width: 40,
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 24, right: 8),
                        child: Text(
                          'Đăng nhập tài khoản Google',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.black54,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ));
  }

  Widget _createAccountLabel() {
    return InkWell(
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => SignUpPage()));
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 20),
       // padding: EdgeInsets.all(15),
        alignment: Alignment.bottomCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const <Widget>[
            Text(
              'Chưa có tài khoản?',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              'Đăng ký',
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
    //           text: 'in',
    //           style: TextStyle(color: mainColor, fontSize: 30),
    //         ),
    //       ]),
    // );
    return Image.asset("assets/images/logo.png",width: 120,height: 120,);
  }
  Widget _emailPasswordWidget() {
    return Column(
      children: <Widget>[
        _entryField("Email",controllerEmail),
        _entryField("Mật khẩu",controllerPassword, isPassword: true),
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
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    alignment: Alignment.centerRight,
                    child: InkWell(onTap: (){  Navigator.push(context, MaterialPageRoute(builder: (context)=> const ResetPasswor()));},child:Text('Quên mật khẩu?',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500)),
                  )),
                  _divider(),
                  _googleButton(),
                  _createAccountLabel(),
                ],
              ),
            ),
          ),
          
        ],
      ),
    ));
  }
}
