

import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:do_an_tot_nghiep/Models/ChatRoom.dart';
import 'package:do_an_tot_nghiep/Models/CommentPost.dart';
import 'package:do_an_tot_nghiep/Models/FriendShip.dart';
import 'package:do_an_tot_nghiep/Models/Like.dart';
import 'package:do_an_tot_nghiep/Models/Notification.dart';
import 'package:do_an_tot_nghiep/Models/Post.dart';
import 'package:do_an_tot_nghiep/Models/User.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';

  // ignore: non_constant_identifier_names
   CreateData(String collection,var object) async{
    DocumentReference documentReference = FirebaseFirestore.instance.collection(collection).doc(object.id);
  
    final json = object.toJson();
    await documentReference.set(json);
  }
  // ignore: non_constant_identifier_names
  CreateNewData(String collection,var object) async{
    DocumentReference documentReference = FirebaseFirestore.instance.collection(collection).doc();
    object.id = documentReference.id;
    final json = object.toJson();
    await documentReference.set(json);
  }
  // ignore: non_constant_identifier_names
  Future<List<Map<String,Object>>> listPost(String collection,String id) async{
       var lsPost = <Post>[];
       var lsUserByPost = <User>[]; 
       var listObject = <Map<String,Object>>[];
       var lsFriendShipId = <String>[];
       lsFriendShipId.add(id);
     await FirebaseFirestore.instance.collection("FriendShip").where("Requester",isEqualTo: id).get().then((value){
          value.docs.forEach((result){
            if(FriendShip.fromJson(result.data()).status==true){
                lsFriendShipId.add(FriendShip.fromJson(result.data()).addressee!);
            }
           
          });
      });
       await FirebaseFirestore.instance.collection("FriendShip").where("Addressee",isEqualTo: id).get().then((value){
          value.docs.forEach((result){
              if(FriendShip.fromJson(result.data()).status==true){
              lsFriendShipId.add(FriendShip.fromJson(result.data()).requester!);
            }
            
          });
      });   
      
    await FirebaseFirestore.instance.collection(collection).orderBy("CreateDate",descending: true).get().then((value){value.docs.forEach((result){
        if(lsFriendShipId.contains(Post.fromJson(result.data()).createBy)){
            lsPost.add(Post.fromJson(result.data()));
        }
        
    });});  
   for(var post in lsPost){
          List<Like> likePosts = [];
          var docSnapshot =  await FirebaseFirestore.instance.collection("User").doc(post.createBy).get();
          var durationDate = DateTime.now().difference(post.createDate!);
        // ignore: prefer_interpolation_to_compose_strings
           var time = durationDate.inSeconds<60?durationDate.inSeconds.toString()+" giây":durationDate.inMinutes<60?durationDate.inMinutes.toString()+" phút":durationDate.inHours<24?durationDate.inHours.toString()+" giờ":durationDate.inDays<10?durationDate.inDays.toString()+" ngày":DateFormat("dd/MM/yyyy").format(post.createDate!).toString();
          await FirebaseFirestore.instance.collection("LikePost").where("PostId",isEqualTo: post.id).get().then((value) => {
              value.docs.forEach((element) {
                likePosts.add(Like.fromJson(element.data()));
              })
          });
          listObject.add({"post":post,"user":User.fromJson(docSnapshot.data()!),"timePost":time,"listUserLikePost":likePosts});
   }
    return listObject;
  }
  updateData(String collection,var object)async{
      await FirebaseFirestore.instance.collection(collection).doc(object.id).update((object).toJson());
  }
    Future<User> getUserById(String id) async{
     var collection = FirebaseFirestore.instance.collection("User");
     var docSnapshot =  await collection.doc(id).get();
     if(docSnapshot.data()!=null){
        return User.fromJson(docSnapshot.data()!);
     }
     else{
        return User();
     }
     
  }
  Future<List<Map<String,Object>>> getlistOthers(String id) async{
    var lsFriendShip = <FriendShip>[];
    var listObject = <Map<String,Object>>[];
     await FirebaseFirestore.instance.collection("FriendShip").where("Requester",isEqualTo: id).get().then((value){
          value.docs.forEach((result){
            
            lsFriendShip.add(FriendShip.fromJson(result.data()));
          });
      });
       await FirebaseFirestore.instance.collection("FriendShip").where("Addressee",isEqualTo: id).get().then((value){
          value.docs.forEach((result){
            lsFriendShip.add(FriendShip.fromJson(result.data()));
          });
      });
      await FirebaseFirestore.instance.collection("User").where("Id",isNotEqualTo: id).get().then((value){
          value.docs.forEach((result){
            var user = User.fromJson(result.data());
            if(lsFriendShip.where((element) => element.addressee==user.id||element.requester==user.id).toList().isNotEmpty){
                if(lsFriendShip.firstWhere((element) => element.addressee==user.id||element.requester==user.id).status==false){
                    if(lsFriendShip.where((element) => element.addressee==user.id).isNotEmpty){
                         listObject.add({"user":user,"status":1});
                    }
                    else if(lsFriendShip.where((element) => element.requester==user.id).isNotEmpty){
                        listObject.add({"user":user,"status":2});
                    }
                }
                else{
                  listObject.add({"user":user,"status":3});
                }
            }
            else{
              listObject.add({"user":user,"status":0});
            }
          });
      });
     
      
      return listObject;
  }
  Future makeFriend(String requesterId,String addresseeId) async{
     var object = await FirebaseFirestore.instance.collection("FriendShip").where("Requester",isEqualTo: requesterId).where("Addressee",isEqualTo: addresseeId).get().then((value) => value.docs.firstWhere((element) => FriendShip.fromJson(element.data()).requester==requesterId&&FriendShip.fromJson(element.data()).addressee==addresseeId).data());
     FriendShip getFriendShip = FriendShip.fromJson(object);
     getFriendShip.status = true;
     await FirebaseFirestore.instance.collection("FriendShip").doc(getFriendShip.id).update(getFriendShip.toJson());
  }
  Future deleteFriend(String requesterId,String addresseeId) async{
     var object = await FirebaseFirestore.instance.collection("FriendShip").get().then((value) => value.docs.firstWhere((element) => (FriendShip.fromJson(element.data()).requester==requesterId&&FriendShip.fromJson(element.data()).addressee==addresseeId)||((FriendShip.fromJson(element.data()).requester==addresseeId&&FriendShip.fromJson(element.data()).addressee==requesterId))).data());
     FriendShip getFriendShip = FriendShip.fromJson(object);
     await FirebaseFirestore.instance.collection("FriendShip").doc(getFriendShip.id).delete();
  }
  Future<List<User>> getAllFriend(String id) async{
    var lsFriendShip = <FriendShip>[];
    var lsUserbyFriend = <User>[];
      await FirebaseFirestore.instance.collection("FriendShip").where("Requester",isEqualTo: id).where("Status",isEqualTo: true).get().then((value){
          value.docs.forEach((result){
            lsFriendShip.add(FriendShip.fromJson(result.data()));
          });
      });
       await FirebaseFirestore.instance.collection("FriendShip").where("Addressee",isEqualTo: id).where("Status",isEqualTo: true).get().then((value){
          value.docs.forEach((result){
            lsFriendShip.add(FriendShip.fromJson(result.data()));
          });
      });
      for(var item in lsFriendShip){
          if(item.requester==id){
            var user = await FirebaseFirestore.instance.collection("User").doc(item.addressee).get();
            lsUserbyFriend.add(User.fromJson(user.data()!));
          }
          else{
            var user = await FirebaseFirestore.instance.collection("User").doc(item.requester).get();
            lsUserbyFriend.add(User.fromJson(user.data()!));
          }
      }
      return lsUserbyFriend;
  }
  updatePost(Post post) async{
      await FirebaseFirestore.instance.collection("Post").doc(post.id).update(post.toJson());
  }
  removeData(String collection,String id) async{
    await FirebaseFirestore.instance.collection(collection).doc(id).delete();
  }
  Future<List<Map<String,Object>>> loadCommentPost(String postId) async{
    var jsonListComment = <Map<String,Object>>[];
    
    await FirebaseFirestore.instance.collection("Comment").orderBy("CreateDate",descending: true).get().then((value) => 
    value.docs.where((element) => CommentPost.fromJson(element.data()).postId==postId && CommentPost.fromJson(element.data()).parentId=="").forEach((element) {
      jsonListComment.add({"parentComment":CommentPost.fromJson(element.data()),"userComment":User(),"jsonSubComment":<Map<String,Object>>[]});
     
    }));
    for(int i = 0;i<jsonListComment.length;i++){
      User user = await getUserById((jsonListComment[i]["parentComment"] as CommentPost).userId!);
      jsonListComment[i]["userComment"] = user;
      
      await FirebaseFirestore.instance.collection("Comment").orderBy("CreateDate",descending: false).get().then((value) => 
       value.docs.where((element) => CommentPost.fromJson(element.data()).postId==postId && CommentPost.fromJson(element.data()).parentId==(jsonListComment[i]["parentComment"] as CommentPost).id).forEach((element) async{
        User user = await getUserById(CommentPost.fromJson(element.data()).userId!);
        (jsonListComment[i]["jsonSubComment"] as List<Map<String,Object>>).add({"subComment":CommentPost.fromJson(element.data()),"userSubComment":user});
     
    }));
     
    } 
    return jsonListComment;
  }
  Future<String> getRoomChatByUser(String user1, String user2) async{
    String id  =  ChatRoom.fromJson(await FirebaseFirestore.instance.collection("ChatRoom").get().then((value) => value.docs.firstWhere((element) => (ChatRoom.fromJson(element.data()).userFirst==user1 && ChatRoom.fromJson(element.data()).userSecond==user2) || (ChatRoom.fromJson(element.data()).userFirst==user2 && ChatRoom.fromJson(element.data()).userSecond==user1)).data())).id!;
    return id;

  }
  Future<ChatRoom> getObjectRoomChatByUser(String user1, String user2) async{
    var chatRoom  =  ChatRoom.fromJson(await FirebaseFirestore.instance.collection("ChatRoom").get().then((value) => value.docs.firstWhere((element) => (ChatRoom.fromJson(element.data()).userFirst==user1 && ChatRoom.fromJson(element.data()).userSecond==user2) || (ChatRoom.fromJson(element.data()).userFirst==user2 && ChatRoom.fromJson(element.data()).userSecond==user1)).data()));
    return chatRoom;

  }
  Future<List<Map<String,Object>>>getAllNotificationByUser(String userID) async{
    var listNotification = <Map<String,Object>>[];

       await FirebaseFirestore.instance.collection("Notification").orderBy("CreateDate",descending: true).get().then((value) => value.docs.where((element) => NotificationObject.fromJson(element.data()).receiver==userID).forEach((element) { 
          listNotification.add({"notification":NotificationObject.fromJson(element.data()),"sender":User()});
       }));
       for(var item in listNotification){
          item['sender'] = await getUserById((item['notification'] as NotificationObject).sender!);
       }
       print(listNotification.length);
       return listNotification;
  }
  Future<bool> checkUserByEmail(String email)async {
    bool check = false;
     // ignore: await_only_futures, unrelated_type_equality_checks
     await FirebaseFirestore.instance.collection("User").where("Email",isEqualTo: email).get().then((value) => check = value.docs.isNotEmpty ? true: false);
     return check;
  }
  Future<List<Map<String,Object>>> listPostByUser(String id) async{
       var lsPost = <Post>[];
       var lsUserByPost = <User>[]; 
       var listObject = <Map<String,Object>>[];
          
      
    await FirebaseFirestore.instance.collection("Post").orderBy("CreateDate",descending: true).get().then((value){value.docs.forEach((result){
        if(Post.fromJson(result.data()).createBy == id){
            lsPost.add(Post.fromJson(result.data()));
        }
        
    });});  
   for(var post in lsPost){
          List<Like> likePosts = [];
          var docSnapshot =  await FirebaseFirestore.instance.collection("User").doc(post.createBy).get();
          var durationDate = DateTime.now().difference(post.createDate!);
        // ignore: prefer_interpolation_to_compose_strings
           var time = durationDate.inSeconds<60?durationDate.inSeconds.toString()+" giây":durationDate.inMinutes<60?durationDate.inMinutes.toString()+" phút":durationDate.inHours<24?durationDate.inHours.toString()+" giờ":durationDate.inDays<10?durationDate.inDays.toString()+" ngày":DateFormat("dd/MM/yyyy").format(post.createDate!).toString();
          await FirebaseFirestore.instance.collection("LikePost").where("PostId",isEqualTo: post.id).get().then((value) => {
              value.docs.forEach((element) {
                likePosts.add(Like.fromJson(element.data()));
              })
          });
          listObject.add({"post":post,"user":User.fromJson(docSnapshot.data()!),"timePost":time,"listUserLikePost":likePosts});
   }
    return listObject;
  }
  Future<bool> checkFriend(String user1, String user2)async{
       bool check = false;
     // ignore: await_only_futures, unrelated_type_equality_checks
     await FirebaseFirestore.instance.collection("FriendShip").where("Status",isEqualTo: true).get().then((value) => value.docs.where((element) =>check =  (FriendShip.fromJson(element.data()).addressee==user1&& FriendShip.fromJson(element.data()).requester==user2||(FriendShip.fromJson(element.data()).addressee==user2&&FriendShip.fromJson(element.data()).requester==user1))).isNotEmpty ? true: false);
     return check;
  }
   
