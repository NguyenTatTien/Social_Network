import 'dart:ffi';

import 'package:do_an_tot_nghiep/DAO/DAOHepper.dart';
import 'package:do_an_tot_nghiep/Models/ChatRoom.dart';
import 'package:do_an_tot_nghiep/Models/FriendShip.dart';
import 'package:do_an_tot_nghiep/Models/Notification.dart';
import 'package:do_an_tot_nghiep/NotificationService/PushNotification.dart';
import 'package:do_an_tot_nghiep/Views/message.dart';
import 'package:do_an_tot_nghiep/Models/User.dart';
import 'package:do_an_tot_nghiep/Views/Profile.dart';
import 'package:do_an_tot_nghiep/Views/addImagePost.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';


class Guest extends StatefulWidget {
  const Guest({ Key? key }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _GuestState createState() => _GuestState();
}

class _GuestState extends State<Guest> {

  var _users = <Map<String,Object>>[];
  var _foundedUsers = <Map<String,Object>>[];
  var myUser = User();
  var scrollController = ScrollController();
  var lastData;
  @override
  void initState() {
      getListUser();
    // TODO: implement initState
    super.initState();
    scrollController.addListener(scrollListener);
  }
  void scrollListener()async{
   if(scrollController.position.pixels == scrollController.position.maxScrollExtent){
    lastData = (_users[_users.length-1]["user"] as User).id;
    
    _users.addAll(await getlistOthers(auth.FirebaseAuth.instance.currentUser!.uid,lastData));
     _foundedUsers = _users;
      setState(() {
        _users;
        _foundedUsers;
      });
    }
  }
Future getListUser() async{
  myUser = await getUserById(auth.FirebaseAuth.instance.currentUser!.uid);
   _users = await getlistOthers(auth.FirebaseAuth.instance.currentUser!.uid,lastData);
    setState(() {
      _foundedUsers = _users;
    });
}
  onSearch(String search) {
    setState(() {
      _foundedUsers = _users.where((user) => (user["user"]as User).firstName!.toLowerCase().contains(search.toLowerCase())|| (user["user"]as User).lastName!.toLowerCase().contains(search.toLowerCase())).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: SizedBox(
          height: 38,
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
              hintText: "Search users"
            ),
          ),
        ),
      ),
      body: Container(
        color: Colors.white,
        // ignore: prefer_is_empty
        child: _foundedUsers.length > 0 ? ListView.builder(
          itemCount: _foundedUsers.length,
          controller: scrollController,
          itemBuilder: (context, index) {
            return Slidable(
              actionPane: const SlidableDrawerActionPane(),
              actionExtentRatio: 0.25,
              child: userComponent(user: _foundedUsers[index]),
              actions: <Widget>[
                IconSlideAction(
                  caption: 'Archive',
                  color: Colors.transparent,
                  icon: Icons.archive,
                  
                  onTap: () => print("archive"),
                ),
                IconSlideAction(
                  caption: 'Share',
                  color: Colors.transparent,
                  icon: Icons.share,
                  // ignore: avoid_print
                  onTap: () => print('Share'),
                ),
              ],
              secondaryActions: <Widget>[
                IconSlideAction(
                  caption: 'More',
                  color: Colors.transparent,
                  icon: Icons.more_horiz,
                  // ignore: avoid_print
                  onTap: () => print('More'),
                ),
                IconSlideAction(
                  caption: 'Delete',
                  color: Colors.transparent,
                  icon: Icons.delete,
                  // ignore: avoid_print
                  onTap: () => print('Delete'),
                ),
              ],
            );
          }) : const Center(child: Text("No users found", style: TextStyle(color: Colors.white),)),
      ),
    );
  }

  userComponent({required Map<String,Object> user}) {
    return InkWell(onTap: (){
          Navigator.push(context, MaterialPageRoute(builder: (context) => Profile((user["user"] as User).id)));
            },
      child: Container(
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
                        image:  NetworkImage('${(user["user"] as User).image}'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ignore: prefer_interpolation_to_compose_strings
                  Text((user["user"] as User).firstName!+" "+(user["user"] as User).lastName!, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 5,),
                  Container(
                  width: 140,
                  child: RichText(
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(
                  text: (user["user"] as User).email!,
                  style: GoogleFonts.lato(
                      color: Colors.grey[500],),
                    
                ),))
                  // Text(user.email!, style: TextStyle(color: Colors.grey[500])),
                ]
              )
            ]
          ),
          InkWell(
            onTap: () {

                user["status"]==0?sendRequestShip(user):user["status"]==2?agreeShip(user):user["status"]==1?deleteRequestShip(user):(){};
            },
            
            child:AnimatedContainer(
              
              height: 35,
              width:80,
              duration: const Duration(milliseconds: 300),
              // ignore: unrelated_type_equality_checks
              decoration: BoxDecoration(
                // color: user.isFollowedByMe ? Colors.blue[700] : const Color(0x00ffffff),
                color:  (user["status"] as int)==0?Colors.white:(user["status"] as int)==3?Colors.blue[700]:Colors.red[700],
                
                borderRadius: BorderRadius.circular(5),
                // border: Border.all(color: user.isFollowedByMe ? Colors.transparent : Colors.grey.shade700,)
                 border: Border.all(color: ((user["status"] as int)==0?Colors.grey.shade700:(user["status"] as int)==3?Colors.blue[700]:Colors.red[700])!)
              ),
              child: Center(
                
                // child: Text(user.isFollowedByMe ? 'Unfollow' : 'Follow', style: TextStyle(color: user.isFollowedByMe ? Colors.black : Colors.black))
                child: 
                 Text('${(user["status"] as int)==0?"Kết bạn":"${(user["status"] as int)==1?"Hủy lời mời":'${(user["status"] as int)==2?"Chấp nhận":"Nhắn tin"}'}"}', style: TextStyle(color: (user["status"] as int)==0?Colors.black:Colors.white)
              )
            ),
          ))
        ],
      ),
    ),);
  }
  
  sendRequestShip(Map<String,Object> user) async{
      await CreateNewData("FriendShip", FriendShip(id:"",requester: auth.FirebaseAuth.instance.currentUser!.uid,addressee: (user["user"] as User).id!,status: false));
      setState(() {
        user["status"] = 1;
      });
       NotificationObject notification = NotificationObject(id: "",content: "${myUser.firstName} ${myUser.lastName} đã gửi một yêu cầu kết bạn.",receiver:(user["user"] as User).id ,createDate: DateTime.now(),idObject: myUser.id,sender: myUser.id);
       CreateNewData("Notification", notification);
       
       PushNotification.sendPushNotification(User(),"${myUser.firstName} ${myUser.lastName} đã gửi một yêu cầu kết bạn.",(user["user"] as User).token!);
  }
  
  deleteRequestShip(Map<String,Object> user) async{
      await deleteFriend((user["user"] as User).id!, auth.FirebaseAuth.instance.currentUser!.uid);
      setState(() {
        user["status"] = 0;
      });
  }
  
  agreeShip(Map<String,Object> user) async{
    await makeFriend((user["user"] as User).id!, auth.FirebaseAuth.instance.currentUser!.uid);
    var chatRoom = ChatRoom(id: "",userFirst:(user["user"] as User).id!,userSecond:  auth.FirebaseAuth.instance.currentUser!.uid,createDate: DateTime.now());
    CreateNewData("ChatRoom", chatRoom);
    setState(() {
        user["status"] = 3;
      });
      NotificationObject notification = NotificationObject(id: "",content: "${myUser.firstName} ${myUser.lastName} đã đồng ý kết bạn với bạn.",receiver:(user["user"] as User).id!,createDate: DateTime.now(),idObject: myUser.id,sender: myUser.id);
       CreateNewData("Notification", notification);
       
      PushNotification.sendPushNotification(User(),"${myUser.firstName} ${myUser.lastName} đã đồng ý kết bạn với bạn.",(user["user"] as User).token!);
  }
} 

