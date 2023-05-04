import 'package:comment_box/comment/comment.dart';
import 'package:comment_tree/widgets/comment_tree_widget.dart';
import 'package:comment_tree/widgets/tree_theme_data.dart';
import 'package:do_an_tot_nghiep/DAO/DAOHepper.dart';
import 'package:do_an_tot_nghiep/Models/CommentObject.dart';
import 'package:do_an_tot_nghiep/Models/CommentShow.dart';
import 'package:do_an_tot_nghiep/Models/Like.dart';
import 'package:do_an_tot_nghiep/Models/Notification.dart';
import 'package:do_an_tot_nghiep/Models/ShortVideo.dart';
import 'package:do_an_tot_nghiep/Models/User.dart';
import 'package:do_an_tot_nghiep/NotificationService/PushNotification.dart';

import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

// ignore: depend_on_referenced_packages
import 'package:video_player/video_player.dart';
import 'dart:math' as math;

class Watches extends StatefulWidget {
  @override
  _Watches createState() => _Watches();
}

class _Watches extends State<Watches> with SingleTickerProviderStateMixin {
  bool abo = false;
  bool foryou = true;
  bool play = true;
  late VideoPlayerController _controller;
  late AnimationController animationController;
  PageController pageController =
      PageController(initialPage: 0, viewportFraction: 0.8);
  ScrollController _scrollController = ScrollController(initialScrollOffset: 0);
  PageController foryouController = new PageController();
  var listShortVideo = <Map<String, Object>>[];
  var jsonListComment = <Map<String, Object>>[];
   final formKey = GlobalKey<FormState>();
   String parentId ="";
  User userReceiver= User();
   final TextEditingController commentController = TextEditingController();
  User? myuser;

  @override
  void initState() {
    super.initState();
     loadData();
    animationController = new AnimationController(
        vsync: this, duration: new Duration(seconds: 5));
    animationController.repeat();
   
     
  }

  loadData() async {
    listShortVideo = await getListShortVideo(auth.FirebaseAuth.instance.currentUser!.uid);
    myuser = await getUserById(auth.FirebaseAuth.instance.currentUser!.uid);
     _controller = VideoPlayerController.network('${(listShortVideo[0]['shortvideo'] as ShortVideo).videoURL}')
    
      ..initialize().then((value) {
        _controller.play();
        _controller.setLooping(true);
        setState(() {});
      });
   
  }
  likeVideo(ShortVideo shortVideo,bool islike){
   setState(() {
    shortVideo.likeCount=shortVideo.likeCount! + 1;
    islike = true;
     
   });
   updateData("ShortVideo", shortVideo);
  }
  notLikeVideo(ShortVideo shortVideo,bool islike){
    setState(() {
    shortVideo.likeCount=shortVideo.likeCount! - 1;
    islike = false;
     
   });
   updateData("ShortVideo", shortVideo);
  }
  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    animationController.dispose();
    
  }
  getDataComment(var shortVideo)async{
      jsonListComment = await loadCommentPost((shortVideo!["shortvideo"] as ShortVideo).id!,"video");

      userReceiver = await getUserById((shortVideo!["shortvideo"]as ShortVideo).createById!);
    setState(() {
      jsonListComment;
      userReceiver;
    });
  }
   newLike(ShortVideo video,int index) async{
        Like like = Like(id: "",objectId: video.id,userId: auth.FirebaseAuth.instance.currentUser!.uid,type: 2,objectType: "video",createDate: DateTime.now());
        video.likeCount=video.likeCount! + 1;
       // updatePost(video);
        CreateNewData("Like", like);
        if(video.createById!=auth.FirebaseAuth.instance.currentUser!.uid){
          User user= await getUserById(auth.FirebaseAuth.instance.currentUser!.uid);
          NotificationObject notification = NotificationObject(id: "",content: "${user.firstName} ${user.lastName} đã thích một video của bạn",receiver: video.createById,createDate: DateTime.now(),idObject: video.id,sender: user.id);
          CreateNewData("Notification", notification);
          User userPost = await getUserById(video.createById!);
          PushNotification.sendPushNotification(User(),"${user.firstName} ${user.lastName} đã thích một video của bạn",userPost.token!);

        }
      setState(() {
        (listShortVideo[index]["shortvideo"] as ShortVideo).likeCount! + 1;
        listShortVideo[index]["isLike"] = true;
        // ((posts.firstWhere((element) => (element["post"] as Post).id==id)["listUserLikePost"]) as List<Like>).remove((element) => element.userId==auth.FirebaseAuth.instance.currentUser!.uid);
      
      });
    
  }
  disLike(ShortVideo video,int index)async{
    video.likeCount = video.likeCount! - 1;
    Like like = await getLike(auth.FirebaseAuth.instance.currentUser!.uid, video.id!);
    removeData("Like", like.id!);
  //  updatePost(video);
  //   if(idLike !=   && idLikePost != ""){
  //      removeData("Like",idLikePost);
  //       (jsonPost!["post"] as Post).likeCount! - 1;
  //       (jsonPost!["listUserLikePost"] as List<Like>).removeWhere((element) => element.userId==auth.FirebaseAuth.instance.currentUser!.uid);
  //   }
    
    setState(() {
      video;
      listShortVideo[index]["isLike"] = false;
     // jsonPost;
    });
    
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      body: Stack(
        children: <Widget>[
          homescreen(),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.center,
          //   children: <Widget>[
          //     TextButton(
          //         onPressed: () {
          //           setState(() {
          //             abo = true;
          //             foryou = false;
          //           });
          //         },
          //         child: Text('Short',
          //             style: abo
          //                 ? const TextStyle(
          //                     color: Colors.white,
          //                     fontWeight: FontWeight.bold,
          //                     fontSize: 18)
          //                 : const TextStyle(color: Colors.white, fontSize: 16))),
          //     const Text('|', style: TextStyle(color: Colors.white, fontSize: 5)),
          //     TextButton(
          //         onPressed: () {
          //           setState(() {
          //             abo = false;
          //             foryou = true;
          //           });
          //         },
          //         child: Text('Video',
          //             style: foryou
          //                 ? const TextStyle(
          //                     color: Colors.white,
          //                     fontWeight: FontWeight.bold,
          //                     fontSize: 18)
          //                 : const TextStyle(color: Colors.white, fontSize: 16))),
          //   ],
          // )
        ],
      ),
    );
  }

  homescreen() {
    if (foryou) {
      return PageView.builder(
          controller: foryouController,
          onPageChanged: (index) {
           
            setState(() {
             _controller = VideoPlayerController.network('${(listShortVideo[index]['shortvideo'] as ShortVideo).videoURL}')
    
            ..initialize().then((value) {
              _controller.play();
              _controller.setLooping(true);
              
            });
           
             
            });
          },
          scrollDirection: Axis.vertical,
          itemCount: listShortVideo.length,
          itemBuilder: (context, index) {
            return Stack(
              children: <Widget>[
                TextButton(
                    //    padding: EdgeInsets.all(0),
                    onPressed: () {
                      setState(() {
                        if (play) {
                          _controller.pause();
                          play = !play;
                        } else {
                          _controller.play();
                          play = !play;
                        }
                      });
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      child: VideoPlayer(_controller),
                    )),
                Padding(
                  padding: const EdgeInsets.only(bottom: 70),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: 100,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(left: 10, bottom: 10),
                            child: Text(
                              '${(listShortVideo[index]['shortvideo'] as ShortVideo).createByName}',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          Padding(
                              padding: const EdgeInsets.only(left: 10, bottom: 10),
                              child: 
                                  Text(
                                      '${(listShortVideo[index]['shortvideo'] as ShortVideo).content}',
                                      style: const TextStyle(fontSize: 14))
                          ),
                                
                          // Container(
                          //   padding: EdgeInsets.only(left: 10),
                          //   child: Row(
                          //     children: <Widget>[
                          //       Icon(Icons.music_note,
                          //           size: 16, color: Colors.white),
                          //       Text('R10 - Oboy',
                          //           style: TextStyle(color: Colors.white))
                          //     ],
                          //   ),
                          // )
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.only(bottom: 65, right: 10),
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: Container(
                        width: 70,
                        height: 400,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            Container(
                              margin: const EdgeInsets.only(bottom: 23),
                              width: 40,
                              height: 50,
                              child: Stack(
                                children: <Widget>[
                                   CircleAvatar(
                                    radius: 20,
                                    backgroundColor: Colors.white,
                                    child: CircleAvatar(
                                      radius: 19,
                                      backgroundColor: Colors.black,
                                      backgroundImage:
                                          NetworkImage('${(listShortVideo[index]['shortvideo'] as ShortVideo).createByImage}'),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.bottomCenter,
                                    child: CircleAvatar(
                                      radius: 10,
                                      backgroundColor:
                                          const Color(0xfd2c58).withOpacity(1),
                                      child: const Center(
                                          child: Icon(Icons.add,
                                              size: 15, color: Colors.white)),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            InkWell(onTap: (){
                              (listShortVideo[index]['isLike'] as bool)?disLike((listShortVideo[index]['shortvideo'] as ShortVideo),index):newLike((listShortVideo[index]['shortvideo'] as ShortVideo),index);
                            },child:Container(
                              padding: const EdgeInsets.only(bottom: 15),
                              child:Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Icon(Icons.favorite,
                                      size: 25, color: (listShortVideo[index]['isLike'] as bool)?Colors.red:Colors.white),
                                  Text('${(listShortVideo[index]['shortvideo'] as ShortVideo).likeCount}',
                                      style: TextStyle(
                                          color: (listShortVideo[index]['isLike'] as bool)?Colors.red:Colors.white, fontSize: 12))
                                ],
                              )),
                            ),
                            Container(
                              padding: const EdgeInsets.only(bottom: 15),
                              child: InkWell(child:Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Transform(
                                      alignment: Alignment.center,
                                      transform: Matrix4.rotationY(math.pi),
                                      child: const Icon(Icons.sms,
                                          size: 25, color: Colors.white)),
                                  Text('${(listShortVideo[index]['shortvideo'] as ShortVideo).commentCount}',
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 12))
                                ],
                              ),onTap: ()async{await getDataComment(listShortVideo[index]);showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            builder: (BuildContext context) {
              return StatefulBuilder(builder:(BuildContext context,StateSetter setstater){return Container(
                height: MediaQuery.of(context).size.height*3/4,
                color: Colors.white,
                child: Scaffold(
                 appBar: AppBar(iconTheme: const IconThemeData.fallback(),backgroundColor: Colors.white,
                 ),
                 body:CommentBox(
          userImage: CommentBox.commentImageParser(
              imageURLorPath: "${myuser!.image}"),
          child: jsonListComment.isNotEmpty ? ListView.builder(
          itemCount: jsonListComment.length,
        
          itemBuilder: (context, i) {
            return commentView(i);
          }):const Center(child: Text("Không có binh luận nào"),),
          labelText: 'Bình luận...',
          errorText: 'Bình luận không được để trống',
          withBorder: false,
          sendButtonMethod: () {
           

            commentPost(parentId,userReceiver,listShortVideo[index]);
            setState(() {
              commentController.text = "";
            });
          },
          formKey: formKey,
          commentController: commentController,
          backgroundColor: Color.fromARGB(255, 240, 240, 240),
          textColor: Color.fromARGB(255, 7, 7, 7),
          sendWidget: Icon(Icons.send_sharp, size: 30, color: Color.fromARGB(255, 0, 0, 0)),
        ) 
                )
              );});
            },
          );},)
                            ),
                            Container(
                              padding: const EdgeInsets.only(bottom: 30),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Transform(
                                      alignment: Alignment.center,
                                      transform: Matrix4.rotationY(math.pi),
                                      child: const Icon(Icons.reply,
                                          size: 25, color: Colors.white)),
                                  const Text('Partager',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 12))
                                ],
                              ),
                            ),
                            AnimatedBuilder(
                              animation: animationController,
                              child: CircleAvatar(
                                radius: 22,
                                backgroundColor: const Color(0x222222).withOpacity(1),
                                child: CircleAvatar(
                                  radius: 12,
                                  backgroundImage:
                                      NetworkImage('${(listShortVideo[index]['shortvideo'] as ShortVideo).content}'),
                                ),
                              ),
                              builder: (context, _widget) {
                                return Transform.rotate(
                                    angle: animationController.value * 6.3,
                                    child: _widget);
                              },
                            )
                          ],
                        ),
                      ),
                    ))
              ],
            );
          });
    } else {
      _controller.play();
      return Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.black,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: const Text(
                        'Créateurs tendances',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ))
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Center(
                    child: Container(
                      child: Column(
                        children: <Widget>[
                          Center(
                            child: Text(
                                'Abonne-toi à un compte pour découvrir ses',
                                style: TextStyle(
                                    color: Colors.white.withOpacity(0.8))),
                          ),
                          Center(
                            child: Text('dernières vidéos ici.',
                                style: TextStyle(
                                    color: Colors.white.withOpacity(0.8))),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
              Container(
                height: 372,
                margin: const EdgeInsets.only(top: 25),
                child: PageView.builder(
                    dragStartBehavior: DragStartBehavior.down,
                    controller: pageController,
                    itemCount: 5,
                    itemBuilder: (context, position) {
                      return videoSlider(position);
                    }),
              )
            ],
          ));
    }
  }

  videoSlider(int index) {
    return AnimatedBuilder(
      animation: pageController,
      builder: (context, widget) {
        double value = 1;
        if (pageController.position.haveDimensions) {
          value = (pageController.page! - index);
          value = (1 - (value.abs() * 0.3)).clamp(0.0, 1.0);
        }
        return Center(
          child: SizedBox(
            height: Curves.easeInOut.transform(value) * 372,
            width: Curves.easeInOut.transform(value) * 300,
            child: widget,
          ),
        );
      },
      child: Stack(
        children: <Widget>[
          ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            child: VideoPlayer(_controller),
          ),
          const Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: EdgeInsets.all(5),
                child: Icon(
                  Icons.close,
                  size: 15,
                  color: Colors.white,
                ),
              )),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.only(bottom: 15),
              height: 370 / 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Padding(
                      padding: const EdgeInsets.only(bottom: 15),
                      child: CircleAvatar(
                        backgroundColor: Colors.black,
                        backgroundImage: AssetImage('${(listShortVideo[index]['shortvideo'] as ShortVideo).createByImage}'),
                        radius: 30,
                      )),
                  const Padding(
                      padding: EdgeInsets.only(bottom: 6),
                      child:
                          Text('Spook', style: TextStyle(color: Colors.white))),
                  Text('${(listShortVideo[index]['shortvideo'] as ShortVideo).createByName}',
                      style: TextStyle(color: Colors.white.withOpacity(0.5))),
                  Container(
                      height: 50,
                      margin: const EdgeInsets.only(left: 50, right: 50, top: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xfe2b54).withOpacity(1),
                        borderRadius: const BorderRadius.all(Radius.circular(5)),
                      ),
                      child: const Center(
                        child: Text(
                          'Abonnement',
                          style: TextStyle(color: Colors.white),
                        ),
                      ))
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  buttonplus() {
    return Container(
      width: 46,
      height: 30,
      decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          color: Colors.transparent),
      child: Stack(
        children: <Widget>[
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: 28,
              height: 30,
              decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  color: const Color(0x2dd3e7).withOpacity(1)),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              width: 28,
              height: 30,
              decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  color: const Color(0xed316a).withOpacity(1)),
            ),
          ),
          Center(
            child: Container(
              width: 28,
              height: 30,
              decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  color: Colors.white),
              child: const Center(child: Icon(Icons.add, color: Colors.black)),
            ),
          )
        ],
      ),
    );
  }
  
  Widget commentView(int i){
    return Container(
            child: CommentTreeWidget<CommentShow, CommentShow>(
              CommentShow(
                  userId: '',
                  avatar: '${(jsonListComment![i]["userComment"] as User).image}',
                  userName: '${(jsonListComment![i]["userComment"] as User).firstName} ${(jsonListComment![i]["userComment"] as User).lastName}',
                  content: '${(jsonListComment![i]["parentComment"] as CommentObject).content}'),
                  
              // ignore: prefer_const_literals_to_create_immutables
              [
                for(var item in (jsonListComment![i]["jsonSubComment"] as List<Map<String,Object>>))
                  CommentShow(
                      userId: '${(item["userSubComment"] as User).id}',
                      avatar: '${(item["userSubComment"] as User).image}',
                      userName: '${(item["userSubComment"] as User).firstName} ${(item["userSubComment"] as User).lastName}',
                      content: '${(item["subComment"] as CommentObject).content}'),
                // Comment(
                //     avatar: 'assets/images/person5.jpg',
                //     userName: 'anh tien',
                //     content:
                //         'A Dart template generator which helps teams generator which helps teams generator which helps teams'),
                // Comment(
                //     avatar: 'assets/images/person6.jpg',
                //     userName: 'co deo nhe',
                //     content: 'A Dart template generator which helps teams'),
                // Comment(
                //     avatar: 'assets/images/person7.jpg',
                //     userName: 'ten ne',
                //     content:
                //         'A Dart template generator which helps teams generator which helps teams '),
              ],
              
              treeThemeData:
                    TreeThemeData(lineColor:(jsonListComment![i]["jsonSubComment"] as List<Map<String,Object>>).length>0?Color.fromARGB(255, 223, 223, 223):Color.fromARGB(255, 255, 255, 255), lineWidth:2),
              avatarRoot: (context, data) => PreferredSize(
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.grey,
                  backgroundImage: NetworkImage(data.avatar!),
                ),
                preferredSize: Size.fromRadius(18),
              ),
              avatarChild: (context, data) => PreferredSize(
                child: CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.grey,
                  backgroundImage: NetworkImage('${data.avatar}'),
                ),
                preferredSize: Size.fromRadius(12),
              ),
              contentChild: (context, data) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                      decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${data.userName}',
                            style: Theme.of(context).textTheme.caption?.copyWith(
                                fontWeight: FontWeight.w600, color: Colors.black),
                          ),
                          const SizedBox(
                            height: 4,
                          ),
                          Text(
                            '${data.content}',
                            style: Theme.of(context).textTheme.caption?.copyWith(
                                fontWeight: FontWeight.w300, color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                    if(data.userId!=auth.FirebaseAuth.instance.currentUser!.uid)
                      DefaultTextStyle(
                        // ignore: deprecated_member_use
                        style: Theme.of(context).textTheme.caption!.copyWith(
                            color: Colors.grey[700], fontWeight: FontWeight.bold),
                        child: Padding(
                          padding: EdgeInsets.only(top: 4),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 8,
                              ),
                              Text('Like'),
                              SizedBox(
                                width: 24,
                              ),
                              InkWell(onTap: ()async{
                              commentController.text = data.userName!;
                              userReceiver = await getUserById(data.userId!);
                              setState(() {
                                parentId = (jsonListComment![i]["parentComment"] as CommentObject).id!;
                                userReceiver;
                                commentController;
                              });
                             
                            },child:Text('Reply'),),
                            ],
                          ),
                        ),
                      )
                  ],
                );
              },
              contentRoot: (context, data) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                      decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${data.userName}',
                            style: Theme.of(context).textTheme.caption!.copyWith(
                                fontWeight: FontWeight.w600, color: Colors.black),
                          ),
                          const SizedBox(
                            height: 4,
                          ),
                          Text(
                            '${data.content}',
                            style: Theme.of(context).textTheme.caption!.copyWith(
                                fontWeight: FontWeight.w300, color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                  if(data.userId != auth.FirebaseAuth.instance.currentUser!.uid)
                    DefaultTextStyle(
                      style: Theme.of(context).textTheme.caption!.copyWith(
                          color: Colors.grey[700], fontWeight: FontWeight.bold),
                      child: Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: Row(
                          children: [
                            const SizedBox(
                              width: 8,
                            ),
                            Text('Like'),
                            SizedBox(
                              width: 24,
                            ),
                            InkWell(onTap: (){
                              commentController.text = (jsonListComment![i]["userComment"] as User).firstName! + " "+ (jsonListComment![i]["userComment"] as User).lastName!;
                              
                              setState(() {
                                parentId = (jsonListComment[i]["parentComment"] as CommentObject).id!;
                                userReceiver = (jsonListComment[i]["userComment"] as User);
                                commentController;
                              });
                          
                            },child:Text('Reply')),
                          ],
                        ),
                      ),
                    )
                  ],
                );
              },
            ),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          );
  }
   void commentPost(String parentId,User userReceiver,var jsonPost) async{
    if(commentController.text!=""){
        // ignore: unnecessary_null_comparison
        String userid = userReceiver != null ? userReceiver.id! :  "";
        
        CommentObject comment = CommentObject(id: "",userId: auth.FirebaseAuth.instance.currentUser!.uid,postId:(jsonPost!["shortvideo"] as ShortVideo).id,parentId: parentId,receiver: userid,content: commentController.text,type: "video", createDate: DateTime.now());
    CreateNewData("Comment", comment);
   
    if(parentId!=""){
        ((jsonListComment.firstWhere((element) => (element["parentComment"] as CommentObject).id==parentId))["jsonSubComment"] as List<Map<String,Object>>).add({"subComment":comment,"userSubComment":myuser!});
        NotificationObject notification = NotificationObject(id: "",content: "${myuser!.firstName} ${myuser!.lastName} đã nhắc bạn trong bài viết bạn quan tâm.",receiver: (jsonPost!["shortvideo"] as ShortVideo).createById,createDate: DateTime.now(),idObject: (jsonPost!["shortvideo"] as ShortVideo).id,sender: myuser!.id);
       CreateNewData("Notification", notification);
       PushNotification.sendPushNotification(User(),"${myuser!.firstName} ${myuser!.lastName} đã bình luận một bài viết của bạn.",userReceiver.token!);
    }
    else{
       jsonListComment.insert(0,{"parentComment":comment,"userComment":myuser!,"jsonSubComment":<Map<String,Object>>[]});
      if((jsonPost!["shortvideo"] as ShortVideo).createById != auth.FirebaseAuth.instance.currentUser!.uid){
          
       NotificationObject notification = NotificationObject(id: "",content: "${myuser!.firstName} ${myuser!.lastName} đã bình luận một bài viết của bạn.",receiver: (jsonPost!["shortvideo"] as ShortVideo).createById,createDate: DateTime.now(),idObject: (jsonPost!["shortvideo"] as ShortVideo).id,sender: myuser!.id);
       CreateNewData("Notification", notification);
       PushNotification.sendPushNotification(User(),"${myuser!.firstName} ${myuser!.lastName} đã bình luận một bài viết của bạn.",userReceiver.token!);
      }
    }
   (jsonPost!["shortvideo"] as ShortVideo).commentCount = (jsonPost!["shortvideo"] as ShortVideo).commentCount! + 1;
  
 // updatePost((jsonPost!["post"] as ShortVideo));
    setState(() {
      jsonListComment;
      jsonPost;
    });
    }
  }
}
