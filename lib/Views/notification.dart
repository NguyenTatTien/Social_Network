import 'package:do_an_tot_nghiep/DAO/DAOHepper.dart';
import 'package:do_an_tot_nghiep/Models/Notification.dart';
import 'package:do_an_tot_nghiep/Models/User.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  var listNotification = <Map<String,Object>>[];
  var lastData;
  var scrollController =ScrollController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAllNotification();
    scrollController.addListener(scrollListener);
    
  }
  void scrollListener() async{
    if(scrollController.position.pixels==scrollController.position.maxScrollExtent){
        listNotification.addAll(await getAllNotificationByUser(auth.FirebaseAuth.instance.currentUser!.uid,lastData));
        setState(() {
          listNotification;
        });
    }
    
  }
  void getAllNotification() async{
    listNotification = await getAllNotificationByUser(auth.FirebaseAuth.instance.currentUser!.uid,lastData);
   
    setState(() {
      listNotification;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Center(child:Text("Thông báo",style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 20),),)
      ),
      body: Container(
        color: Colors.white,
        // ignore: prefer_is_empty
        child: listNotification.length > 0 ? ListView.builder(
          itemCount: listNotification.length,
          controller: scrollController,
          itemBuilder: (context, index) {
            return Slidable(
              actionPane: const SlidableDrawerActionPane(),
              actionExtentRatio: 0.25,
              child: notification(notification: listNotification[index],index: index),
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
          }) : const Center(child: Text("Không có thông báo!", style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),)),
      ),
    );
  }
  notification({required Map<String,Object> notification,required int index}) {
    var time = DateTime.now().difference((notification['notification'] as NotificationObject).createDate!);
    String stringTime = time.inSeconds < 60? time.inSeconds.toString()+" giây":time.inMinutes < 60 ? time.inMinutes.toString() +" phút": time.inHours < 24 ? time.inHours.toString() +" giờ" : DateFormat("dd/MM/yyyy").format((notification['notification'] as NotificationObject).createDate!).toString();
     return InkWell(onTap: (){
    },child:Container( color: index%2!=0?Color.fromARGB(255, 192, 226, 253):Colors.white ,child:Container(
      
      margin: const EdgeInsets.symmetric(horizontal: 10),
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
               Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image:  NetworkImage('${(notification['sender'] as User).image}'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: MediaQuery.of(context).size.width*0.75,child:Text((notification['notification'] as NotificationObject).content!, style: const TextStyle(color: Colors.black,fontSize: 15))),
                  const SizedBox(height: 5,),
                  Text("${stringTime}", style: TextStyle(color: Color.fromARGB(255, 134, 134, 134))),
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
    )));
  }
}
