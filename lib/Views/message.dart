import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:do_an_tot_nghiep/DAO/DAOHepper.dart';
import 'package:do_an_tot_nghiep/Models/ChatFinal.dart';
import 'package:do_an_tot_nghiep/Models/ChatRoom.dart';
import 'package:do_an_tot_nghiep/Models/GroupChat.dart';
import 'package:do_an_tot_nghiep/Models/MemberGroupChat.dart';
import 'package:do_an_tot_nghiep/Views/Chat.dart';
import 'package:do_an_tot_nghiep/Views/ChatGroup.dart';
import 'package:do_an_tot_nghiep/Views/Design.dart';
import 'package:do_an_tot_nghiep/Views/Guest.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../Models/User.dart';

class Message extends StatefulWidget {
  const Message({ Key? key }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _MessageState createState() => _MessageState();
}

class _MessageState extends State<Message> {

  List<User> _users = [];

  var controllerGroup = TextEditingController();
  List<User> _foundedUsers = [];
  String roomId = "";
  String search = "";
  List<Map<String,Object>> _listRoomChat = [];
  List<Map<String,Object>>  _lsRoomeChat= [];
  List<bool> checks = <bool>[];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
      Map<String, Object>? mapRoom = <String,Object>{};
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getListFriend();
     
  
   
   
  }
  
  getListFriend() async{
     _users = await getAllFriend(auth.FirebaseAuth.instance.currentUser!.uid);
    setState(() {
      _foundedUsers = _users;
    });
  }
  onSearch(String search) {
    setState(() {
      _lsRoomeChat = _listRoomChat.where((element) => element["typeChat"]=="user"? ("${(User.fromJson2(element["object"] as Map<String,dynamic>)).firstName!} ${(User.fromJson2(element["object"] as Map<String,dynamic>)).lastName!}").contains(search):GroupChat.formJson2(element["object"]as Map<String,dynamic>).groupName!.contains(search)).toList();
      this.search = search;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 80,
        backgroundColor: Colors.white,
        title: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [

            Container(margin: EdgeInsets.only(bottom: 10),child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children:  [
              Flexible(child:Align(alignment: Alignment.topRight,child: Text("Tin nhắn",style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 20)),),flex: 3,),
              Flexible(flex: 2,child:Align(alignment: Alignment.topRight,child: InkWell(onTap: (){ showDialog(context: context, builder: (BuildContext context) {
                return AlertDialog(
                    title: const Text("Tạo nhóm chat"),
                    content:    
            TextField(
              controller: controllerGroup,
              
              decoration: InputDecoration(
                  border: OutlineInputBorder(
                borderSide: const BorderSide(color: Color.fromARGB(255, 0, 64, 255), width: 1),),
                  fillColor: Color.fromARGB(255, 255, 255, 255),
                  filled: true,hintText: "Nhập tên nhóm")),
                    actions: [
                      ElevatedButton(onPressed: (){ Navigator.pop(context);}, child: const Text("Thoát")),
                      ElevatedButton(onPressed: (){createGroupChat();Navigator.of(context).pop();}, child: const Text("Tạo nhóm"))
                    ],
                );
              });},child:const Icon(Icons.group_add_outlined,size: 22,color: mainColor),)),)
        ],)),
            SizedBox(
          height: 40,
          child: TextField(
            onChanged: (value) => onSearch(value),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xfff3f3f4),
              contentPadding: const EdgeInsets.all(0),
              prefixIcon: Icon(Icons.search, color: Colors.grey.shade500,),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50),
                borderSide: BorderSide.none
              ),
              hintStyle: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500
              ),
              hintText: "Tìm kiếm"
            ),
          )),
          ]
        ),
      ),
      body: Container(
        color: Colors.white,
        // ignore: prefer_is_empty
        // child: _foundedUsers.length > 0 ? ListView.builder(
        //   itemCount: _foundedUsers.length,
        //   itemBuilder: (context, index) {
        //     return Slidable(
        //       actionPane: const SlidableDrawerActionPane(),
        //       actionExtentRatio: 0.25,
        //       child: userComponent(user: _foundedUsers[index]),
        //       actions: <Widget>[
        //         IconSlideAction(
        //           caption: 'Archive',
        //           color: Colors.transparent,
        //           icon: Icons.archive,
                  
        //           onTap: () => print("archive"),
        //         ),
        //         IconSlideAction(
        //           caption: 'Share',
        //           color: Colors.transparent,
        //           icon: Icons.share,
        //           // ignore: avoid_print
        //           onTap: () => print('Share'),
        //         ),
        //       ],
        //       secondaryActions: <Widget>[
        //         IconSlideAction(
        //           caption: 'More',
        //           color: Colors.transparent,
        //           icon: Icons.more_horiz,
        //           // ignore: avoid_print
        //           onTap: () => print('More'),
        //         ),
        //         IconSlideAction(
        //           caption: 'Delete',
        //           color: Colors.transparent,
        //           icon: Icons.delete,
        //           // ignore: avoid_print
        //           onTap: () => print('Delete'),
        //         ),
        //       ],
        //     );
        //   }) : const Center(child: Text("No users found", style: TextStyle(color: Colors.white),)),
          child:  StreamBuilder<QuerySnapshot>(
                
                stream: _firestore
                    .collection('Chat')
                    .orderBy("ChatFinalDate", descending: true)
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                    
                  if (snapshot.data != null){
                    if(checks.length<snapshot.data!.docs.length){

                      checks = List<bool>.filled(snapshot.data!.docs.length, false);
                 //     _lsRoomeChat = List<Map<String,Object>>.filled(snapshot.data!.docs.length, {"idChatFinal":"","idChat":"","object": <String,dynamic>{},"typeChat":"","chatFinal":"","chatFinalDate":DateTime});
                    }
                    return ListView.builder(
                      //controller: scrollController,
                    
                      
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                       // convertToMapChatMap(snapshot.data!.docs[index].data() as Map<String,dynamic>,index);
                      Map<String, dynamic> map = {"ObjectChat": snapshot.data!.docs[index]
                            .data() as Map<String, dynamic>,"index":index};   
                   
                      
                                      
                        return 
                        Column(children: [  
                         // ignore: unnecessary_null_comparison
                         map!=null?Slidable(
                              actionPane: const SlidableDrawerActionPane(),
                              actionExtentRatio: 0.25,
                              child:  userComponent(mapChat:map),
                            // child: Container(child:Text("${map}")),
                              // actions: <Widget>[
                              //   IconSlideAction(
                              //     caption: 'Archive',
                              //     color: Colors.transparent,
                              //     icon: Icons.archive,
                                  
                              //     onTap: () => print("archive"),
                              //   ),
                              //   IconSlideAction(
                              //     caption: 'Share',
                              //     color: Colors.transparent,
                              //     icon: Icons.share,
                              //     // ignore: avoid_print
                              //     onTap: () => print('Share'),
                              //   ),
                              // ],
                              // secondaryActions: <Widget>[
                              //   IconSlideAction(
                              //     caption: 'More',
                              //     color: Colors.transparent,
                              //     icon: Icons.more_horiz,
                              //     // ignore: avoid_print
                              //     onTap: () => print('More'),
                              //   ),
                              //   IconSlideAction(
                              //     caption: 'Delete',
                              //     color: Colors.transparent,
                              //     icon: Icons.delete,
                              //     // ignore: avoid_print
                              //     onTap: () => print('Delete'),
                              //   ),
                              // ],
                            ):
                          Container(),
                         
                        ]);
                      },
                    );
                  } else {
                    return Center(child: Text("Kết bạn hoặc tạo nhóm nhắn tin đi."),);
                  }
                },
              ),
      ),
    );
  }
  str(){
    _firestore
                    .collection('ChatFinal')
                    .orderBy("ChatFinalDate", descending: true)
                    .snapshots();
    
  }

  // userComponent({required User user}) {
  //   return InkWell(onTap: (){
  //     getRoomChat(user.id!);
  //     if(roomId!=""){
  //         Navigator.push(context, MaterialPageRoute(builder: (context)=> MyChat(userMap: user,chatRoomId: roomId,)));
  //     }
      
  //   },child:Container(
  //     margin: const EdgeInsets.symmetric(horizontal: 10),
  //     padding: const EdgeInsets.only(top: 10, bottom: 10),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //       children: [
  //         Row(
  //           children: [
  //              Container(
  //                   width: 50,
  //                   height: 50,
  //                   decoration: BoxDecoration(
  //                     shape: BoxShape.circle,
  //                     image: DecorationImage(
  //                       image:  NetworkImage('${user.image}'),
  //                       fit: BoxFit.cover,
  //                     ),
  //                   ),
  //                 ),
                
  //             const SizedBox(width: 10),
  //             Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Text(user.firstName!+" "+user.lastName!, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w500)),
  //                 const SizedBox(height: 5,),
  //                 Text(user.email!, style: TextStyle(color: Colors.grey[500])),
  //               ]
  //             )
  //           ]
  //         ),
  //         // GestureDetector(
  //         //   onTap: () {
  //         //     setState(() {
  //         //       user.isFollowedByMe = !user.isFollowedByMe;
  //         //     });
  //         //   },
  //         //   child: AnimatedContainer(
  //         //     height: 35,
  //         //     width:80,
  //         //     duration: const Duration(milliseconds: 300),
  //         //     decoration: BoxDecoration(
  //         //       color: user.isFollowedByMe ? Colors.blue[700] : const Color(0x00ffffff),
  //         //       borderRadius: BorderRadius.circular(5),
  //         //       border: Border.all(color: user.isFollowedByMe ? Colors.transparent : Colors.grey.shade700,)
  //         //     ),
  //         //     child: Center(
  //         //       child: Text(user.isFollowedByMe ? 'Unfollow' : 'Follow', style: TextStyle(color: user.isFollowedByMe ? Colors.white : Colors.white))
  //         //     )
  //         //   ),
  //         // )
  //       ],
  //     ),
  //   ));
  // }
  checkUserChat(Map<String,dynamic> mapChat){

    ChatRoom chatRoom = ChatRoom.fromJson(mapChat["ObjectChat"]["Object"] as Map<String,dynamic>);

    if(chatRoom.userFirstById==auth.FirebaseAuth.instance.currentUser!.uid||chatRoom.userSecondById==auth.FirebaseAuth.instance.currentUser!.uid){
    
        checks[mapChat["index"]] = true;
      
    }

  }
 checkGroupChat(Map<String,dynamic> mapChat,String userId) async{

  GroupChat groupChat = GroupChat.fromJson(mapChat["ObjectChat"]["Object"] as Map<String,dynamic>);

     await checkMemberGroup(groupChat, userId).then((value) =>   setState(() {
      checks[mapChat["index"]]=value;
}));

      
      
    
  }
   userComponent({required Map<String,dynamic> mapChat}){
    if(mapChat["ObjectChat"]["TypeChat"]!=null){


      
     mapChat["ObjectChat"]["TypeChat"]=="user"?checkUserChat(mapChat): checkGroupChat(mapChat,auth.FirebaseAuth.instance.currentUser!.uid);
 
       if(checks[mapChat["index"]]){
        return InkWell(onTap: (){
      if(mapChat["ObjectChat"]!=""){
         mapChat["ObjectChat"]["TypeChat"]=="user"?Navigator.push(context, MaterialPageRoute(builder: (context)=> MyChat(userMapId:ChatRoom.fromJson(mapChat["ObjectChat"]["Object"] as Map<String,dynamic>).userFirstById!=auth.FirebaseAuth.instance.currentUser!.uid?ChatRoom.fromJson(mapChat["ObjectChat"]["Object"] as Map<String,dynamic>).userFirstById!:ChatRoom.fromJson(mapChat["ObjectChat"]["Object"] as Map<String,dynamic>).userSecondById!,chatRoomId: ChatRoom.fromJson(mapChat["ObjectChat"]["Object"] as Map<String,dynamic>).id!,chatfinalId: mapChat["ObjectChat"]["Id"].toString(),))):Navigator.push(context, MaterialPageRoute(builder: (context)=> ChatGroup(groupChat:(GroupChat.fromJson(mapChat["ObjectChat"]["Object"] as Map<String,dynamic>)),chatFinalId:mapChat["ObjectChat"]["Id"].toString() ,)));
      }
      
      
    },child:Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
               Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image:  NetworkImage(mapChat["ObjectChat"]["TypeChat"]=="user"?'${ChatRoom.fromJson(mapChat["ObjectChat"]["Object"] as Map<String,dynamic>).userFirstById!=auth.FirebaseAuth.instance.currentUser!.uid?ChatRoom.fromJson(mapChat["ObjectChat"]["Object"] as Map<String,dynamic>).userFirstByImage:ChatRoom.fromJson(mapChat["ObjectChat"]["Object"] as Map<String,dynamic>).userSecondByImage}':'${(GroupChat.fromJson(mapChat["ObjectChat"]["Object"] as Map<String,dynamic>)).avatarGroup}'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(mapChat["ObjectChat"]["TypeChat"]=="user"?'${ChatRoom.fromJson(mapChat["ObjectChat"]["Object"] as Map<String,dynamic>).userFirstById!=auth.FirebaseAuth.instance.currentUser!.uid?ChatRoom.fromJson(mapChat["ObjectChat"]["Object"] as Map<String,dynamic>).userFirstByFullName:ChatRoom.fromJson(mapChat["ObjectChat"]["Object"] as Map<String,dynamic>).userSecondByFullName}':'${(GroupChat.fromJson(mapChat["ObjectChat"]["Object"] as Map<String,dynamic>)).groupName}', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 5,),
                  Text(mapChat["ObjectChat"]["ChatContentFinal"].toString(), style: TextStyle(color: Colors.grey[500])),
                ]
              )
            ]
          ),
          // GestureDetector(
          //   onTap: () {
          //     setState(() {
          //       user.isFollowedByMe = !user.isFollowedByMe;
          //     });
          //   },
          //   child: AnimatedContainer(
          //     height: 35,
          //     width:80,
          //     duration: const Duration(milliseconds: 300),
          //     decoration: BoxDecoration(
          //       color: user.isFollowedByMe ? Colors.blue[700] : const Color(0x00ffffff),
          //       borderRadius: BorderRadius.circular(5),
          //       border: Border.all(color: user.isFollowedByMe ? Colors.transparent : Colors.grey.shade700,)
          //     ),
          //     child: Center(
          //       child: Text(user.isFollowedByMe ? 'Unfollow' : 'Follow', style: TextStyle(color: user.isFollowedByMe ? Colors.white : Colors.white))
          //     )
          //   ),
          // )
        ],
      ),
    ));
       }
       else{
         return Container();
       }
    }
    else{
      return Container();
    }
  }
  getRoomChat(String userid) async{
      roomId =  await getRoomChatByUser(userid,auth.FirebaseAuth.instance.currentUser!.uid);
  }
  createGroupChat()async{
    User myUser = await getUserById(auth.FirebaseAuth.instance.currentUser!.uid);
    if(controllerGroup.text!=""){
       GroupChat groupChat = GroupChat(groupName: controllerGroup.text,avatarGroup: "https://firebasestorage.googleapis.com/v0/b/project-cb943.appspot.com/o/image%2FlogoPreson%2Fgroupchat.jpg?alt=media&token=33a04890-7b06-4af6-9c65-e571fa7cbe5d",adminId: myUser.id,adminFullName: "${myUser.firstName} ${myUser.lastName}",createDate: DateTime.now());
      CreateNewData("GroupChat", groupChat);
      MemberGroupChat memberGroupChat = MemberGroupChat(groupId: groupChat.id,joinDate: DateTime.now(),userId: myUser.id);
      insertMemberGroup(memberGroupChat);
      ChatFinal chatFinal = ChatFinal(object: groupChat.toJson(),chatContentFinal: "Bạn vừa tạo nhóm ${controllerGroup.text}",chatFinalByUserId: myUser.id,chatFinalByUserFullName: "${myUser.firstName} ${myUser.lastName}",typeChat: "group",chatFinalDate:DateTime.now());
      CreateNewData("Chat", chatFinal); 
    }
    else{
        Fluttertoast.showToast(
          msg: "Bạn chưa nhập tên nhóm!",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          textColor: Colors.white,
          fontSize: 16.0
      );
    }
  }
}

