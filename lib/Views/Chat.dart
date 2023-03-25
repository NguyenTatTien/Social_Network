import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:do_an_tot_nghiep/DAO/DAOHepper.dart';
import 'package:do_an_tot_nghiep/Models/ChatRoom.dart';
import 'package:do_an_tot_nghiep/Models/User.dart';
import 'package:do_an_tot_nghiep/NotificationService/PushNotification.dart';
import 'package:do_an_tot_nghiep/Views/Design.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:signalr_netcore/signalr_client.dart';
import 'package:uuid/uuid.dart';



import 'receiver_row_view.dart';
import '../Models/ChatMessagesModel.dart';
import 'global_members.dart';
import 'sender_row_view.dart';
import 'package:logging/logging.dart';
var url =
    'https://i.pinimg.com/736x/fd/6e/04/fd6e04548095d7f767917f344a904ff1.jpg';
var urlTwo =
    'https://sguru.org/wp-content/uploads/2017/03/cute-n-stylish-boys-fb-dp-2016.jpg';
class MyChat extends StatefulWidget {
  final User userMap;
  final String chatRoomId;
  MyChat({required this.chatRoomId, required this.userMap});
  
  @override
  MyChatState createState() => MyChatState(this.chatRoomId,this.userMap);
}

class MyChatState extends State<MyChat> with WidgetsBindingObserver{
  final User userMap;
  final String chatRoomId;
  var _message = TextEditingController();
  var scrollController = ScrollController();
  var message = '';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  File? imageFile;
  

// The location of the SignalR Server.
// ignore: unnecessary_new
  MyChatState(this.chatRoomId,this.userMap);
    @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    setStatus(true);
   
    
  }
  void setStatus(bool status) async {
    ChatRoom chatRoom = await getObjectRoomChatByUser(_auth.currentUser!.uid, userMap.id!);
    if(chatRoom.userFirst==auth.FirebaseAuth.instance.currentUser!.uid){
      print("a");
      await _firestore.collection('ChatRoom').doc(chatRoomId).update({
            "StatusUserFirst": status,
          });
    }
    else{
      print("b");
        await _firestore.collection('ChatRoom').doc(chatRoomId).update({
            "StatusUserSecond": status,
          });
    }
    
  }
  @override
  void dispose() {
    // TODO: implement dispose
    setStatus(false);
    super.dispose();
  }
    // ignore: override_on_non_overriding_member
  
  void scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 1000)).then((_) {
      if (!scrollController.hasClients) return;
      
        scrollController.jumpTo(scrollController.position.maxScrollExtent);
    });
  }
   Future getImage() async {
      ImagePicker _picker = ImagePicker();

      await _picker.pickImage(source: ImageSource.gallery).then((xFile) {
        if (xFile != null) {
          imageFile = File(xFile.path);
          uploadImage();
        }
      });
  }
   Future uploadImage() async {
    String fileName = Uuid().v1();
    int status = 1;
    await _firestore
        .collection('ChatRoom')
        .doc(chatRoomId)
        .collection('Message')
        .doc(fileName)
        .set({
      "SendById":_auth.currentUser!.uid,
      "Message": "",
      "Type": "img",
      "CreateDate": DateTime.now(),
    });
    var ref =
        FirebaseStorage.instance.ref().child('image').child("chat").child(chatRoomId).child("$fileName.jpg");

    var uploadTask = await ref.putFile(imageFile!).catchError((error) async {
      await _firestore
          .collection('ChatRoom')
          .doc(chatRoomId)
          .collection('Message')
          .doc(fileName)
          .delete();

      status = 0;
    });

    if (status == 1) {
      String imageUrl = await uploadTask.ref.getDownloadURL();

      await _firestore
          .collection('ChatRoom')
          .doc(chatRoomId)
          .collection('Message')
          .doc(fileName)
          .update({"Message": imageUrl});
      setState(() {
         scrollController.jumpTo(scrollController.position.maxScrollExtent);
      });
      User user = await getUserById(_auth.currentUser!.uid);
      ChatRoom chatRoom = await getObjectRoomChatByUser(_auth.currentUser!.uid, userMap.id!);
       if((chatRoom.userFirst==userMap.id && chatRoom.statusUserFirst != true) || (chatRoom.userSecond==userMap.id && chatRoom.statusUserSecond != true) ){
          await PushNotification.sendPushNotification(user, "${user.firstName} ${user.lastName} đã gửi bạn một ảnh mới!",userMap.token!);
       }
    }
  }

  void onSendMessage() async {
    if (_message.text.isNotEmpty) {
      Map<String, dynamic> messages = {
        "SendById": _auth.currentUser!.uid,
        "Message": _message.text,
        "Type": "text",
        "CreateDate": DateTime.now(),
      };
      String messageChat = _message.text;
      _message.clear();
      await _firestore
          .collection('ChatRoom')
          .doc(chatRoomId)
          .collection('Message')
          .add(messages);
       setState(() {
         scrollController.jumpTo(scrollController.position.maxScrollExtent);
       });
       User user = await getUserById(_auth.currentUser!.uid);
       ChatRoom chatRoom = await getObjectRoomChatByUser(_auth.currentUser!.uid, userMap.id!);
      if((chatRoom.userFirst==userMap.id && chatRoom.statusUserFirst != true) || (chatRoom.userSecond==userMap.id && chatRoom.statusUserSecond != true) ){
        await PushNotification.sendPushNotification(user, messageChat,userMap.token!);
      }
      
    
    } else {
      print("Enter Some Text");
    }
  }
  
  @override
  Widget build(BuildContext context) {
    // return Scaffold(
    //   backgroundColor: const Color(0xffF5F5F3),
    //   appBar:  AppBar(
    //     elevation: 12,
    //     titleSpacing: 10,
    //     backgroundColor:  mainColor,
    //     leading: const Padding(
    //       padding: EdgeInsets.all(8.0),
    //       child: Icon(
    //         Icons.arrow_back_ios_sharp,
    //         color: Colors.white,
    //       ),
    //     ),
    //     leadingWidth: 20,
    //     title: ListTile(
    //       leading: CircleAvatar(
    //         backgroundImage: NetworkImage(url),
    //       ),
    //       title: const Text(
    //         'Usama XD',
    //         style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    //       ),
    //       subtitle: const Text(
    //         'online',
    //         style: TextStyle(color: Colors.white),
    //       ),
    //     ),
    //     actions: const [
    //       Padding(
    //         padding: EdgeInsets.only(right: 20),
    //         child: Icon(Icons.videocam_rounded),
    //       ),
    //       Padding(
    //         padding: EdgeInsets.only(right: 20),
    //         child: Icon(Icons.call),
    //       ),
    //     ],
    //   ),
    //   body: Column(
    //     children: [
    //       Flexible(
    //           flex: 1,
    //           fit: FlexFit.tight,
    //           child: ListView.builder(
    //             controller: scrollController,
    //             physics: const BouncingScrollPhysics(),
    //             itemCount: chatModelList.length,
    //             itemBuilder: (context, index) => chatModelList.elementAt(index).isMee
    //                 ? SenderRowView(index: index,)
    //                 : ReceiverRowView(index: index),
    //           )),
    //       Container(
    //         alignment: Alignment.center,
    //         color: Colors.white,
    //         child: Row(
    //           crossAxisAlignment: CrossAxisAlignment.end,
    //           children: [
    //             const Padding(
    //               padding: EdgeInsets.only(bottom: 12.0,left: 8),
    //               child: Icon(Icons.emoji_emotions_outlined, color: mainColor,),
    //             ),
    //             Expanded(
    //               child: TextFormField(
    //               maxLines: 6,
    //               minLines: 1,
    //               keyboardType: TextInputType.multiline,
    //               controller: _message,
    //               onFieldSubmitted: (value) {
    //                 _message.text = value;
    //               },
    //               decoration: const InputDecoration(
    //                 contentPadding: EdgeInsets.only(left: 8),
    //                   border: InputBorder.none,
    //                   focusColor: Colors.white,
    //                   hintText: 'Type a message',
    //               ),
    //             ),
    //             ),
    //             Padding(
    //               padding: const EdgeInsets.only(bottom: 12, right: 10),
    //               child: Transform.rotate(
    //                 angle: 45,
    //                 child: const Icon(
    //                   Icons.attachment_outlined,
    //                   color: mainColor,
    //                 ),
    //               ),
    //             ),
    //             GestureDetector(
    //               onTap: () {
                     
    //               },
    //               onLongPress: () {
                    
                    
    //               },
    //               child: const Padding(
    //                 padding: EdgeInsets.only(bottom: 8, right: 8),
    //                 child: CircleAvatar(
    //                   backgroundColor: mainColor,
    //                   child: Icon(
    //                     Icons.send,
    //                     color: Colors.white,
    //                   ),
    //                 ),
    //               ),
    //             ),
    //           ],
    //         ),
    //       )
    //     ],
    //   ),
    // );
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mainColor,
        title: StreamBuilder<DocumentSnapshot>(
          stream:
              _firestore.collection("User").doc(userMap.id).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.data != null) {
              return Container(
                child: Column(
                  children: [
                    // ignore: prefer_interpolation_to_compose_strings
                    Text(userMap.firstName! + " " +userMap.lastName!),
                    Text(
                      (snapshot.data!['Status'] as bool) ==true?"Online":"Offline",
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              );
            } else {
              return Container();
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        
        child: Column(
          children: [
            Container(
              height: size.height / 1.35,
              width: size.width,
              child: StreamBuilder<QuerySnapshot>(
                
                stream: _firestore
                    .collection('ChatRoom')
                    .doc(chatRoomId)
                    .collection('Message')
                    .orderBy("CreateDate", descending: false)
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.data != null) {
                     WidgetsBinding.instance.addPostFrameCallback((_) {
                        scrollToBottom();
                      });
                    return ListView.builder(
                      controller: scrollController,
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        Map<String, dynamic> map = snapshot.data!.docs[index]
                            .data() as Map<String, dynamic>;
                        
                        return messages(size, map, context);
                      },
                    );
                  } else {
                    return Container();
                  }
                },
              ),
            ),
            Container(
              height: size.height / 10,
              width: size.width,
              alignment: Alignment.center,
              child: Container(
                height: size.height / 12,
                width: size.width / 1.1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: size.height / 17,
                      width: size.width / 1.3,
                      child: TextField(
                        controller: _message,
                        decoration: InputDecoration(
                            suffixIcon: IconButton(
                              onPressed: () => getImage(),
                              icon: Icon(Icons.photo),color: mainColor,
                            ),
                            hintText: "Send Message",
                            
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: mainColor,width: 1)
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: mainColor,width: 1)
                            ),
                      ),)
                    ),
                    IconButton(
                        icon: Icon(Icons.send,color: mainColor,), onPressed: onSendMessage),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
Widget messages(Size size, Map<String, dynamic> map, BuildContext context) {
    return map['Type'] == "text"
        ? Container(
            width: size.width,
            alignment: map['SendById'] == _auth.currentUser!.uid
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
              margin: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: map['SendById'] == _auth.currentUser!.uid? mainColor:Color.fromARGB(115, 80, 80, 80),
              ),
              child: Text(
                map['Message'],
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          )
        : Container(
            height: size.height / 2.5,
            width: size.width,
            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
            alignment: map['SendById'] == _auth.currentUser!.uid
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: InkWell(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ShowImage(
                    imageUrl: map['Message'],
                  ),
                ),
              ),
              child: Container(
                height: size.height / 2.5,
                width: size.width / 2,
                decoration: BoxDecoration(border: Border.all()),
                alignment: map['Msessage'] != "" ? null : Alignment.center,
                child: map['Message'] != ""
                    ? Image.network(
                        map['Message'],
                        fit: BoxFit.cover,
                      )
                    : CircularProgressIndicator(),
              ),
            ),
          );
  }
}

class ShowImage extends StatelessWidget {
  final String imageUrl;

  const ShowImage({required this.imageUrl, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        height: size.height,
        width: size.width,
        color: Colors.black,
        child: Image.network(imageUrl),
      ),
    );
  }
}