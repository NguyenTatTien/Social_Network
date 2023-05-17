import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:do_an_tot_nghiep/DAO/DAOHepper.dart';
import 'package:do_an_tot_nghiep/Models/ChatFinal.dart';
import 'package:do_an_tot_nghiep/Models/ChatRoom.dart';
import 'package:do_an_tot_nghiep/Models/GroupChat.dart';
import 'package:do_an_tot_nghiep/Models/User.dart';
import 'package:do_an_tot_nghiep/NotificationService/PushNotification.dart';
import 'package:do_an_tot_nghiep/Services/Premissiond.dart';
import 'package:do_an_tot_nghiep/Views/CallUtils.dart';
import 'package:do_an_tot_nghiep/Views/Design.dart';
import 'package:do_an_tot_nghiep/Views/MemberGroup.dart';
import 'package:do_an_tot_nghiep/Views/Profile.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:do_an_tot_nghiep/Models/Message.dart' as mess;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
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
class ChatGroup extends StatefulWidget {
  final GroupChat groupChat;
  final String chatFinalId;
  ChatGroup({required this.groupChat,required this.chatFinalId});
  
  @override
  ChatGroupState createState() => ChatGroupState(this.groupChat,this.chatFinalId);
}

class ChatGroupState extends State<ChatGroup> with WidgetsBindingObserver{
  final GroupChat groupChat;


  var _message = TextEditingController();
  var controllerGroup = TextEditingController();
  var scrollController = ScrollController();
  var message = '';
  User myUser = User();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  File? imageFile;
  DateTime? timeMessage;
  bool rev = false;
  SampleItem? selectedMenu;
  String? imgGroupTemp;
  String? chatFinalId;
  ChatFinal chatFinal = ChatFinal();
  int countMember=0;
// The location of the SignalR Server.
// ignore: unnecessary_new
  ChatGroupState(this.groupChat,this.chatFinalId);
    @override
  void initState() {
    // TODO: implement initState
    getMyUser();
    WidgetsBinding.instance.addObserver(this);
   // setStatus(true);
   WidgetsBinding.instance.addPostFrameCallback((_){
                    scrollToBottom();
                      // Add Your Code here.

  });
    
  }
  void getMyUser() async{
     myUser = await getUserById(auth.FirebaseAuth.instance.currentUser!.uid);
    countMember = await countMemberGroup(groupChat.id!);
     setState(() {
       myUser;
       countMember;
     });
  }
  // void setStatus(bool status) async {
  //   myUser = await getUserById(auth.FirebaseAuth.instance.currentUser!.uid);
  //   ChatRoom chatRoom = await getObjectRoomChatByUser(_auth.currentUser!.uid, userMap.id!);
  //   if(chatRoom.userFirst==auth.FirebaseAuth.instance.currentUser!.uid){
     
  //     await _firestore.collection('ChatRoom').doc(groupChat.id).update({
  //           "StatusUserFirst": status,
  //         });
  //   }
  //   else{
    
  //       await _firestore.collection('ChatRoom').doc(groupChat.id).update({
  //           "StatusUserSecond": status,
  //         });
  //   }
    
  // }
  @override
  void dispose() {
    // TODO: implement dispose
   // setStatus(false);
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
        .collection('GroupChat')
        .doc(groupChat.id)
        .collection('Message')
        .doc(fileName)
        .set({
      "SendById":_auth.currentUser!.uid,
      "SendByFullName":"${myUser.firstName!} ${myUser.lastName!}",
      "SendByImage":myUser.image,
      "Message": "",
      "TypeChat":"user",
      "ObjectId":groupChat.id,
      "Type": "img",
      "CreateDate": DateTime.now(),
    });
    var ref =
        FirebaseStorage.instance.ref().child('image').child("chat").child(groupChat.id!).child("$fileName.jpg");

    var uploadTask = await ref.putFile(imageFile!).catchError((error) async {
      await _firestore
          .collection('GroupChat')
          .doc(groupChat.id)
          .collection('Message')
          .doc(fileName)
          .delete();

      status = 0;
    });

    if (status == 1) {
      String imageUrl = await uploadTask.ref.getDownloadURL();

      await _firestore
          .collection('GroupChat')
          .doc(groupChat.id)
          .collection('Message')
          .doc(fileName)
          .update({"Message": imageUrl});
      ChatFinal chatFinal = await getChatFinal(chatFinalId!);

      chatFinal.chatContentFinal = "Gửi một hình ảnh";
      
      chatFinal.chatFinalDate = DateTime.now();
     
      updateData("Chat", chatFinal);
      // setState(() {
      //    scrollController.jumpTo(scrollController.position.maxScrollExtent);
      // });
      
      // ChatRoom chatRoom = await getObjectRoomChatByUser(_auth.currentUser!.uid, userMap.id!);
      //  if((chatRoom.userFirst==userMap.id && chatRoom.statusUserFirst != true) || (chatRoom.userSecond==userMap.id && chatRoom.statusUserSecond != true) ){
      //     await PushNotification.sendPushNotification(myUser, "${myUser.firstName} ${myUser.lastName} đã gửi bạn một ảnh mới!",userMap.token!);
      //  }
    }
  }

  void onSendMessage() async {
    if (_message.text.isNotEmpty) {
      mess.Message messages = mess.Message(message: _message.text,type: "text",sendById: _auth.currentUser!.uid,sendByFullName: "${myUser.firstName!} ${myUser.lastName!}",sendByImage: myUser.image,objectId: groupChat.id,typeChat: "group",createDate: DateTime.now());
      
      String messageChat = _message.text;
      _message.clear();
      await _firestore
          .collection('GroupChat')
          .doc(groupChat.id)
          .collection('Message')
          .add(messages.toJson());
      //  setState(() {
      //    scrollController.jumpTo(scrollController.position.maxScrollExtent);
      //  });
    
      ChatFinal chatFinal = await getChatFinal(chatFinalId!);
     
      chatFinal.chatContentFinal = messageChat;
      
      chatFinal.chatFinalDate = DateTime.now();
     
      updateData("ChatFinal", chatFinal);
      
     
     //  GroupChat groupChat = await getGroupChatById(groupChatId);
      // if((groupChat.userFirst==userMap.id && chatRoom.statusUserFirst != true) || (chatRoom.userSecond==userMap.id && chatRoom.statusUserSecond != true) ){
      //   await PushNotification.sendPushNotification(myUser, messageChat,userMap.token!);
      // }
      
    
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        actions: [Padding(
            padding: EdgeInsets.only(right: 20),
            child: Row(children:[InkWell(onTap: (){}
           // await CallUtils.dial(from:myUser, to: groupChat.id,context: context)
            ,child:Icon(Icons.videocam_rounded)),
              PopupMenuButton<SampleItem>(
          initialValue: selectedMenu,
          // Callback that sets the selected popup menu item.
              onSelected: (SampleItem item) {
                setState(() {
                  selectedMenu = item;
                });
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<SampleItem>>[
                PopupMenuItem<SampleItem>(
                  value: SampleItem.itemOne,
                  child: InkWell(onTap: ()=>showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Chỉnh sửa nhóm'),
          content: StatefulBuilder(builder: (context, setState) => customGroup(context,setState),),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, 'Cancel'),
              child: const Text('Thoát'),
            ),
            TextButton(
              onPressed: ()async{
                var firebaseStorage =  FirebaseStorage.instance.ref();
                if(groupChat.avatarGroup!=imgGroupTemp && groupChat.avatarGroup != "https://firebasestorage.googleapis.com/v0/b/project-cb943.appspot.com/o/image%2FlogoPreson%2Fgroupchat.jpg?alt=media&token=33a04890-7b06-4af6-9c65-e571fa7cbe5d"){
                                       await firebaseStorage.child(groupChat.avatarGroup!).delete();
                                    }
                                   
                                    groupChat.avatarGroup = imgGroupTemp;
                                    groupChat.groupName = controllerGroup.text;
                                   updateData("GroupChat", groupChat);
                                   ChatFinal chatFinal = await getChatFinal(chatFinalId!);
                                   chatFinal.object = groupChat.toJson();
                                   updateData("Chat", chatFinal);
                                    setState(() {
                                      groupChat;
                                    });

                                    Navigator.of(context).pop();
                
              },
              child:  Text('Lưu'),
            ),
          ],
        )),child:Row(
                children: [
                  // ignore: avoid_unnecessary_containers
                  Container(child: const Icon(Icons.edit,size: 20,color: Colors.black,),),
                  Container(margin: const EdgeInsets.only(left: 5),child: const Text("Chỉnh sửa nhóm",style: TextStyle(fontSize: 15,color: Colors.black87),),)
                ],
              ),),
                ),
                PopupMenuItem<SampleItem>(
                  value: SampleItem.itemTwo,
                  child: InkWell(onTap: ()=>showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Xóa nhóm'),
          content: const Text('Bạn có muốn xóa nhóm này không'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, 'Cancel'),
              child: const Text('Thoát'),
            ),
            TextButton(
              onPressed: () {},
              child:  Text('Xóa nhóm'),
            ),
          ],
        )),child:Row(
                children: [
                  // ignore: avoid_unnecessary_containers
                  Container(child: const Icon(Icons.delete,size: 20,color: Colors.black,),),
                  Container(margin: const EdgeInsets.only(left: 5),child: const Text("Xóa nhóm",style: TextStyle(fontSize: 15,color: Colors.black87),),)
                ],
              ),),
                ),
                 PopupMenuItem<SampleItem>(
                  value: SampleItem.itemTwo,
                  child: InkWell(onTap: (){ Navigator.push(context, MaterialPageRoute(builder: (context)=> MemberGroup(groupChat: groupChat,)));},child:Row(
                children: [
                  // ignore: avoid_unnecessary_containers
                  Container(child: const Icon(Icons.group,size: 20,color: Colors.black,),),
                  Container(margin: const EdgeInsets.only(left: 5),child: const Text("Thành viên",style: TextStyle(fontSize: 15,color: Colors.black87),),)
                ],
              ),),
                ),
              
              ],
            ),
            ]),
          ),],
        backgroundColor: mainColor,
        title: StreamBuilder<DocumentSnapshot>(
          stream:
              _firestore.collection("GroupChat").doc(groupChat.id).snapshots(),
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
                  text: groupChat.groupName,
                  style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold)
                    
                ),)),
                    Text(
                      //(snapshot.data!['Status'] as bool) ==true?"Online":"Offline",
                      "Thành viên:${countMember}",
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
           //   height: size.height / 1.35,
           height: bodyHeight,
              width: size.width,
              child: StreamBuilder<QuerySnapshot>(
                
                stream: _firestore
                    .collection('GroupChat')
                    .doc(groupChat.id)
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
                       
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [  
                          
                          listTime[index]!=""?Center(child: Container(child: Text(DateTime.now().difference(map['CreateDate'].toDate() as DateTime).inDays==0?DateFormat("HH:mm").format(map['CreateDate'].toDate())+", Hôm nay": DateFormat("HH:mm, dd/MM/yyyy").format(map['CreateDate'].toDate())),)):Container(),
                          SizedBox(height: 5,),
                          Container(child:messages(size, map, context)),
                          

                          ]);
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
Widget customGroup(BuildContext context,StateSetter setState){
  controllerGroup.text = groupChat.groupName!;
  imgGroupTemp = groupChat.avatarGroup!;
  return Container(height: 200,child:Column(children: [
     Stack(
                  children: <Widget>[
                    Container(
                        height: 100,
                        width: 100,
                        margin: const EdgeInsets.only(
                            left: 0, right: 0, top: 15, bottom: 5),
                        padding: const EdgeInsets.all(2.0),
                        decoration: BoxDecoration(
                            border:
                                Border.all(color: mainColor, width: 2),
                            borderRadius: BorderRadius.circular(100)),
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(
                            '$imgGroupTemp'
                          ),
                        )),
                       
                        Positioned(
                              bottom: 0,
                              right: 0, //give the values according to your requirement
                              child: InkWell(onTap: () async{
                              FilePickerResult? result = await FilePicker.platform.pickFiles();
              // ignore: unnecessary_null_comparison
             
                                if(result!=null)
                                {
                                 
                                   final file = File(result.files.first.path!);
                                    
                                  // ignore: curly_braces_in_flow_control_structures, use_build_context_synchronously
                                   var firebaseStorage =  FirebaseStorage.instance.ref().child("image/group/${groupChat.id}/${DateTime.now().toString()}");
                                     await firebaseStorage.putFile(file);
                                    
                                   imgGroupTemp = await firebaseStorage.getDownloadURL();
                                  this.setState(() {
                                    imgGroupTemp;
                                  });
                                  
                                      
                                }
                            }, child:Material(
                                  color: mainColor,
                                  elevation: 10,
                                  borderRadius: BorderRadius.circular(100),
                                  child: const Padding(
                                    padding: EdgeInsets.all(3.0),
                                    child: Icon(
                                      Icons.camera,
                                      size: 45,
                                      color: Colors.white,
                                    ),
                                  )),)
                            )
                  ],
                ),
               Container(margin: EdgeInsets.only(top: 10),child:TextField(
              controller: controllerGroup,
              decoration: InputDecoration(
                  border: OutlineInputBorder(
              
                borderSide: const BorderSide(color: Color.fromARGB(255, 0, 64, 255), width: 1),),
                  fillColor: Color.fromARGB(255, 255, 255, 255),
                  filled: true,hintText: "Nhập tên nhóm"))),
              
  ],));
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
              margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10), width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image:  NetworkImage(map['SendByImage']),
                        fit: BoxFit.cover,
                      ),
                    ),),
Container(
     margin: EdgeInsets.symmetric(vertical: 5),
  child:Column(
                
                  crossAxisAlignment: CrossAxisAlignment.start,
                children:[  
                    Container(padding: EdgeInsets.all(0),child:Text("${map["SendByFullName"]}",style: TextStyle( fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: mainColor,),textAlign: TextAlign.left,)),
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
  
  
  child: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           mainAxisAlignment: MainAxisAlignment.start,
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
Container(padding: EdgeInsets.symmetric(vertical: 10),
              margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10), width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image:  NetworkImage(map['SendByImage']),
                        fit: BoxFit.cover,
                      ),
                    ),),
Container(
     
  child: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
    children:[
Container(padding: EdgeInsets.all(0),child:Text("${map["SendByFullName"]}",style: TextStyle( fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: mainColor,),textAlign: TextAlign.left,)),
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