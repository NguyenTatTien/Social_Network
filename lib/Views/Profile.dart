import 'package:do_an_tot_nghiep/DAO/DAOHepper.dart';
import 'package:do_an_tot_nghiep/Models/ChatRoom.dart';
import 'package:do_an_tot_nghiep/Models/FriendShip.dart';
import 'package:do_an_tot_nghiep/Models/Like.dart';
import 'package:do_an_tot_nghiep/Models/Notification.dart';
import 'package:do_an_tot_nghiep/Models/Post.dart';
import 'package:do_an_tot_nghiep/Models/User.dart';
import 'package:do_an_tot_nghiep/NotificationService/PushNotification.dart';
import 'package:do_an_tot_nghiep/Views/Chat.dart';
import 'package:do_an_tot_nghiep/Views/EditProfile.dart';
import 'package:do_an_tot_nghiep/Views/PageComment.dart';
import 'package:do_an_tot_nghiep/Views/editorText.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// ignore: unnecessary_import
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
// ignore: import_of_legacy_library_into_null_safe, unused_import
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../Models/ReactionElement.dart';
import 'Design.dart';
 const kLargeTextStyle = TextStyle(
  fontSize: 23,
  fontWeight: FontWeight.bold,
);
   const kTitleTextStyle = TextStyle(
  fontSize: 14,
  color: Color.fromRGBO(129, 165, 168, 1),
);
   const kSmallTextStyle = TextStyle(
  fontSize: 16,
);
enum SampleItem { itemOne, itemTwo, itemThree }
class Profile extends StatefulWidget {
  String? id;
  Profile(this.id,{super.key});

  @override
  // ignore: no_logic_in_create_state
  State<Profile> createState() => _ProfileState(id);
}

class _ProfileState extends State<Profile> {
  String? id;
  User user = User();
  int check = 0;
  User myUser =User();
   List<ReactionElement> reactions= [
    ReactionElement("Like", Image.asset("assets/emoji/like.gif",width: 40,height: 40,)),
    ReactionElement("Love", Image.asset("assets/emoji/love.gif",width: 40,height: 40,)),
    ReactionElement("Haha", Image.asset("assets/emoji/haha.gif",width: 40,height: 40)),
    ReactionElement("WOW", Image.asset("assets/emoji/wow.gif",width: 40,height: 40)),
    ReactionElement("Sad", Image.asset("assets/emoji/sad.gif",width: 40,height: 40,)),
    ReactionElement("Angry", Image.asset("assets/emoji/angry.gif",width: 40,height: 40)),

  ];
  final controllerScroll = ScrollController();
  var posts = <Map<String,Object>>[];
  SampleItem? selectedMenu;
  bool _reactionView = false;
  _ProfileState(this.id);
  getData() async{
    user = await getUserById(id!);
    myUser = await getUserById(auth.FirebaseAuth.instance.currentUser!.uid);
    if(auth.FirebaseAuth.instance.currentUser!.uid==id){
     
      posts = await listPostByUser(id!);
    }
    else{
      check = await checkFriend(auth.FirebaseAuth.instance.currentUser!.uid, id!);
      if(check==3){
         posts = await listPostByUser(id!);
      }
    }
    setState(() {
      user;
      check;
    });
  }
  sendRequestShip(String userid) async{
      await CreateNewData("FriendShip", FriendShip(id:"",requester: auth.FirebaseAuth.instance.currentUser!.uid,addressee:userid,status: false));
      setState(() {
        check = 1;
      });
      NotificationObject notification = NotificationObject(id: "",content: "${myUser.firstName} ${myUser.lastName} đã gửi một yêu cầu kết bạn.",receiver:user.id ,createDate: DateTime.now(),idObject: myUser.id,sender: myUser.id);
       CreateNewData("Notification", notification);
       
       PushNotification.sendPushNotification(User(),"${myUser.firstName} ${myUser.lastName} đã gửi một yêu cầu kết bạn.",user.token!);
      
    }
  deleteRequestShip(String userid) async{
      await deleteFriend(userid, auth.FirebaseAuth.instance.currentUser!.uid);
      setState(() {
        check = 0;
      });
  }
  
  agreeShip(String userId) async{
    await makeFriend(userId, auth.FirebaseAuth.instance.currentUser!.uid);
    var chatRoom = ChatRoom(id: "",userFirst:userId,userSecond:  auth.FirebaseAuth.instance.currentUser!.uid,createDate: DateTime.now());
    CreateNewData("ChatRoom", chatRoom);
    setState(() {
        check = 3;
      });
      NotificationObject notification = NotificationObject(id: "",content: "${myUser.firstName} ${myUser.lastName} đã đồng ý kết bạn với bạn.",receiver:user.id ,createDate: DateTime.now(),idObject: myUser.id,sender: myUser.id);
       CreateNewData("Notification", notification);
      PushNotification.sendPushNotification(User(),"${myUser.firstName} ${myUser.lastName} đã đồng ý kết bạn với bạn.",user.token!);
  }

  @override
  void initState()  {
    user = User();
    getData();
    // TODO: implement initState
    super.initState();
  }
   likePost(Post post,int index) async{
   
    Like getlike = await checkLike(auth.FirebaseAuth.instance.currentUser!.uid,post.id!);
    // ignore: unnecessary_null_comparison
    if(getlike.id!=null){
      getlike.type = index;
      updateLikePost(getlike);
      setState(() {
        ((posts.firstWhere((element) => (element["post"] as Post).id==post.id)["listUserLikePost"]) as List<Like>).firstWhere((element) => element.userId==auth.FirebaseAuth.instance.currentUser!.uid).type=index;
        _reactionView = false;
      });
    }
    else{
      
      Like like = Like(id: "",postId: post.id,userId: auth.FirebaseAuth.instance.currentUser!.uid,type: index,createDate: DateTime.now());
      post.likeCount=post.likeCount! + 1;
      updatePost(post);
      CreateNewData("LikePost", like);
      if(post.createBy!=auth.FirebaseAuth.instance.currentUser!.uid){
        User user= await getUserById(auth.FirebaseAuth.instance.currentUser!.uid);
        NotificationObject notification = NotificationObject(id: "",content: "${user.firstName} ${user.lastName} đã thích một bài viết của bạn",receiver: post.createBy,createDate: DateTime.now(),idObject: post.id,sender: user.id);
        CreateNewData("Notification", notification);
        User userPost = await getUserById(post.createBy!);
        PushNotification.sendPushNotification(User(),"${user.firstName} ${user.lastName} đã thích một bài viết của bạn",userPost.token!);

      }
      setState(() {
      ((posts.firstWhere((element) => (element["post"] as Post).id==post.id)["post"]) as Post).likeCount! + 1;
      _reactionView = false;
      // ((posts.firstWhere((element) => (element["post"] as Post).id==id)["listUserLikePost"]) as List<Like>).remove((element) => element.userId==auth.FirebaseAuth.instance.currentUser!.uid);
      ((posts.firstWhere((element) => (element["post"] as Post).id==post.id)["listUserLikePost"]) as List<Like>).add(like);
    });
  
    }
   
    
  }
  notLikePost(Post post){
    post.likeCount = post.likeCount! - 1;
    var idLikePost = ((posts.firstWhere((element) => (element["post"] as Post).id==post.id)["listUserLikePost"]) as List<Like>).firstWhere((element)=> element.userId == auth.FirebaseAuth.instance.currentUser!.uid).id;
    updatePost(post);
    if(idLikePost != null && idLikePost != ""){
       removeData("LikePost",idLikePost);
        ((posts.firstWhere((element) => (element["post"] as Post).id==post.id)["post"]) as Post).likeCount! - 1;
        ((posts.firstWhere((element) => (element["post"] as Post).id==post.id)["listUserLikePost"]) as List<Like>).removeWhere((element) => element.userId==auth.FirebaseAuth.instance.currentUser!.uid);
    }
    setState(() {
      
      posts;
    });
    
  }
  removePost(String id){
    removePostById(id);
    posts.remove((element) => (element["post"] as Post).id==id);
    setState(() {
      posts;
    });

  }
  editPost(Post post){
   Navigator.push(context, MaterialPageRoute(builder: (context)=> EditorText(post.postImage,post)));
  }
  Widget information(){
    return Container(
            
            child: Column(
              children: <Widget>[
               
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image:  NetworkImage('${user.image}'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  "${user.firstName} ${user.lastName}",
                  style: kLargeTextStyle,
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  '${user.email}',
                  style: kTitleTextStyle,
                ),
                const SizedBox(
                  height: 25,
                ),
                
               
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    PostFollower(
                      number: posts.length,
                      title: 'Bài viết',
                    ),
                    PostFollower(
                      number: 110,
                      title: 'Bạn bè',
                    ),
                    
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                  if(check==3 && user.id!=auth.FirebaseAuth.instance.currentUser!.uid)
                       Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Column(
                            children: <Widget>[
                              
                              
                                    IconButton(
                                    icon: const Icon(Icons.person_remove_sharp,color: Colors.blueAccent), onPressed: ()=>deleteRequestShip(user.id!),
                                  ),
                                  const Text('Xóa bạn bè',style: TextStyle(
                                    color: Colors.blueAccent
                                  ),)
                            ],
                          ),
                          Column(
                            children: <Widget>[
                              IconButton(
                                icon: const Icon(Icons.message,color: Colors.blueAccent), onPressed: () {  },
                              ),
                              const Text('Nhắn tin',style: TextStyle(
                                color: Colors.blueAccent
                              ),)
                            ],
                          ),
                          // Column(
                          //   children: <Widget>[
                          //     IconButton(
                          //       icon: const Icon(Icons.more_vert,color: Colors.black),
                          //       onPressed: (){
                                  
                          //       },
                          //     ),
                          //     const Text('More',style: TextStyle(
                          //       color: Colors.black
                          //     ),)
                          //   ],
                          // )
                        ],
                      ),
                    ),
                     if(check==0 && user.id!=auth.FirebaseAuth.instance.currentUser!.uid)
                      Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Column(
                            children: <Widget>[
                              
                              
                                    IconButton(
                                    icon: const Icon(Icons.person_add,color: mainColor), onPressed: ()=>sendRequestShip(user.id!),
                                  ),
                                  const Text('Kết bạn',style: TextStyle(
                                    color: Colors.blueAccent
                                  ),)
                            ],
                          ),
                         
                          // Column(
                          //   children: <Widget>[
                          //     IconButton(
                          //       icon: const Icon(Icons.more_vert,color: Colors.black),
                          //       onPressed: (){
                                  
                          //       },
                          //     ),
                          //     const Text('More',style: TextStyle(
                          //       color: Colors.black
                          //     ),)
                          //   ],
                          // )
                        ],
                      ),
                    ),
                    if(check==1 && user.id!=auth.FirebaseAuth.instance.currentUser!.uid)
                      Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Column(
                            children: <Widget>[
                              
                              
                                    IconButton(
                                    icon: const Icon(Icons.person_off_rounded,color: Color.fromARGB(255, 255, 68, 115)), onPressed: ()=>deleteRequestShip(user.id!),
                                  ),
                                  const Text('Hủy kết bạn',style: TextStyle(
                                    color: Colors.blueAccent
                                  ),)
                            ],
                          ),
                         
                          // Column(
                          //   children: <Widget>[
                          //     IconButton(
                          //       icon: const Icon(Icons.more_vert,color: Colors.black),
                          //       onPressed: (){
                                  
                          //       },
                          //     ),
                          //     const Text('More',style: TextStyle(
                          //       color: Colors.black
                          //     ),)
                          //   ],
                          // )
                        ],
                      ),
                    ),
                    if(check==2 && user.id!=auth.FirebaseAuth.instance.currentUser!.uid)
                      Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Column(
                            children: <Widget>[
                              
                              
                                    IconButton(
                                    icon: const Icon(Icons.person_add_alt_1,color: Color.fromARGB(255, 255, 68, 115)), onPressed:()=> agreeShip(user.id!),
                                  ),
                                  const Text('Chấp nhận kết bạn',style: TextStyle(
                                    color: Colors.blueAccent
                                  ),)
                            ],
                          ),
                         
                          // Column(
                          //   children: <Widget>[
                          //     IconButton(
                          //       icon: const Icon(Icons.more_vert,color: Colors.black),
                          //       onPressed: (){
                                  
                          //       },
                          //     ),
                          //     const Text('More',style: TextStyle(
                          //       color: Colors.black
                          //     ),)
                          //   ],
                          // )
                        ],
                      ),
                    ),
                    SizedBox(height: 10.0,),
                    Container(
                      padding: const EdgeInsets.only(left: 10.0,right: 10.0),
                      child: Column(
                        children: <Widget>[
                          // Row(children: const <Widget>[
                          //   Icon(Icons.work),
                          //   SizedBox(width: 5.0,),
                          //   Text('Founder and CEO at',style: TextStyle(
                          //     fontSize: 18.0
                          //   ),),
                          //   SizedBox(width: 5.0,),
                          //   Text('SignBox',style: TextStyle(
                          //   fontSize: 18.0,
                          //     fontWeight: FontWeight.bold
                          //   ),)
                          // ],),
                          // const SizedBox(height: 10.0,),
                          // Row(children: const <Widget>[
                          //   Icon(Icons.work),
                          //   SizedBox(width: 5.0,),
                          //   Text('Works at',style: TextStyle(
                          //     fontSize: 18.0
                          //   ),),
                          //   SizedBox(width: 5.0,),
                          //   Text('SignBox',style: TextStyle(
                          //   fontSize: 18.0,
                          //     fontWeight: FontWeight.bold
                          //   ),)
                          // ],),
                          // const SizedBox(height: 10.0,),
                          // Row(children: const <Widget>[
                          //   Icon(Icons.school),
                          //   SizedBox(width: 5.0,),
                          //   Text('Studied Computer Science at',style: TextStyle(
                          //     fontSize: 18.0
                          //   ),),
                          //   SizedBox(width: 5.0,),                            
                          // ],),
                          Row(children: <Widget>[
                            const Icon(Icons.date_range),
                            const SizedBox(width: 5.0,),
                            Text('Sinh ngày ${user.birthDay}',style: const TextStyle(
                              fontSize: 18.0
                            ),),]),
                            
                          const SizedBox(height: 10.0,),
                          Row(children: <Widget>[
                            const Icon(Icons.phone),
                            const SizedBox(width: 5.0,),
                            Text('${user.phoneNumber}',style: const TextStyle(
                              fontSize: 18.0
                            ),),]),
                            

const SizedBox(height: 10.0,),
                          Row(children:<Widget>[
                            const Icon(Icons.home),
                            const SizedBox(width: 5.0,),
                            const Text('Sống tại',style: TextStyle(
                              fontSize: 18.0
                            ),),
                            const SizedBox(width: 5.0,),  
                             Expanded(child:Text('${user.address}',style: const TextStyle(
                            fontSize: 18.0,
                              fontWeight: FontWeight.bold
                            ),maxLines: 3,))                        
                          ],),


                          const SizedBox(height: 10.0,),
                          Row(children: const <Widget>[
                            Icon(Icons.location_on),
                            SizedBox(width: 5.0,),
                            Text('Đến từ',style: TextStyle(
                              fontSize: 18.0
                            ),),
                            SizedBox(width: 5.0,), 
                            Text('Việt Nam',style: TextStyle(
                            fontSize: 18.0,
                              fontWeight: FontWeight.bold
                            ),)                           
                          ],),
                            if(user.id == auth.FirebaseAuth.instance.currentUser!.uid)
                                  Row(children: <Widget>[
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () { Navigator.push(context, MaterialPageRoute(builder: (context)=> const EditProfile())); },
                                    child: const Text('Edit Information'),
                                  ),
                                )
                                ],),])),
                                Divider(color: Color.fromARGB(95, 46, 46, 46),thickness: 5,),
                             
                ]));
  }
  Widget loadPost(Map<String,Object> post){

     return Stack(
      children: [
        
      Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
            InkWell(
              onTap: (){Navigator.push(context, MaterialPageRoute(builder: (context)=> Profile((post["user"] as User).id)));},
              child:Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
              children: [
                Container(
                    margin: const EdgeInsets.fromLTRB(5, 0, 10, 0),
                      decoration: const BoxDecoration(color: Colors.white),
                      height: 45,
                      child: Stack(
                        children: <Widget>[
                          Container(
                              height: 45,
                              width: 45,
                              margin: const EdgeInsets.only(
                                  left: 0, right: 0, top: 0, bottom: 0),
                              padding: const EdgeInsets.all(2.0),
                              // decoration: BoxDecoration(
                                  // border:
                                  //     // Border.all(color: Color.fromARGB(255, 0, 207, 142), width: 2),
                                  // borderRadius: BorderRadius.circular(100)),
                              child: CircleAvatar(
                                backgroundImage: NetworkImage(
                                  '${(post["user"] as User).image}'
                                ),
                              )),
                              
                        ],
                      ),
                    ),
                    // ignore: avoid_unnecessary_containers
                    Container(child: Column(children: [
                      SizedBox(width: 150,child: Text("${(post["user"] as User).firstName} ${(post["user"] as User).lastName}",textAlign: TextAlign.left,style: TextStyle(fontWeight:FontWeight.bold,fontSize: 13),),),
                      // ignore: sized_box_for_whitespace, unnecessary_string_interpolations
                      Container(width: 150,child: Text("${(post["timePost"] as String).toString()}",textAlign: TextAlign.left,style: TextStyle(fontSize: 13),),),
                    ],),)
              ],
            ),
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
                  child: InkWell(onTap: (){editPost(post["post"] as Post);},child:Row(
                children: [
                  // ignore: avoid_unnecessary_containers
                  Container(child: const Icon(Icons.edit,size: 20,),),
                  Container(margin: const EdgeInsets.only(left: 5),child: const Text("Chỉnh sữa bài viết",style: TextStyle(fontSize: 15,color: Colors.black87),),)
                ],
              ),),
                ),
                PopupMenuItem<SampleItem>(
                  value: SampleItem.itemTwo,
                  child: InkWell(onTap: ()=>showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Xóa bài viết'),
          content: const Text('Bạn có muốn xóa bài viết'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, 'Cancel'),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {removePost((post["post"] as Post).id!);Navigator.pop(context, 'OK');},
              child:  Text('OK'),
            ),
          ],
        )),child:Row(
                children: [
                  // ignore: avoid_unnecessary_containers
                  Container(child: const Icon(Icons.delete,size: 20,),),
                  Container(margin: const EdgeInsets.only(left: 5),child: const Text("Xóa bài viết",style: TextStyle(fontSize: 15,color: Colors.black87),),)
                ],
              ),),
                ),
              
              ],
            ),
            ],
              ) ),
            Container(margin:const EdgeInsets.fromLTRB(10, 5, 0, 5),width: double.infinity,child: Text("${(post["post"] as Post).postContent}",textAlign: TextAlign.left,style: const TextStyle(fontSize: 13),),),
            // ignore: sized_box_for_whitespace
            Container(width: double.infinity,child: Image.network("${(post["post"] as Post).postImage}"),),
            if((post["post"] as Post).likeCount! > 0||(post["post"] as Post).commentCount! > 0)
              const Padding(
                                  padding: EdgeInsets.only(top: 5, bottom: 5),
                                  
                                  
                                ),
            if((post["post"] as Post).likeCount! > 0||(post["post"] as Post).commentCount! > 0)
              
                Container(padding: EdgeInsets.symmetric(horizontal: 25),child:Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                if((post["post"] as Post).likeCount! > 0)
                Row(
                  children: [
                    // ignore: avoid_unnecessary_containers
                    if((post["listUserLikePost"] as List<Like>).where((element)=>element.type==1).isNotEmpty)
                    InkWell(child: getImage(1).icon,onTap: (){},),
                    if((post["listUserLikePost"] as List<Like>).where((element)=>element.type==2).isNotEmpty)
                    InkWell(child: getImage(2).icon,onTap: (){},),
                    if((post["listUserLikePost"] as List<Like>).where((element)=>element.type==3).isNotEmpty)
                    InkWell(child: getImage(3).icon,onTap: (){},),
                    if((post["listUserLikePost"] as List<Like>).where((element)=>element.type==4).isNotEmpty)
                    InkWell(child: getImage(4).icon,onTap: (){},),
                    if((post["listUserLikePost"] as List<Like>).where((element)=>element.type==5).isNotEmpty)
                    InkWell(child: getImage(5).icon,onTap: (){},),
                    if((post["listUserLikePost"] as List<Like>).where((element)=>element.type==6).isNotEmpty)
                    InkWell(child: getImage(6).icon,onTap: (){},),
                          Container(margin: const EdgeInsets.only(left: 5),child: Text("${(post["post"] as Post).likeCount}",style: TextStyle(fontSize: 13,color: Colors.black87),),)
                        ],
                      ),
                      if((post["post"] as Post).commentCount! > 0)
                      Row(
                        children: [
                          // ignore: avoid_unnecessary_containers
                         InkWell(onTap: (){Navigator.push(context, MaterialPageRoute(builder: (context)=> PageComment((post))));},child:Container(child: const Icon(Icons.message,size: 20,),)),
                          Container(margin: const EdgeInsets.only(left: 5),child: Text("${(post["post"] as Post).commentCount}",style: TextStyle(fontSize: 13,color: Colors.black87),),)
                        ],
                      ),
                      // Row(
                      //   children: [
                      //     const Icon(Icons.share,size: 20,),R
                      //     Container(margin: const EdgeInsets.only(left: 5),child: const Text("Chia sẽ",style: TextStyle(fontSize: 13,color: Colors.black87),),)
                      //   ],
                      // )
                    ],)),             
            const Padding(
                      padding: EdgeInsets.only(left: 5, right: 5),
                      
                      child: Divider(color: Color.fromARGB(95, 46, 46, 46),),
                    ),
           
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
              if((post["listUserLikePost"] as List<Like>).where((element)=>element.userId==auth.FirebaseAuth.instance.currentUser!.uid).isEmpty)
                    InkWell(onTap: (){likePost((post["post"] as Post),1);},onLongPress: (){setState(() {
                        _reactionView = true;
                      });},child:  Row(
                        children: [
                          // ignore: avoid_unnecessary_containers
                          getImage(0).icon,
                          Container(margin: const EdgeInsets.only(left: 5),child: const Text("Thích",style: TextStyle(fontSize: 13,color: Colors.black87),),)
                        ],
                      ),),
              
              if((post["listUserLikePost"] as List<Like>).where((element)=>element.userId==auth.FirebaseAuth.instance.currentUser!.uid).isNotEmpty)
                      InkWell(onTap: (){notLikePost((post["post"] as Post));},onLongPress: (){setState(() {
                        _reactionView = true;
                      });},child:  Row(
                        children: [
                          // ignore: avoid_unnecessary_containers
                          // const Icon(Icons.favorite,size: 20,color: Colors.pink,),
                          getImage((post["listUserLikePost"] as List<Like>).firstWhere((element)=>element.userId==auth.FirebaseAuth.instance.currentUser!.uid).type!).icon,
                          Container(margin: const EdgeInsets.only(left: 5),child: Text(getImage((post["listUserLikePost"] as List<Like>).firstWhere((element)=>element.userId==auth.FirebaseAuth.instance.currentUser!.uid).type!).typeString,style: TextStyle(fontSize: 13,color: Colors.black87),),)
                        ],
                      ),),
              InkWell(onTap: (){Navigator.push(context, MaterialPageRoute(builder: (context)=> PageComment((post))));},child:Row(
                children: [
                  // ignore: avoid_unnecessary_containers
                  Container(child: const Icon(Icons.messenger_outline,size: 20,),),
                  Container(margin: const EdgeInsets.only(left: 5),child: const Text("Bình luận",style: TextStyle(fontSize: 13,color: Colors.black87),),)
                ],
              ),)
              // Row(
              //   children: [
              //     const Icon(Icons.share,size: 20,),
              //     Container(margin: const EdgeInsets.only(left: 5),child: const Text("Chia sẽ",style: TextStyle(fontSize: 13,color: Colors.black87),),)
              //   ],
              // )
            ],), const Divider(color: Color.fromARGB(95, 46, 46, 46),thickness: 5,),
          ],),
           if(_reactionView)
              Positioned(bottom: 50,left: 70,child:Opacity(opacity: 1,
      child: Container(
        padding: EdgeInsets.fromLTRB(2, 2, 2, 2),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30.0),
          border: Border.all(color: Colors.grey.shade300, width: 0.3),
          boxShadow: [
            BoxShadow(
                color: Colors.grey,
                blurRadius: 5.0,
                // LTRB
                offset: Offset.lerp(Offset(0.0, 0.0), Offset(0.0, 0.5), 10.0)!),
          ],
        ),
        width: 245.0,
        height:40,
    
          child: AnimationLimiter(
          child: ListView.builder(
            itemCount: reactions.length,
            padding: EdgeInsets.symmetric(vertical: 0),
            scrollDirection: Axis.horizontal,
            itemBuilder: (BuildContext context, int index) {
              return Container(width: 40,alignment: Alignment.center,margin: EdgeInsets.symmetric(vertical: 0),padding: EdgeInsets.symmetric(vertical: 0),child:  AnimationConfiguration.staggeredList(
              
                position: index,
                duration: const Duration(milliseconds: 375),
                child: SlideAnimation(
                  
                  verticalOffset: 20,
                  
                  child:FadeInAnimation(
                  
                    child: InkWell(child:reactions[index].icon,onTap: (){likePost((post["post"] as Post),index+1);})
                  ),
                ),
              ));})))),
     )],
     );
     
  }
  @override
  Widget build(BuildContext context) {
  
    return Scaffold(
      appBar:  AppBar(
        elevation: 0,
        leading: InkWell(onTap: (){Navigator.pop(context);},child: Icon(Icons.turn_left, color: Colors.black87,)),
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
              children: <Widget>[ 
                user.id!=null?information():Center(),
          ListView.builder(
          controller: controllerScroll,
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemBuilder: (context, index) {
            return loadPost(posts[index]);
          },
          itemCount: posts.length,)

                             
                // SizedBox(
                //   height: 30,
                // ),
                // GridView.count(
                //   crossAxisCount: 3,
                //   shrinkWrap: true,
                //   crossAxisSpacing: 10,
                //   mainAxisSpacing: 10,
                //   children: <Widget>[
                //     GalleryImage(
                //       imagePath: 'images/1.jpg',
                //     ),
                //     GalleryImage(
                //       imagePath: 'images/2.jpg',
                //     ),
                //     GalleryImage(
                //       imagePath: 'images/3.jpg',
                //     ),
                //     GalleryImage(
                //       imagePath: 'images/4.jpg',
                //     ),
                //     GalleryImage(
                //       imagePath: 'images/5.jpg',
                //     ),
                //     GalleryImage(
                //       imagePath: 'images/6.jpg',
                //     ),
                //   ],
                // ),
              ],
            ),
          ),
        ),
      
    );
  }
   ReactionElement getImage(int r){
    switch(r){
      case 1:
        return ReactionElement("Thích",Image.asset("assets/emoji/ic_like_fill.png",width: 20,height: 20,));
      case 2:
        return ReactionElement("Yêu thích",Image.asset("assets/emoji/love2.png",width: 20,height: 20,));
      case 3:
        return ReactionElement("Haha",Image.asset("assets/emoji/haha2.png",width: 20,height: 20,));
      case 4:
        return ReactionElement("Buồn",Image.asset("assets/emoji/sad2.png",width: 20,height: 20,));
      case 5:
        return ReactionElement("Wow",Image.asset("assets/emoji/wow2.png",width: 20,height: 20,));
      case 6:
        return ReactionElement("Phẩn nộ",Image.asset("assets/emoji/angry2.png",width: 20,height: 20,));
      default:
        return ReactionElement("Thích",Image.asset("assets/emoji/ic_like.png",width: 20,height: 20,));
    }
  }
}
// class GalleryImage extends StatelessWidget {
//   final String? imagePath;

//   GalleryImage({@required this.imagePath});y

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(15),
//         image: DecorationImage(
//           image: AssetImage(imagePath!),
//           fit: BoxFit.cover,
//         ),
//       ),
//     );
//   }
// }
class PostFollower extends StatelessWidget {
  final int ?number;
  final String? title;

  PostFollower({@required this.number, @required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(
          number.toString(),
          style: kLargeTextStyle,
        ),
        Text(
          title!,
          style: kSmallTextStyle,
        ),
      ],
    );
  }
   
  
}

class SocialButton extends StatelessWidget {
  final IconData? icon;
  final Color? iconColor;
  final Color? containerColor;

  SocialButton(
      {@required this.icon,
      @required this.iconColor,
      @required this.containerColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 7,
      ),
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: containerColor,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Icon(
        icon,
        color: iconColor,
        size: 20,
      ),
    );
  }
}
