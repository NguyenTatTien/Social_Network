

import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:do_an_tot_nghiep/Models/Call.dart';
import 'package:do_an_tot_nghiep/Models/ChatFinal.dart';
import 'package:do_an_tot_nghiep/Models/ChatRoom.dart';
import 'package:do_an_tot_nghiep/Models/CommentObject.dart';
import 'package:do_an_tot_nghiep/Models/FriendShip.dart';
import 'package:do_an_tot_nghiep/Models/GroupChat.dart';
import 'package:do_an_tot_nghiep/Models/Like.dart';
import 'package:do_an_tot_nghiep/Models/MemberGroupChat.dart';
import 'package:do_an_tot_nghiep/Models/Notification.dart';
import 'package:do_an_tot_nghiep/Models/Post.dart';
import 'package:do_an_tot_nghiep/Models/User.dart';
import 'package:do_an_tot_nghiep/Views/MemberGroup.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';

import '../Models/ShortVideo.dart';

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
  Future<List<Map<String,Object>>> listPost(String collection,String id,var data) async{
       var lsPost = <Post>[];
       var lsUserByPost = <User>[]; 
       var listObject = <Map<String,Object>>[];
    //    var lsFriendShipId = <String>[];
    //    lsFriendShipId.add(id);
    //  await FirebaseFirestore.instance.collection("FriendShip").where("Requester",isEqualTo: id).get().then((value){
    //       value.docs.forEach((result){
    //         if(FriendShip.fromJson(result.data()).status==true){
    //             lsFriendShipId.add(FriendShip.fromJson(result.data()).addressee!);
    //         }
           
    //       });
    //   });
    //    await FirebaseFirestore.instance.collection("FriendShip").where("Addressee",isEqualTo: id).get().then((value){
    //       value.docs.forEach((result){
    //           if(FriendShip.fromJson(result.data()).status==true){
    //           lsFriendShipId.add(FriendShip.fromJson(result.data()).requester!);
    //         }
            
    //       });
    //   });   
  
    // print(lsFriendShipId.length);
      // igno
      //varre: unnecessary_null_comparison
      if(data==null){
       

          await FirebaseFirestore.instance.collection(collection).orderBy("CreateDate",descending: true).limit(3).get().then((value){value.docs.forEach((result){
            
              lsPost.add(Post.fromJson(result.data()));
          
        
        
    });}); 
      }
      else{
         await FirebaseFirestore.instance.collection(collection).orderBy("CreateDate",descending: true).startAfter([data]).limit(3).get().then((value){value.docs.forEach((result){
       
              lsPost.add(Post.fromJson(result.data()));
          
            
        
        
    });}); 
      }
     
      //Stopwatch stopwatch = new Stopwatch()..start();
  
    //print('doSomething() executed in ${stopwatch.elapsed}'); 
   for(var post in lsPost){
          List<Like> likePosts = [];
          var docSnapshot =  await FirebaseFirestore.instance.collection("User").doc(post.createBy).get();
          var durationDate = DateTime.now().difference(post.createDate!);
        // ignore: prefer_interpolation_to_compose_strings
           var time = durationDate.inSeconds<60?durationDate.inSeconds.toString()+" giây":durationDate.inMinutes<60?durationDate.inMinutes.toString()+" phút":durationDate.inHours<24?durationDate.inHours.toString()+" giờ":durationDate.inDays<10?durationDate.inDays.toString()+" ngày":DateFormat("dd/MM/yyyy").format(post.createDate!).toString();
          await FirebaseFirestore.instance.collection("Like").where("ObjectId",isEqualTo: post.id).get().then((value) => {
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
   Future<GroupChat> getGroupChatById(String id) async{
     var collection = FirebaseFirestore.instance.collection("GroupChat");
     var docSnapshot =  await collection.doc(id).get();
     if(docSnapshot.data()!=null){
        return GroupChat.fromJson(docSnapshot.data()!);
     }
     else{
        return GroupChat();
     }
  }
  Future<List<Map<String,Object>>> getlistOthers(String id,var lastData) async{
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
      if(lastData==null){
        await FirebaseFirestore.instance.collection("User").where("Id",isNotEqualTo: id).orderBy("Id",descending: true).limit(10).get().then((value){
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
     
      }else{
            await FirebaseFirestore.instance.collection("User").where("Id",isNotEqualTo: id).orderBy("Id",descending: true).startAfter([lastData]).limit(5).get().then((value){
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
     
      }
    
      
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
  Future<List<Map<String,Object>>> loadCommentPost(String objectId,String type) async{
    var jsonListComment = <Map<String,Object>>[];
    
    await FirebaseFirestore.instance.collection("Comment").orderBy("CreateDate",descending: true).get().then((value) => 
    value.docs.where((element) => CommentObject.fromJson(element.data()).postId==objectId && CommentObject.fromJson(element.data()).parentId==""&&CommentObject.fromJson(element.data()).type==type).forEach((element) {
      jsonListComment.add({"parentComment":CommentObject.fromJson(element.data()),"userComment":User(),"jsonSubComment":<Map<String,Object>>[]});
     
    }));
    for(int i = 0;i<jsonListComment.length;i++){
      User user = await getUserById((jsonListComment[i]["parentComment"] as CommentObject).userId!);
      jsonListComment[i]["userComment"] = user;
      
      await FirebaseFirestore.instance.collection("Comment").orderBy("CreateDate",descending: false).get().then((value) => 
       value.docs.where((element) => CommentObject.fromJson(element.data()).postId==objectId && CommentObject.fromJson(element.data()).parentId==(jsonListComment[i]["parentComment"] as CommentObject).id && CommentObject.fromJson(element.data()).type == type).forEach((element) async{
        User user = await getUserById(CommentObject.fromJson(element.data()).userId!);
        (jsonListComment[i]["jsonSubComment"] as List<Map<String,Object>>).add({"subComment":CommentObject.fromJson(element.data()),"userSubComment":user});
     
    }));
     
    } 
    return jsonListComment;
  }
 
  Future<String> getRoomChatByUser(String user1, String user2) async{
    String id  =  ChatRoom.fromJson(await FirebaseFirestore.instance.collection("UserChat").get().then((value) => value.docs.firstWhere((element) => (ChatRoom.fromJson(element.data()).userFirstById==user1 && ChatRoom.fromJson(element.data()).userSecondById==user2) || (ChatRoom.fromJson(element.data()).userFirstById==user2 && ChatRoom.fromJson(element.data()).userSecondById==user1)).data())).id!;
    return id;

  }
  Future<ChatRoom> getObjectRoomChatByUser(String user1, String user2) async{
    var chatRoom  =  ChatRoom.fromJson(await FirebaseFirestore.instance.collection("UserChat").get().then((value) => value.docs.firstWhere((element) => (ChatRoom.fromJson(element.data()).userFirstById==user1 && ChatRoom.fromJson(element.data()).userSecondById==user2) || (ChatRoom.fromJson(element.data()).userFirstById==user2 && ChatRoom.fromJson(element.data()).userSecondById==user1)).data()));
    return chatRoom;

  }
  Future<List<Map<String,Object>>>getAllNotificationByUser(String userID,var lastData) async{
    var listNotification = <Map<String,Object>>[];
      if(lastData==null){
        await FirebaseFirestore.instance.collection("Notification").orderBy("CreateDate",descending: true).limit(10).get().then((value) => value.docs.where((element) => NotificationObject.fromJson(element.data()).receiver==userID).forEach((element) { 
              listNotification.add({"notification":NotificationObject.fromJson(element.data()),"sender":User()});
              }));
              
      }
      else{
        await FirebaseFirestore.instance.collection("Notification").orderBy("CreateDate",descending: true).startAfter([lastData]).limit(5).get().then((value) => value.docs.where((element) => NotificationObject.fromJson(element.data()).receiver==userID).forEach((element) { 
              listNotification.add({"notification":NotificationObject.fromJson(element.data()),"sender":User()});
        }));
              
      }
      for(var item in listNotification){
                  item['sender'] = await getUserById((item['notification'] as NotificationObject).sender!);
              }
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
          await FirebaseFirestore.instance.collection("Like").where("PostId",isEqualTo: post.id).get().then((value) => {
              value.docs.forEach((element) {
                likePosts.add(Like.fromJson(element.data()));
              })
          });
          listObject.add({"post":post,"user":User.fromJson(docSnapshot.data()!),"timePost":time,"listUserLikePost":likePosts});
   }
    return listObject;
  }
  Future<int> checkFriend(String user1, String user2)async{
       int check = 0;
     // ignore: await_only_futures, unrelated_type_equality_checks
     await FirebaseFirestore.instance.collection("FriendShip").get().then((value)
      => check = value.docs.where((element)
=>(FriendShip.fromJson(element.data()).addressee==user1&& FriendShip.fromJson(element.data()).requester==user2 && FriendShip.fromJson(element.data()).status == true ||(FriendShip.fromJson(element.data()).addressee==user2&&FriendShip.fromJson(element.data()).requester==user1 && FriendShip.fromJson(element.data()).status == true))).isNotEmpty 
? 3
: value.docs.where((element)
=>(FriendShip.fromJson(element.data()).addressee==user1&& FriendShip.fromJson(element.data()).requester==user2 && FriendShip.fromJson(element.data()).status == false)).isNotEmpty
?2
:value.docs.where((element)
=>(FriendShip.fromJson(element.data()).addressee==user2&& FriendShip.fromJson(element.data()).requester==user1 && FriendShip.fromJson(element.data()).status == false)).isNotEmpty?1:0);
     return check;
  }
  Future<bool> makeCall(Call call) async{
    try{
    call.hasDialled = true;
    call.id = call.callerId;
    Map<String,dynamic> hasDialledMap = call.toJson();
    call.id = call.receiverId;
    call.hasDialled = false;
    Map<String,dynamic> hasNotDialledMap = call.toJson();
    await FirebaseFirestore.instance.collection("Call").doc(call.callerId).set(hasDialledMap);
    await FirebaseFirestore.instance.collection("Call").doc(call.receiverId).set(hasNotDialledMap);
      return true;
    }catch(e){
        print(e);
        return false;
    }
  }
  Future<bool> endCall(Call call) async{
    try{
      await FirebaseFirestore.instance.collection("Call").doc(call.callerId).delete();
    await FirebaseFirestore.instance.collection("Call").doc(call.receiverId).delete();
    return true; 
    }catch(e){
      return false;
    }
  }
  Stream<DocumentSnapshot> callStream(String id)=> FirebaseFirestore.instance.collection("Call").doc(id).snapshots();
  Future<Like> checkLike(String userId, String postId) async{
  var like = Like();
   await FirebaseFirestore.instance.collection("Like").where("UserId",isEqualTo: userId).where("ObjectId",isEqualTo: postId).get().then((value) => value.docs.isNotEmpty?value.docs.forEach((element) {
      like = Like.fromJson(element.data());
    }):like=Like());
    return like;
  }
  updateLikePost(Like like) async{
      await FirebaseFirestore.instance.collection("Like").doc(like.id).update(like.toJson());
  }
  removePostById(String id) async{
      List<Like> listLikes = <Like>[];
      List<CommentObject> comments = <CommentObject>[];
      await FirebaseFirestore.instance.collection("Post").doc(id).delete();
      await FirebaseFirestore.instance.collection("Like").where("PostId",isEqualTo: id).get().then((value) => value.docs.forEach((element) {
        listLikes.add(Like.fromJson(element.data()));
      }));
      await FirebaseFirestore.instance.collection("Comment").where("PostId",isEqualTo: id).get().then((value) => value.docs.forEach((element) {
        comments.add(CommentObject.fromJson(element.data()));
      }));
      for(var item in listLikes){
        await FirebaseFirestore.instance.collection("Like").doc(item.id).delete();
      }
       for(var item in comments){
        await FirebaseFirestore.instance.collection("Comment").doc(item.id).delete();
      }
  }
  Future<String> updateImageByPost(String url,String path,File file)async{
      await FirebaseStorage.instance.refFromURL(url).delete();
      var chilPath = await FirebaseStorage.instance.ref().child(path);
      chilPath.putFile(file);
       String urlImage = await chilPath.getDownloadURL();
      return urlImage;
  }
  Future<List<Map<String,Object>>> getListShortVideo(String userId)async{
    List<Map<String,Object>> listShortVideo = [];
     await FirebaseFirestore.instance.collection("ShortVideo").orderBy("CreateDate",descending: true).get().then((value) => value.docs.forEach((element) { 
        listShortVideo.add({"shortvideo":ShortVideo.fromJson(element.data()),"isLike":false,});
     }));
     for(var item in listShortVideo){
      var shortvideo = (item["shortvideo"] as ShortVideo);
        await FirebaseFirestore.instance.collection("Like").where("UserId",isEqualTo: userId).where("ObjectId",isEqualTo: shortvideo.id).where("ObjectType",isEqualTo: "video").get().then((value) => item["isLike"]=value.docs.isNotEmpty?true:false);
     }
     return listShortVideo;
  }

 Future<Like> getLike(String userId,String objectId)async{
     Like like = Like();
     await FirebaseFirestore.instance.collection("Like").where("UserId",isEqualTo: userId).where("ObjectId",isEqualTo: objectId).where("ObjectType",isEqualTo: "video").snapshots().first.then((value) => like = Like.fromJson(value.docs.first.data()));
     return like;
  }
  Future<int> countListFriend(String userId)async{
    int count = 0;
     await FirebaseFirestore.instance.collection("FriendShip").get().then((value) => count = value.docs.where((element) => (FriendShip.fromJson(element.data()).addressee==userId ||FriendShip.fromJson(element.data()).requester==userId)&&FriendShip.fromJson(element.data()).status==true).length);
     return count;
  }
  Future<List<Map<String,Object>>> listRoomChat(String userId)async{
    var roomChats = <Map<String,Object>>[];
    
    return roomChats;
  }
  Future<ChatRoom> getChatRoom(String userFirst,String userSecond) async{
    ChatRoom chatRoom = ChatRoom();
     await FirebaseFirestore.instance.collection("UserChat").get().then((value) => chatRoom = ChatRoom.fromJson(value.docs.firstWhere((element) => (ChatRoom.fromJson(element.data()).userFirstById==userFirst && ChatRoom.fromJson(element.data()).userFirstById==userSecond)|| (ChatRoom.fromJson(element.data()).userFirstById==userSecond && ChatRoom.fromJson(element.data()).userSecondById==userFirst)).data()));
     return chatRoom;
  }
   
  Future<ChatFinal> getChatFinal(String objectId) async{
    ChatFinal chatFinal = ChatFinal();
   var doc = await FirebaseFirestore.instance.collection("Chat").doc(objectId).get();
    chatFinal = ChatFinal.fromJson(doc.data()!);
     return chatFinal;
  }
 
  deleteChatRoom(String id)async{
    await FirebaseFirestore.instance.collection("UserChat").doc(id).delete();
  }
  deleteChatFinal(String id)async{
    await FirebaseFirestore.instance.collection("Chat").doc(id).delete();
  }
 uploadChatFinal(ChatFinal chatFinal)async{
    await FirebaseFirestore.instance.collection("Chat").doc(chatFinal.id).update(chatFinal.toJson());
 }
 Future<List<String>> getListMemberInGroup(String groupId) async{
  List<String> listMember = [];
  await FirebaseFirestore.instance.collection("GroupChat").doc(groupId).collection("Member").get().then((value) => value.docs.forEach((element) { 
    listMember.add(MemberGroupChat.fromJson(element.data()).userId!);
  }));
  return listMember;
 }
 Future<List<User>> lsFiendNotJoinGroupChat(String groupId,String id,List<User> members) async{

   var lsFriendShip = <FriendShip>[];
    var listObject = <User>[];
     await FirebaseFirestore.instance.collection("FriendShip").where("Requester",isEqualTo: id).where("").get().then((value){
          value.docs.forEach((result){
            // ignore: iterable_contains_unrelated_type
            if(!members.where((e)=>e.id == FriendShip.fromJson(result.data()).addressee).isNotEmpty){

                lsFriendShip.add(FriendShip.fromJson(result.data()));
            }
          
          });
      });
       await FirebaseFirestore.instance.collection("FriendShip").where("Addressee",isEqualTo: id).get().then((value){
          value.docs.forEach((result){
             // ignore: iterable_contains_unrelated_type
             if(!members.where((e)=>e.id == FriendShip.fromJson(result.data()).requester).isNotEmpty){
          
                lsFriendShip.add(FriendShip.fromJson(result.data()));
            }
          });
      });
      await FirebaseFirestore.instance.collection("User").where("Id",isNotEqualTo: id).orderBy("Id",descending: true).get().then((value){
                value.docs.forEach((result){
                  var user = User.fromJson(result.data());
                  if(lsFriendShip.where((element) => element.addressee==user.id||element.requester==user.id).toList().isNotEmpty){
                      if(lsFriendShip.firstWhere((element) => element.addressee==user.id||element.requester==user.id).status==true){
                         listObject.add(user);
                      }
                  }
                 
                });
      });
      return listObject;
 }
 insertMemberGroup(MemberGroupChat memberGroupChat)async{
    await FirebaseFirestore.instance.collection("GroupChat").doc(memberGroupChat.groupId).collection("Member").add(memberGroupChat.toJson());
 }
 Future<MemberGroupChat> getMemberGroup(String groupId,String userId)async{
    MemberGroupChat memberGroupChat = MemberGroupChat();
    await FirebaseFirestore.instance.collection("GroupChat").doc(groupId).collection("Member").where("UserId").get().then((value) => memberGroupChat = MemberGroupChat.fromJson(value.docs.first.data()));
    return memberGroupChat;
 }
 removeMemberGroup(String memberId,String groupId)async{
    await FirebaseFirestore.instance.collection("GroupChat").doc(groupId).collection("Member").doc(memberId).delete();
 }
Future<bool> checkMemberGroup(GroupChat groupChat,String userId)async{
  bool check = false;
   await FirebaseFirestore.instance.collection("GroupChat").doc(groupChat.id).collection("Member").get().then((value) => check = value.docs.where((element) => MemberGroupChat.fromJson(element.data()).userId==userId).isNotEmpty?true:false);
  return check;
}
Future<int> countMemberGroup(String groupId)async{
  int count = 0;
   await FirebaseFirestore.instance.collection("GroupChat").doc(groupId).collection("Member").get().then((value) => count = value.docs.length);
   return count;
}
Future<String> getChatFinalId(String objectId,String type)async{
   String id = "";
   if(type=="user"){
      await FirebaseFirestore.instance.collection("Chat").get().then((value) =>id = ChatFinal.fromJson(value.docs.firstWhere((element) => ChatFinal.fromJson(element.data()).typeChat==type && element.data()["Object"]["Id"]==objectId).data()).id!);
   }
  
   return id;
}