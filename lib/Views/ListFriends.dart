import 'package:do_an_tot_nghiep/DAO/DAOHepper.dart';
import 'package:do_an_tot_nghiep/Models/ChatFinal.dart';
import 'package:do_an_tot_nghiep/Models/ChatRoom.dart';
import 'package:do_an_tot_nghiep/Views/Chat.dart';
import 'package:do_an_tot_nghiep/Views/Design.dart';
import 'package:do_an_tot_nghiep/Views/Guest.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';

import '../Models/User.dart';

class ListFriend extends StatefulWidget {
  const ListFriend({ Key? key }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ListFriendState createState() => _ListFriendState();
}

class _ListFriendState extends State<ListFriend> {

  List<User> _users = [];


  List<User> _foundedUsers = [];
  String roomId = "";
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
      _foundedUsers = _users.where((user) => user.firstName!.toLowerCase().contains(search)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 80, 
        backgroundColor: Colors.white,
     
       automaticallyImplyLeading: false,
        title:Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [

            Container(margin: EdgeInsets.only(bottom: 5),child:Center(child: Text("Bạn bè(${_users.length})",style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 20)),)),
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
              hintText: "Search users"
            ),
          )),
          ]
        ),
      ),
      body: Container(
        color: Colors.white,
        // ignore: prefer_is_empty
        child: _foundedUsers.length > 0 ? ListView.builder(
          itemCount: _foundedUsers.length,
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

  userComponent({required User user}) {
    return InkWell(onTap: (){
      getRoomChat(user.id!);
      if(roomId!=""){
       //   Navigator.push(context, MaterialPageRoute(builder: (context)=> MyChat(userMapId: user.id!,chatRoomId: roomId)));
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
                        image:  NetworkImage('${user.image}'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.firstName!+" "+user.lastName!, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 5,),
                  Text(user.email!, style: TextStyle(color: Colors.grey[500])),
                ]
              )
            ]
          ),
          GestureDetector(
            onTap: () {
              showDialog(context: context, builder: (BuildContext context) {
                return AlertDialog(
                    title: const Text("Xóa bạn bè"),
                    content: Text("Bạn có muốn xóa kêt bạn với ${user.firstName} ${user.lastName} không?"),
                    actions: [
                      ElevatedButton(onPressed: (){ Navigator.pop(context);}, child: const Text("Thoát")),
                      ElevatedButton(onPressed: (){ deleteFriendShip(user);}, child: const Text("Xóa"))
                    ],
                );
              });
             
            },
            child: AnimatedContainer(
              height: 35,
              width:80,
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                color: mainColor,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: mainColor)
              ),
              child: Center(
                child: Text( 'Xóa bạn bè', style: TextStyle(color: Colors.white))
              )
            ),
          )
        ],
      ),
    ));
  }
  getRoomChat(String userid) async{
      roomId =  await getRoomChatByUser(userid,auth.FirebaseAuth.instance.currentUser!.uid);
     
  }
  
  deleteFriendShip(User user) async{
      await deleteFriend(user.id!, auth.FirebaseAuth.instance.currentUser!.uid);
      ChatRoom chatRoom = await getChatRoom(user.id!, auth.FirebaseAuth.instance.currentUser!.uid);
      ChatFinal chatFinal = await getChatFinal(chatRoom.id!);
      await deleteChatRoom(chatRoom.id!);
      await deleteChatFinal(chatFinal.id!);
      setState(() {
          _users.remove(user);
          _foundedUsers.remove(user);
      });
  }
}

