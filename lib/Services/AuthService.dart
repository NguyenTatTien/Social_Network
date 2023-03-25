import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:do_an_tot_nghiep/DAO/DAOHepper.dart';
import 'package:do_an_tot_nghiep/Models/User.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
class AuthService extends ChangeNotifier{
  final googleSignin = GoogleSignIn();
  GoogleSignInAccount? _user;
  GoogleSignInAccount get user => _user!;
  googleLogin() async{
    print("f");
    final userGoogle =  await GoogleSignIn().signIn();
   
    print("gg");
    final googleAuth = await userGoogle!.authentication;
    final credential = auth.GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken
    );
    print("den day");
    await auth.FirebaseAuth.instance.signInWithCredential(credential);
    print(auth.FirebaseAuth.instance.currentUser!.uid);
    var user = await getUserById(auth.FirebaseAuth.instance.currentUser!.uid);
    // ignore: unnecessary_null_comparison
    if(user.id==null){
        user = User(id: auth.FirebaseAuth.instance.currentUser!.uid,address: "",birthDay:"",createDate: DateTime.now(),email: auth.FirebaseAuth.instance.currentUser!.email,firstName: auth.FirebaseAuth.instance.currentUser!.displayName!.substring(0,auth.FirebaseAuth.instance.currentUser!.displayName!.indexOf(" ")),image: auth.FirebaseAuth.instance.currentUser!.photoURL,lastName: auth.FirebaseAuth.instance.currentUser!.displayName!.substring(auth.FirebaseAuth.instance.currentUser!.displayName!.indexOf(" "),auth.FirebaseAuth.instance.currentUser!.displayName!.length),password: "",phoneNumber: auth.FirebaseAuth.instance.currentUser!.phoneNumber);
        CreateData("User", user);
    }
    notifyListeners();
  }
}