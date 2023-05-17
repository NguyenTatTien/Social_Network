import 'package:comment_box/comment/comment.dart';
import 'package:do_an_tot_nghiep/DAO/DAOHepper.dart';
import 'package:do_an_tot_nghiep/Models/ChatFinal.dart';
import 'package:do_an_tot_nghiep/Models/ChatRoom.dart';
import 'package:do_an_tot_nghiep/Models/FriendShip.dart';
import 'package:do_an_tot_nghiep/Models/GroupChat.dart';
import 'package:do_an_tot_nghiep/Models/MemberGroupChat.dart';
import 'package:do_an_tot_nghiep/Models/Notification.dart';
import 'package:do_an_tot_nghiep/NotificationService/PushNotification.dart';
import 'package:do_an_tot_nghiep/Views/Design.dart';
import 'package:do_an_tot_nghiep/Views/message.dart';
import 'package:do_an_tot_nghiep/Models/User.dart';
import 'package:do_an_tot_nghiep/Views/Profile.dart';
import 'package:do_an_tot_nghiep/Views/addImagePost.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';


class MemberGroup extends StatefulWidget {
  GroupChat? groupChat;
  MemberGroup({this.groupChat});

  @override
  // ignore: library_private_types_in_public_api
  _MemberGroupState createState() => _MemberGroupState(this.groupChat);
}

class _MemberGroupState extends State<MemberGroup> {

  var _users = <User>[];
  var _foundedUsers = <User>[];
  var myUser = User();
  var scrollController = ScrollController();
  GroupChat? groupChat;


  var lastData;
  _MemberGroupState(this.groupChat);
  @override
  void initState() {
      getListUser();
    // TODO: implement initState
    super.initState();
    scrollController.addListener(scrollListener);
  }
  void scrollListener()async{
   if(scrollController.position.pixels == scrollController.position.maxScrollExtent){
    lastData = _users[_users.length-1].id;
    
  //  _users.addAll(await getlistOthers(auth.FirebaseAuth.instance.currentUser!.uid,lastData));
     _foundedUsers = _users;
      setState(() {
        _users;
        _foundedUsers;
      });
    }
  }
Future getListUser() async{

  myUser = await getUserById(auth.FirebaseAuth.instance.currentUser!.uid);
  List<String> listMemberId = await getListMemberInGroup(groupChat!.id!);
  for(var item in listMemberId){
    _users.add(await getUserById(item));
  }
 //  _users = await getlistOthers(auth.FirebaseAuth.instance.currentUser!.uid,lastData);
    setState(() {
      _users;
      _foundedUsers = _users;
    });
}
  onSearch(String search) {
    setState(() {
      _foundedUsers = _users.where((user) => user.firstName!.toLowerCase().contains(search.toLowerCase())|| user.lastName!.toLowerCase().contains(search.toLowerCase())).toList();
  
  });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        toolbarHeight: 50,
        title:  Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Container(margin: EdgeInsets.only(top: 10),child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children:  [
              Flexible(child:Align(alignment: Alignment.center,child: Text("Thành viên",style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 20)),),flex: 3,),
              Flexible(flex: 1,child:Align(alignment: Alignment.center,child: InkWell(onTap: ()async{  List<User> listUser = await lsFiendNotJoinGroupChat(groupChat!.id!, auth.FirebaseAuth.instance.currentUser!.uid, _users); showDialog(context: context, builder: (BuildContext context) {
                return AlertDialog(
                    insetPadding: EdgeInsets.zero,
                    contentPadding: EdgeInsets.zero,
                    content:  Container(  width:MediaQuery.of(context).size.width - 20,height:MediaQuery.of(context).size.height - 300  ,child:viewMyFriend(listUser)),
                    actions: [
                      ElevatedButton(onPressed: (){ Navigator.pop(context);}, child: const Text("Thoát")),
                      
                    ],
                );
              });},child:const Icon(Icons.group_add_outlined,size: 22,color: mainColor),)),)
        ],)),
          // Container(margin: EdgeInsets.only(top: 10),child:SizedBox(
          // height: 40,
          // width: MediaQuery.of(context).size.width ,
          // child: TextField(
          //   onChanged: (value) => onSearch(value),
          //   decoration: InputDecoration(
          //     filled: true,
          //     fillColor: const Color(0xfff3f3f4),
          //     contentPadding: const EdgeInsets.all(0),
          //     prefixIcon: Icon(Icons.search, color: Colors.grey.shade500,),
          //     border: OutlineInputBorder(
          //       borderRadius: BorderRadius.circular(50),
          //       borderSide: BorderSide.none
          //     ),
          //     hintStyle: TextStyle(
          //       fontSize: 14,
          //       color: Colors.grey.shade500
          //     ),
          //     hintText: "Search users"
          //   ),
          // ))),
          ]
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
              child: userComponent(user: _foundedUsers[index],type: 1),
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
            );
          }) : const Center(child: Text("Không có dữ liệu", style: TextStyle(color: Colors.white),)),
      ),
    );
  }
  
  viewMyFriend(List<User> listUser){
   
    return  Scaffold(
    
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        automaticallyImplyLeading:false ,
        title: SizedBox(
          height: 38,
          width: MediaQuery.of(context).size.width-50,
          child:Align(alignment: Alignment.centerLeft,child: TextField(
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
          ),
        ),
      )),
      body: Container(
        color: Colors.white,
      
        // ignore: prefer_is_empty
        child: listUser.length > 0 ? ListView.builder(
          itemCount: listUser.length,
          controller: scrollController,
          itemBuilder: (context, index) {
            return Slidable(
              actionPane: const SlidableDrawerActionPane(),
              actionExtentRatio: 0.25,
              child: userComponent(user: listUser[index],type: 2),
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
            );
          }) : const Center(child: Text("No users found", style: TextStyle(color: Colors.white),)),
      ),
    );
  }
  
  userComponent({required User user,required int type}) {
    return InkWell(onTap: (){
          // Navigator.push(context, MaterialPageRoute(builder: (context) => Profile((user.id))));
        mainBottomSheet(context);
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
                        image:  NetworkImage('${user.image}'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ignore: prefer_interpolation_to_compose_strings
                  Row(children:
                   [
                    Text(user.firstName!+" "+user.lastName!, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w500)),
                    Text((groupChat!.adminId==user.id!?"(Trưởng nhóm)":""))
                    ]),
                  const SizedBox(height: 5,),
                  Container(
                  width: 140,
                  child: RichText(
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(
                  text: user.email!,
                  style: GoogleFonts.lato(
                      color: Colors.grey[500],),
                    
                ),))
                  // Text(user.email!, style: TextStyle(color: Colors.grey[500])),
                ]
              )
            ]
          ),
          type==1?
          Container(): InkWell(
            onTap: () {
              MemberGroupChat memberGroupChat = MemberGroupChat(groupId: groupChat!.id!,userId: user.id,joinDate: DateTime.now());
              insertMemberGroup(memberGroupChat);
              setState(() {
                _users.add(user);
                _foundedUsers = _users;
              });
              Navigator.of(context).pop();
                //user["status"]==0?sendRequestShip(user):user["status"]==2?agreeShip(user):user["status"]==1?deleteRequestShip(user):(){};
            },
            child:InkWell(child: Container(
                  margin: EdgeInsets.all(10),
                  padding: EdgeInsets.all(0),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(width: 2, color: mainColor)),
                  child: Icon(
                    Icons.add,
                    color: mainColor,
                  ),
                )),
          )
        ],
      ),
    ),);
  }
   mainBottomSheet(BuildContext context) {
    showModalBottomSheet(
      isScrollControlled: true,
        context: context,
         constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width -10,         
        ),
         shape: RoundedRectangleBorder(
     borderRadius: new BorderRadius.only(
                  topLeft: const Radius.circular(10.0),
                  topRight: const Radius.circular(10.0),
                  bottomLeft: const Radius.circular(0.0),
                  bottomRight: const Radius.circular(0.0))),
      
        builder: (BuildContext context) {
          return Container(
     
      child: new Container(
          height: 200.0,
         
          child:  Column(

       
                children: [
          
                  SizedBox(height: 30,child: Container(margin: EdgeInsets.only(top: 5),padding: EdgeInsets.all(0),width:MediaQuery.of(context).size.width-10,height: 30 ,child: ElevatedButton(onPressed: (){}, child: Text("Người dùng",style: TextStyle(color: Colors.black45,fontSize: 11),),style: ElevatedButton.styleFrom(backgroundColor: Colors.white10,side: BorderSide.none,elevation: 0,shadowColor: Colors.transparent),))),
                   SizedBox(child:Container(margin: EdgeInsets.all(0),padding: EdgeInsets.all(0),child:Divider(
                  color: Color.fromARGB(58, 170, 170, 170),
                  thickness: 1,
                  ))),
                     SizedBox(height: 40,child: Container(padding: EdgeInsets.all(0),width:MediaQuery.of(context).size.width-10,height: 40 ,child: ElevatedButton(onPressed: (){}, child:Stack(
            children: <Widget>[
                Align(
                    alignment: Alignment.centerLeft,
                    child: Icon(Icons.person_add_rounded)
                ),
                Align(
                    alignment: Alignment.center,
                    child: Text("Xóa thành viên",style: TextStyle(color: mainColor,fontSize: 15),)
                )
            ],
        ), style: ElevatedButton.styleFrom(backgroundColor: Colors.white10,side: BorderSide.none,elevation: 0,shadowColor: Colors.transparent),))),
                   SizedBox(child:Container(margin: EdgeInsets.all(0),padding: EdgeInsets.all(0),child:Divider(
                  color: Color.fromARGB(58, 170, 170, 170),
                  thickness: 1,
                  ))),
                  SizedBox(height: 40,child: Container(padding: EdgeInsets.all(0),width:MediaQuery.of(context).size.width-10,height: 40 ,child: ElevatedButton(onPressed: (){}, child: Text("Xem trang cá nhân",style: TextStyle(color: mainColor,fontSize: 15),),style: ElevatedButton.styleFrom(backgroundColor: Colors.white10,side: BorderSide.none,elevation: 0,shadowColor: Colors.transparent),))),
                   SizedBox(child:Container(margin: EdgeInsets.all(0),padding: EdgeInsets.all(0),child:Divider(
                  color: Color.fromARGB(58, 170, 170, 170),
                  thickness: 1,
                  ))),
                   SizedBox(height: 40,child: Container(padding: EdgeInsets.all(0),width:MediaQuery.of(context).size.width-10,height: 40 ,child: ElevatedButton(onPressed: (){}, child: Text("Hủy",style: TextStyle(color: mainColor,fontSize: 15),),style: ElevatedButton.styleFrom(backgroundColor: Colors.white10,side: BorderSide.none,elevation: 0,shadowColor: Colors.transparent),))),
                ],)));
        });
  }

  removeMember(User user)async{
    MemberGroupChat memberGroupChat = await getMemberGroup(groupChat!.id!, user.id!);
    removeMemberGroup(memberGroupChat.id!, groupChat!.id!);
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
    //var chatRoom = ChatRoom(id: "",userFirst:(user["user"] as User).id!,userSecond:  auth.FirebaseAuth.instance.currentUser!.uid,createDate: DateTime.now());
    //CreateNewData("ChatRoom", chatRoom);
    var chatfinal = ChatFinal(chatContentFinal: "Hãy nhắn tin cho nhau nào!",chatFinalDate: DateTime.now(),typeChat: "user");
    CreateNewData("ChatFinal", chatfinal);
    setState(() {
        user["status"] = 3;
      });
      NotificationObject notification = NotificationObject(id: "",content: "${myUser.firstName} ${myUser.lastName} đã đồng ý kết bạn với bạn.",receiver:(user["user"] as User).id!,createDate: DateTime.now(),idObject: myUser.id,sender: myUser.id);
      CreateNewData("Notification", notification);
      PushNotification.sendPushNotification(User(),"${myUser.firstName} ${myUser.lastName} đã đồng ý kết bạn với bạn.",(user["user"] as User).token!);
  }
} 

