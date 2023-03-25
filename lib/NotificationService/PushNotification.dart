import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as authFire;
import 'package:firebase_messaging/firebase_messaging.dart';


import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart';

import '../Models/User.dart';

class PushNotification{
   static authFire.FirebaseAuth auth = authFire.FirebaseAuth.instance;

  // for accessing cloud firestore database
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  // for accessing firebase storage
  static FirebaseStorage storage = FirebaseStorage.instance;

  // for storing self information


  // to return current user
  

  // for accessing firebase userssaging (Push Notification)
  static FirebaseMessaging fuserssaging = FirebaseMessaging.instance;

  // for getting firebase userssaging token
  static Future<void> getFirebaseMessagingToken(User user) async {
    await fuserssaging.requestPermission();

    await fuserssaging.getToken().then((t) {
      if (t != null) {
        user.token = t;
      }
    });
    await FirebaseFirestore.instance.collection("User").doc(user.id).update(user.toJson());

    // for handling foreground userssages
    // FirebaseMessaging.onuserssage.listen((Remoteuserssage userssage) {
    //   log('Got a userssage whilst in the foreground!');
    //   log('userssage data: ${userssage.data}');

    //   if (userssage.notification != null) {
    //     log('userssage also contained a notification: ${userssage.notification}');
    //   }
    // });
  }

  // for sending push notification
  static Future<void> sendPushNotification(
      User user, String msg,String tokenUser) async {
    try {
      print("send token:$tokenUser");
      final body = {
        "to": tokenUser,
        "notification": {
          // ignore: unnecessary_null_comparison
          "title": '${user.firstName ?? ""} ${user.lastName ?? ""}', //our nauser should be send
          "body": msg,
          "android_channel_id": "chats"
        },
        // "data": {
        //   "souser_data": "User ID: ${user.id}",
        // },
      };

      var res = await post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader:
                'key=AAAAbra5zWg:APA91bEeAWceB9ZkfrmkdP-GckZTnUC-TBYPsfDfVUZ9HXvH1VBVzgWCRxbqQBmLFxenX63aWnQJM73b19IF1oVUZRBy46UHMWlUfCCthge7GLvtoN9VyxXM5h1osH7UkS8zZvMMTxPa'
          },
          body: jsonEncode(body));
      print('Response status: ${res.statusCode}');
      print('Response body: ${res.body}');
    } catch (e) {
      print('\nsendPushNotificationE: $e');
    }
  }

  // for checking if user exists or not?
  // static Future<bool> userExists() async {
  //   return (await firestore.collection('users').doc(auth.currentUser!.uid).get()).exists;
  // }

  // // for adding an chat user for our conversation
  // static Future<bool> addUser(String email) async {
  //   final data = await firestore
  //       .collection('users')
  //       .where('email', isEqualTo: email)
  //       .get();

  //   log('data: ${data.docs}');

  //   if (data.docs.isNotEmpty && data.docs.first.id != auth.currentUser!.uid) {
  //     //user exists

  //     log('user exists: ${data.docs.first.data()}');

  //     firestore
  //         .collection('users')
  //         .doc(auth.currentUser!.uid)
  //         .collection('my_users')
  //         .doc(data.docs.first.id)
  //         .set({});

  //     return true;
  //   } else {
  //     //user doesn't exists

  //     return false;
  //   }
  // }

  // for getting current user info


  // for creating a new user
  

  // for getting id's of known users from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getMyUsersId() {
    return firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .collection('my_users')
        .snapshots();
  }

  // for getting all users from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers(
      List<String> userIds) {
    log('\nUserIds: $userIds');

    return firestore
        .collection('users')
        .where('id',
            whereIn: userIds.isEmpty
                ? ['']
                : userIds) //because empty list throws an error
        // .where('id', isNotEqualTo: auth.currentUser!.uid)
        .snapshots();
  }

  // for adding an user to my user when first userssage is send




  // update profile picture of user

  

  // update online or last active status of user
 

  // for sending userssage
 
  
}