import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:do_an_tot_nghiep/DAO/DAOHepper.dart';
import 'package:do_an_tot_nghiep/Models/Call.dart';
import 'package:do_an_tot_nghiep/Models/ChatFinal.dart';
import 'package:do_an_tot_nghiep/Models/ChatRoom.dart';
import 'package:do_an_tot_nghiep/Models/User.dart';
import 'package:do_an_tot_nghiep/NotificationService/PushNotification.dart';
import 'package:do_an_tot_nghiep/Services/Premissiond.dart';
import 'package:do_an_tot_nghiep/Views/CallUtils.dart';
import 'package:do_an_tot_nghiep/Views/Design.dart';
import 'package:do_an_tot_nghiep/Views/callup_screen.dart';
import 'package:do_an_tot_nghiep/Views/message.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:do_an_tot_nghiep/Models/Message.dart' as mess;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
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
  final String userMapId;
  final String chatfinalId;
  final String chatRoomId;
  MyChat({required this.chatRoomId, required this.userMapId,required this.chatfinalId});
  
  @override
  MyChatState createState() => MyChatState(this.chatRoomId,this.userMapId,this.chatfinalId);
}

class MyChatState extends State<MyChat> with WidgetsBindingObserver{
  final String userMapId;


  final String chatFinalId;
  User userMap = User();
  final String chatRoomId;

  var _message = TextEditingController();
  var scrollController = ScrollController();
  var message = '';
  User myUser = User();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  File? imageFile;
  DateTime? timeMessage;
  bool rev = false;
  
// The location of the SignalR Server.
// ignore: unnecessary_new
  MyChatState(this.chatRoomId,this.userMapId,this.chatFinalId);
    @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserMap();
    WidgetsBinding.instance.addObserver(this);
    setStatus(true);
   WidgetsBinding.instance.addPostFrameCallback((_){
                    scrollToBottom();
                    // Add Your Code here.

  });
    
  }
  getUserMap()async{
    userMap = await getUserById(userMapId);
    setState(() {
      userMap;
    });
  
     
  }
  void setStatus(bool status) async {
    myUser = await getUserById(auth.FirebaseAuth.instance.currentUser!.uid);
    ChatRoom chatRoom = await getObjectRoomChatByUser(_auth.currentUser!.uid, userMap.id!);
    if(chatRoom.userFirstById==auth.FirebaseAuth.instance.currentUser!.uid){
     
      await _firestore.collection('ChatRoom').doc(chatRoomId).update({
            "StatusUserFirst": status,
          });
    }
    else{
    
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
  
  void scrollToBottom(){
    Future.delayed(Duration.zero).then((_) {
      if (!scrollController.hasClients) return;
      
       
        //scrollController.jumpTo(scrollController.position.maxScrollExtent);
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
        .collection('UserChat')
        .doc(chatRoomId)
        .collection('Message')
        .doc(fileName)
        .set({
      "SendById":_auth.currentUser!.uid,
      "SendByFullName":"${myUser.firstName!} ${myUser.lastName!}",
      "SendByImage":myUser.image,
      "Message": "",
      "TypeChat":"user",
      "ObjectId":chatRoomId,
      "Type": "img",
      "CreateDate": DateTime.now(),
    });
    var ref =
        FirebaseStorage.instance.ref().child('image').child("chat").child(chatRoomId).child("$fileName.jpg");

    var uploadTask = await ref.putFile(imageFile!).catchError((error) async {
      await _firestore
          .collection('UserChat')
          .doc(chatRoomId)
          .collection('Message')
          .doc(fileName)
          .delete();

      status = 0;
    });

    if (status == 1) {
      String imageUrl = await uploadTask.ref.getDownloadURL();

      await _firestore
          .collection('UserChat')
          .doc(chatRoomId)
          .collection('Message')
          .doc(fileName)
          .update({"Message": imageUrl});
      // setState(() {
      //    scrollController.jumpTo(scrollController.position.maxScrollExtent);
      // });
      ChatFinal chatFinal = await getChatFinal(chatFinalId);

      chatFinal.chatContentFinal = "Gửi một hình ảnh";
      
      chatFinal.chatFinalDate = DateTime.now();
     
      updateData("Chat", chatFinal);
      ChatRoom chatRoom = await getObjectRoomChatByUser(_auth.currentUser!.uid, userMap.id!);
       if((chatRoom.userFirstById==userMap.id && chatRoom.statusUserFirst != true) || (chatRoom.userSecondById==userMap.id && chatRoom.statusUserSecond != true) ){
          await PushNotification.sendPushNotification(myUser, "${myUser.firstName} ${myUser.lastName} đã gửi bạn một ảnh mới!",userMap.token!);
       }
    }
  }

  void onSendMessage() async {
    if (_message.text.isNotEmpty) {
      mess.Message messages = mess.Message(message: _message.text,type: "text",sendById: _auth.currentUser!.uid,sendByFullName: "${myUser.firstName!} ${myUser.lastName!}",sendByImage: myUser.image,objectId: chatRoomId,typeChat: "user",createDate: DateTime.now());
      
      String messageChat = _message.text;
      _message.clear();
      await _firestore
          .collection('UserChat')
          .doc(chatRoomId)
          .collection('Message')
          .add(messages.toJson());
      //  setState(() {
      //    scrollController.jumpTo(scrollController.position.maxScrollExtent);
      //  });
    
      ChatFinal chatFinal = await getChatFinal(chatFinalId);
      print(chatFinal.object);
      chatFinal.chatContentFinal = messageChat;
      
      chatFinal.chatFinalDate = DateTime.now();
     
      updateData("Chat", chatFinal);
      
     
       ChatRoom chatRoom = await getObjectRoomChatByUser(_auth.currentUser!.uid, userMap.id!);
      if((chatRoom.userFirstById==userMap.id && chatRoom.statusUserFirst != true) || (chatRoom.userSecondById==userMap.id && chatRoom.statusUserSecond != true) ){
        await PushNotification.sendPushNotification(myUser, messageChat,userMap.token!);
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
    final appBar = AppBar();
    final bodyHeight = MediaQuery.of(context).size.height - appBar.preferredSize.height - MediaQuery.of(context).padding.top - 70;
                 
    return Scaffold(
      appBar: AppBar(
        actions: [Padding(
            padding: EdgeInsets.only(right: 20),
            child: InkWell(onTap: () async => 
             await CallUtils.dial(from:myUser, to: userMap,context: context)
            //   Navigator.push(
            // context, MaterialPageRoute(builder: (context) => CallUpScreen(new Call())))
            ,child:Icon(Icons.videocam_rounded)),
          ),],
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
                  Container(
                  width: 120,
                 
                  child: RichText(
                    textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  strutStyle: const StrutStyle(fontSize: 22.0),
                  text: TextSpan(
                  text: "${userMap.firstName!} ${userMap.lastName!}",
                  style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold)
                    
                ),)),
                  
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
          mainAxisSize: MainAxisSize.max,
        
          children: [
            Container(
             
              height: bodyHeight,
              width: size.width,
              child: StreamBuilder<QuerySnapshot>(
                
                stream: _firestore
                    .collection('UserChat')
                    .doc(chatRoomId)
                    .collection('Message')
                    .orderBy("CreateDate", descending: true).limit(30)
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.data != null){
                    var listTime = [];
                    for(int i = 0 ;i<snapshot.data!.docs.length;i++){
                      if(i<snapshot.data!.docs.length-1){
                      
                         if(((snapshot.data!.docs[(i)].data() as Map<String, dynamic>)["CreateDate"].toDate() as DateTime).difference((snapshot.data!.docs[i+1].data() as Map<String, dynamic>)["CreateDate"].toDate() as DateTime).inMinutes>30){
                          listTime.add((snapshot.data!.docs[i].data() as Map<String, dynamic>)["CreateDate"].toDate().toString());
                        
                         }
                         else{
                          listTime.add("");
                          
                         }
                      }
                      else{
                        listTime.add("");
                        
                      }
                    }
                                        
                    
                    return ListView.builder(
                      controller: scrollController,
                      reverse: true,
                      shrinkWrap: true,
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        
                        Map<String, dynamic> map = snapshot.data!.docs[index]
                            .data() as Map<String, dynamic>;
                       
                        return Column(children: [  
                          listTime[index]!=""?Center(child: Text(DateTime.now().difference(map['CreateDate'].toDate() as DateTime).inDays==0?DateFormat("HH:mm").format(map['CreateDate'].toDate())+", Hôm nay": DateFormat("HH:mm, dd/MM/yyyy").format(map['CreateDate'].toDate())),):Container(),
                          messages(size, map, context)]);
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
                            hintText: "Nhập tin nhắn",
                            
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
    timeMessage=map["CreateDate"].toDate();
    return
    map['Type'] == "text"
        ?Container(
            width: size.width,
            alignment: map['SendById'] == _auth.currentUser!.uid
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child:
            map['SendById'] == _auth.currentUser!.uid?
            Wrap(
    direction: Axis.horizontal,
    crossAxisAlignment: WrapCrossAlignment.start,
    spacing:0,
    runSpacing: 5,
    children: [

Container(
     margin: EdgeInsets.symmetric(vertical: 5,horizontal: 10),
  child:Column(
                
                  crossAxisAlignment: CrossAxisAlignment.start,
                children:[  
                   
                  Container(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
              margin: EdgeInsets.symmetric(vertical: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: map['SendById'] == _auth.currentUser!.uid? mainColor:Colors.white,
              ),
              child:
                
                  Text(
                map['Message'],
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
          
                
            ),
                Container(padding: EdgeInsets.all(0),child:Text("20:22",style: TextStyle( fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.black38,),textAlign: TextAlign.left,)),
            ])),
          
          ]):  Wrap(
    direction: Axis.horizontal,
    crossAxisAlignment: WrapCrossAlignment.start,
    spacing:0,
    runSpacing: 5,
    children: [

Container(
      margin: EdgeInsets.symmetric(vertical: 5,horizontal: 10),
  child:Column(
                
                  crossAxisAlignment: CrossAxisAlignment.start,
                children:[  
                    
                  Container(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
              margin: EdgeInsets.symmetric(vertical: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
             
                color: map['SendById'] == _auth.currentUser!.uid? mainColor:Color.fromARGB(255, 225, 237, 255),
              ),
              child:
                
                  Text(
                map['Message'],
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color.fromARGB(161, 0, 0, 0),
                ),
              ),
          
                
            ),
                Container(padding: EdgeInsets.all(0),child:Text("20:22",style: TextStyle( fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.black38,),textAlign: TextAlign.left,)),
            ])),
          ]))
        : Container(
           
              
            alignment: map['SendById'] == _auth.currentUser!.uid
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child:
             map['SendById'] == _auth.currentUser!.uid?
            Wrap(
    direction: Axis.horizontal,
    crossAxisAlignment: WrapCrossAlignment.start,
    spacing:0,
    runSpacing: 5,
    children: [

 Container(
   margin: EdgeInsets.symmetric(vertical: 5,horizontal: 10),
  
  child: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
          
    children:[ InkWell(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ShowImage(
                    imageUrl: map['Message'],
                  ),
                ),
              ),
              child: Container(
               
              margin: EdgeInsets.symmetric(vertical: 5),
            
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
            Container(  margin: EdgeInsets.only(top: 5),child:Text("20:22",style: TextStyle( fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.black38,),textAlign: TextAlign.left,)),
          ]))]):  Wrap(
    direction: Axis.horizontal,
    crossAxisAlignment: WrapCrossAlignment.start,
    spacing:0,
    runSpacing: 5,
    children: [

Container(
      margin: EdgeInsets.symmetric(vertical: 5,horizontal: 10),
  child: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
    children:[

 InkWell(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ShowImage(
                    imageUrl: map['Message'],
                  ),
                ),
              ),
              child: Container(
              margin: EdgeInsets.symmetric(vertical: 5),

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
                Container(margin: EdgeInsets.symmetric(vertical: 5),child:Text("20:22",style: TextStyle( fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.black38,),textAlign: TextAlign.left,)),
            ])),
          ]));
    
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