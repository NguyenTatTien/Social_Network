import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:do_an_tot_nghiep/DAO/DAOHepper.dart';
import 'package:do_an_tot_nghiep/Models/Like.dart';
import 'package:do_an_tot_nghiep/Models/Notification.dart';
import 'package:do_an_tot_nghiep/Models/Post.dart';
import 'package:do_an_tot_nghiep/Models/User.dart';
import 'package:do_an_tot_nghiep/NotificationService/PushNotification.dart';
import 'package:do_an_tot_nghiep/Views/Profile.dart';
import 'package:do_an_tot_nghiep/Views/mainpage.dart';
import 'package:do_an_tot_nghiep/Views/pageComment.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../Models/ReactionElement.dart';

 enum Reaction {like,smilling,angry,anguished,grinning,love,none}
// ignore: must_be_immutable
class FirstFeedIU extends StatefulWidget {
  const FirstFeedIU({super.key});

  @override
  State<FirstFeedIU> createState() => _FirstFeedIUState();
}

class _FirstFeedIUState extends State<FirstFeedIU> {
  final controllerScroll = ScrollController();
  var posts = <Map<String,Object>>[];
  List<bool> _reactionViews = [];
  var lastData = null;
  Reaction _reaction = Reaction.none;
  bool _reactionView = false;
  List<ReactionElement> reactions= [
    ReactionElement("Like", Image.asset("assets/emoji/like.gif",width: 40,height: 40,)),
    ReactionElement("Love", Image.asset("assets/emoji/love.gif",width: 40,height: 40,)),
    ReactionElement("Haha", Image.asset("assets/emoji/haha.gif",width: 40,height: 40)),
    ReactionElement("WOW", Image.asset("assets/emoji/wow.gif",width: 40,height: 40)),
    ReactionElement("Sad", Image.asset("assets/emoji/sad.gif",width: 40,height: 40,)),
    ReactionElement("Angry", Image.asset("assets/emoji/angry.gif",width: 40,height: 40)),

  ];
   Future inintall()async{
    posts = await listPost("Post",auth.FirebaseAuth.instance.currentUser!.uid,lastData);
    print((posts[0]["listUserLikePost"] as List<Like>).length);
    setState(() {
      posts;
       _reactionViews = List<bool>.generate(posts.length, (index) => false,growable: true);
    });
  }
  @override
  void initState() {
    inintall();
   
    // TODO: implement initState
    super.initState();
    
     MainPage.scrollController.addListener(scrollListener);
  }
   void scrollListener() async{
    
      if (MainPage.scrollController.position.pixels == MainPage.scrollController.position.maxScrollExtent) {
       
      lastData = (posts[posts.length-1]["post"] as Post).createDate;
      var newpost = await listPost("Post",auth.FirebaseAuth.instance.currentUser!.uid,lastData);
      for(var item in newpost){
        posts.add({"post":item["post"] as Post,"user":item["user"] as User,"timePost":item["timePost"] as String,"listUserLikePost":item["listUserLikePost"] as List<Like>});
      }
      setState(() {
        posts;
        _reactionViews = List<bool>.generate(posts.length, (index) => false,growable: true);
      });
      
    
    } 
  }
 
  likePost(Post post,int index) async{
   
    Like getlike = await checkLike(auth.FirebaseAuth.instance.currentUser!.uid,post.id!);
    // ignore: unnecessary_null_comparison
    if(getlike.id!=null){
      getlike.type = index;
      updateLikePost(getlike);
      setState(() {
        ((posts.firstWhere((element) => (element["post"] as Post).id==post.id)["listUserLikePost"]) as List<Like>).firstWhere((element) => element.userId==auth.FirebaseAuth.instance.currentUser!.uid).type=index;
         //_reactionViews[index] = false;
      });
    }
    else{
      
      Like like = Like(id: "",objectId: post.id,userId: auth.FirebaseAuth.instance.currentUser!.uid,type: index,objectType: "post",createDate: DateTime.now());
      post.likeCount=post.likeCount! + 1;
      updatePost(post);
      CreateNewData("Like", like);
      if(post.createBy!=auth.FirebaseAuth.instance.currentUser!.uid){
        User user= await getUserById(auth.FirebaseAuth.instance.currentUser!.uid);
        NotificationObject notification = NotificationObject(id: "",content: "${user.firstName} ${user.lastName} đã thích một bài viết của bạn",receiver: post.createBy,createDate: DateTime.now(),idObject: post.id,sender: user.id);
        CreateNewData("Notification", notification);
        User userPost = await getUserById(post.createBy!);
        PushNotification.sendPushNotification(User(),"${user.firstName} ${user.lastName} đã thích một bài viết của bạn",userPost.token!);

      }
      setState(() {
      ((posts.firstWhere((element) => (element["post"] as Post).id==post.id)["post"]) as Post).likeCount! + 1;
      // _reactionViews[index] = false;
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
       removeData("Like",idLikePost);
        ((posts.firstWhere((element) => (element["post"] as Post).id==post.id)["post"]) as Post).likeCount! - 1;
        ((posts.firstWhere((element) => (element["post"] as Post).id==post.id)["listUserLikePost"]) as List<Like>).removeWhere((element) => element.userId==auth.FirebaseAuth.instance.currentUser!.uid);
    }
    setState(() {
      
      posts;
    });
    
  }
  Widget loadPost(Map<String,Object> post,int index){

     return Stack(
      children: [
        
      Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
            InkWell(
              onTap: (){Navigator.push(context, MaterialPageRoute(builder: (context)=> Profile((post["user"] as User).id)));},
              child:Row(
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
            ),),
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
                     
                        _reactionViews[index] = true;
                      });
                      },onTapCancel: () {
                         
                        setState(() {
                            _reactionViews[index] = false;
                        });
                        
                      },child:  Row(
                        children: [
                          // ignore: avoid_unnecessary_containers
                          getImage(0).icon,
                          Container(margin: const EdgeInsets.only(left: 5),child: const Text("Thích",style: TextStyle(fontSize: 13,color: Colors.black87),),)
                        ],
                      ),),
              
              if((post["listUserLikePost"] as List<Like>).where((element)=>element.userId==auth.FirebaseAuth.instance.currentUser!.uid).isNotEmpty)
                      InkWell(onTap: (){notLikePost((post["post"] as Post));},onLongPress: (){setState(() {
                       _reactionViews[index] = true;
                      });},onTapCancel: () {
                         
                        setState(() {
                            _reactionViews[index] = false;
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
           if(_reactionViews[index])
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
            itemBuilder: (BuildContext context, int i) {
              return Container(width: 40,alignment: Alignment.center,margin: EdgeInsets.symmetric(vertical: 0),padding: EdgeInsets.symmetric(vertical: 0),child:  AnimationConfiguration.staggeredList(
              
                position: i,
                duration: const Duration(milliseconds: 375),
                child: SlideAnimation(
                  
                  verticalOffset: 20,
                  
                  child:FadeInAnimation(
                    child: InkWell(child:reactions[i].icon,onTap: (){likePost((post["post"] as Post),i+1);setState(() {
                         _reactionViews[index] = false;
                    });})
                  ),
                ),
              ));})))),
     )],
     );
     
  }
  @override
  Widget build(BuildContext context) {
    if(posts.isNotEmpty){
    return

       ListView.builder(
          controller: controllerScroll,
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemBuilder: (context, index) {
            return loadPost(posts[index],index);
          },
          itemCount: posts.length,);
    } 
    else {
      return const Center(child:Text("Không có bài viết nào!",style: TextStyle(fontSize: 12),));
    }
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
