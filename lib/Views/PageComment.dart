import 'package:comment_box/comment/comment.dart';
import 'package:comment_tree/data/comment.dart';
import 'package:comment_tree/widgets/comment_tree_widget.dart';
import 'package:comment_tree/widgets/tree_theme_data.dart';
import 'package:do_an_tot_nghiep/DAO/DAOHepper.dart';
import 'package:do_an_tot_nghiep/Models/CommentPost.dart';
import 'package:do_an_tot_nghiep/Models/Notification.dart';
import 'package:do_an_tot_nghiep/Models/Post.dart';
import 'package:do_an_tot_nghiep/Models/User.dart';
import 'package:do_an_tot_nghiep/NotificationService/PushNotification.dart';
import 'package:do_an_tot_nghiep/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../Models/CommentShow.dart';
import '../Models/Like.dart';
import '../Models/ReactionElement.dart';

// ignore: must_be_immutable
class PageComment extends StatefulWidget {
  Map<String,Object>? jsonPost;
  
  PageComment(this.jsonPost, {super.key});
  @override
  // ignore: no_logic_in_create_state, unnecessary_this
  State<PageComment> createState() => _PageCommentState(this.jsonPost);
}
class _PageCommentState extends State<PageComment> {
  Map<String,Object>? jsonPost;
  String parentId ="";
  User userReceiver= User();
  User user = User();
  bool _reactionView = false;
  List<Map<String,Object>>? jsonListComment = <Map<String,Object>>[];
   final formKey = GlobalKey<FormState>();
   final TextEditingController commentController = TextEditingController();
    List<ReactionElement> reactions= [
    ReactionElement("Like", Image.asset("assets/emoji/like.gif",width: 40,height: 40,)),
    ReactionElement("Love", Image.asset("assets/emoji/love.gif",width: 40,height: 40,)),
    ReactionElement("Haha", Image.asset("assets/emoji/haha.gif",width: 40,height: 40)),
    ReactionElement("WOW", Image.asset("assets/emoji/wow.gif",width: 40,height: 40)),
    ReactionElement("Sad", Image.asset("assets/emoji/sad.gif",width: 40,height: 40,)),
    ReactionElement("Angry", Image.asset("assets/emoji/angry.gif",width: 40,height: 40)),

  ];
  _PageCommentState(this.jsonPost);
  likePost(Post post,int index) async{
    Like getlike = await checkLike(auth.FirebaseAuth.instance.currentUser!.uid,post.id!);
    // ignore: unnecessary_null_comparison
    if(getlike.id!=null){
      getlike.type = index;
      updateLikePost(getlike);
      setState(() {
        ((jsonPost!["listUserLikePost"]) as List<Like>).firstWhere((element) => element.userId==auth.FirebaseAuth.instance.currentUser!.uid).type=index;
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
        (jsonPost!["post"] as Post).likeCount! + 1;
        _reactionView = false;
        // ((posts.firstWhere((element) => (element["post"] as Post).id==id)["listUserLikePost"]) as List<Like>).remove((element) => element.userId==auth.FirebaseAuth.instance.currentUser!.uid);
        (jsonPost!["listUserLikePost"] as List<Like>).add(like);
      });
    }
  }
  notLikePost(Post post){
    post.likeCount = post.likeCount! - 1;
    var idLikePost = (jsonPost!["listUserLikePost"] as List<Like>).firstWhere((element)=> element.userId == auth.FirebaseAuth.instance.currentUser!.uid).id;
    updatePost(post);
    if(idLikePost != null && idLikePost != ""){
       removeData("LikePost",idLikePost);
        (jsonPost!["post"] as Post).likeCount! - 1;
        (jsonPost!["listUserLikePost"] as List<Like>).removeWhere((element) => element.userId==auth.FirebaseAuth.instance.currentUser!.uid);
    }
    setState(() {
      
      jsonPost;
    });
    
  }
  void loadComment() async{
   
    jsonListComment = await loadCommentPost((jsonPost!["post"] as Post).id!);
    user = await getUserById(auth.FirebaseAuth.instance.currentUser!.uid);
    
    setState(() {
      jsonListComment;
      user;
    });
  }
 
  @override
  void initState() {
    // TODO: implement initState
    loadComment();
    userReceiver = (jsonPost!["user"] as User);
    super.initState();
  }
  Widget commentChild(){
    return SingleChildScrollView(child:
    Column(
            mainAxisAlignment: MainAxisAlignment.start,
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
                                  '${(jsonPost!["user"] as User).image}'
                                ),
                              )),
                              
                        ],
                      ),
                    ),
                    // ignore: avoid_unnecessary_containers
                    Container(child: Column(children: [
                      SizedBox(width: 150,child: Text("${(jsonPost!["user"] as User).firstName} ${(jsonPost!["user"] as User).lastName}",textAlign: TextAlign.left,style: TextStyle(fontWeight:FontWeight.bold,fontSize: 13),),),
                      // ignore: sized_box_for_whitespace, unnecessary_string_interpolations
                      Container(width: 150,child: Text("${(jsonPost!["timePost"] as String).toString()}",textAlign: TextAlign.left,style: TextStyle(fontSize: 13),),),
                    ],),)
              ],
            ),
            Container(margin:const EdgeInsets.fromLTRB(10, 5, 0, 5),width: double.infinity,child: Text("${(jsonPost!["post"] as Post).postContent}",textAlign: TextAlign.left,style: const TextStyle(fontSize: 13),),),
            // ignore: sized_box_for_whitespace
            Container(width: double.infinity,child: Image.network("${(jsonPost!["post"] as Post).postImage}"),),
            if((jsonPost!["post"] as Post).likeCount! > 0||(jsonPost!["post"] as Post).commentCount! > 0)
              const Padding(
                                  padding: EdgeInsets.only(top: 5, bottom: 5),
                                  
                                  
                                ),
            if((jsonPost!["post"] as Post).likeCount! > 0||(jsonPost!["post"] as Post).commentCount! > 0)
              
                Container(padding: EdgeInsets.symmetric(horizontal: 25),child:Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                if((jsonPost!["post"] as Post).likeCount! > 0)
                Row(
                  children: [
                    // ignore: avoid_unnecessary_containers
                  
                    if((jsonPost!["listUserLikePost"] as List<Like>).where((element)=>element.type==1).isNotEmpty)
                    InkWell(child: getImage(1).icon,onTap: (){},),
                    if((jsonPost!["listUserLikePost"] as List<Like>).where((element)=>element.type==2).isNotEmpty)
                    InkWell(child: getImage(2).icon,onTap: (){},),
                    if((jsonPost!["listUserLikePost"] as List<Like>).where((element)=>element.type==3).isNotEmpty)
                    InkWell(child: getImage(3).icon,onTap: (){},),
                    if((jsonPost!["listUserLikePost"] as List<Like>).where((element)=>element.type==4).isNotEmpty)
                    InkWell(child: getImage(4).icon,onTap: (){},),
                    if((jsonPost!["listUserLikePost"] as List<Like>).where((element)=>element.type==5).isNotEmpty)
                    InkWell(child: getImage(5).icon,onTap: (){},),
                    if((jsonPost!["listUserLikePost"] as List<Like>).where((element)=>element.type==6).isNotEmpty)
                    InkWell(child: getImage(6).icon,onTap: (){},),
                          Container(margin: const EdgeInsets.only(left: 5),child: Text("${(jsonPost!["post"] as Post).likeCount}",style: TextStyle(fontSize: 13,color: Colors.black87),),)
                        ],
                      ),
                      if((jsonPost!["post"] as Post).commentCount! > 0)
                      Row(
                        children: [
                          // ignore: avoid_unnecessary_containers
                          Container(child: const Icon(Icons.message,size: 20,),),
                          Container(margin: const EdgeInsets.only(left: 5),child: Text("${(jsonPost!["post"] as Post).commentCount}",style: TextStyle(fontSize: 13,color: Colors.black87),),)
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
              if((jsonPost!["listUserLikePost"] as List<Like>).where((element)=>element.userId==auth.FirebaseAuth.instance.currentUser!.uid).isEmpty)
                    InkWell(onTap: (){likePost((jsonPost!["post"] as Post),1);},onLongPress: (){setState(() {
                        _reactionView = true;
                      });},child:  Row(
                        children: [
                          // ignore: avoid_unnecessary_containers
                           getImage(0).icon,
                         
                          Container(margin: const EdgeInsets.only(left: 5),child: const Text("Thích",style: TextStyle(fontSize: 13,color: Colors.black87),),)
                        ],
                      ),),
              if((jsonPost!["listUserLikePost"] as List<Like>).where((element)=>element.userId==auth.FirebaseAuth.instance.currentUser!.uid).isNotEmpty)
                      InkWell(onTap: (){notLikePost((jsonPost!["post"] as Post));},onLongPress: (){setState(() {
                        _reactionView = true;
                      });},child:  Row(
                        children: [
                          // ignore: avoid_unnecessary_containers
                           getImage((jsonPost!["listUserLikePost"] as List<Like>).firstWhere((element)=>element.userId==auth.FirebaseAuth.instance.currentUser!.uid).type!).icon,
                          Container(margin: const EdgeInsets.only(left: 5),child: Text(getImage((jsonPost!["listUserLikePost"] as List<Like>).firstWhere((element)=>element.userId==auth.FirebaseAuth.instance.currentUser!.uid).type!).typeString,style: TextStyle(fontSize: 13,color: Colors.black87),),)
                        ],
                      ),),
              InkWell(onTap: (){setState(() {
                parentId = "";
                userReceiver = (jsonPost!["user"] as User);
              });},child:Row(
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
            ],), const Divider(color: Color.fromARGB(95, 46, 46, 46),),
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
                  
                    child: InkWell(child:reactions[index].icon,onTap: (){likePost((jsonPost!["post"] as Post),index+1);})
                  ),
                ),
              ));})))),
     ),
  for(int i = 0;i<jsonListComment!.length;i++)
    commentView(i),
    
              ],),
      );
  }
Widget commentView(int i){
    return Container(
            child: CommentTreeWidget<CommentShow, CommentShow>(
              CommentShow(
                  userId: '${(jsonListComment![i]["userComment"] as User).id}',
                  avatar: '${(jsonListComment![i]["userComment"] as User).image}',
                  userName: '${(jsonListComment![i]["userComment"] as User).firstName} ${(jsonListComment![i]["userComment"] as User).lastName}',
                  content: '${(jsonListComment![i]["parentComment"] as CommentPost).content}'),
                  
              // ignore: prefer_const_literals_to_create_immutables
              [
                for(var item in (jsonListComment![i]["jsonSubComment"] as List<Map<String,Object>>))
                  CommentShow(
                      userId: '${(item["userSubComment"] as User).id}',
                      avatar: '${(item["userSubComment"] as User).image}',
                      userName: '${(item["userSubComment"] as User).firstName} ${(item["userSubComment"] as User).lastName}',
                      content: '${(item["subComment"] as CommentPost).content}'),
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
                                parentId = (jsonListComment![i]["parentComment"] as CommentPost).id!;
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
                          SizedBox(
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
                            SizedBox(
                              width: 8,
                            ),
                            Text('Like'),
                            SizedBox(
                              width: 24,
                            ),
                            InkWell(onTap: (){
                              commentController.text = (jsonListComment![i]["userComment"] as User).firstName! + " "+ (jsonListComment![i]["userComment"] as User).lastName!;
                              
                              setState(() {
                                parentId = (jsonListComment![i]["parentComment"] as CommentPost).id!;
                                userReceiver = (jsonListComment![i]["userComment"] as User);
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.white,appBar: AppBar(title: Text("Bình luận"),),body:CommentBox(
          userImage: CommentBox.commentImageParser(
              imageURLorPath: "${user.image}"),
          child: commentChild(),
          labelText: 'Write a comment...',
          errorText: 'Comment cannot be blank',
          withBorder: false,
          sendButtonMethod: () {
            commentPost(parentId,userReceiver);
            setState(() {
              commentController.text = "";
            });
          },
          formKey: formKey,
          commentController: commentController,
          backgroundColor: Color.fromARGB(255, 240, 240, 240),
          textColor: Color.fromARGB(255, 7, 7, 7),
          sendWidget: Icon(Icons.send_sharp, size: 30, color: Color.fromARGB(255, 0, 0, 0)),
        )); 
  }
  
  void commentPost(String parentId,User userReceiver) async{
    if(commentController.text!=""){
        // ignore: unnecessary_null_comparison
        String userid = userReceiver != null ? userReceiver.id! :  "";
        CommentPost comment = CommentPost(id: "",userId: auth.FirebaseAuth.instance.currentUser!.uid,postId:(jsonPost!["post"] as Post).id,parentId: parentId,receiver: userid,content: commentController.text,createDate: DateTime.now());
    CreateNewData("Comment", comment);
    if(parentId!=""){
        ((jsonListComment!.firstWhere((element) => (element["parentComment"] as CommentPost).id==parentId))["jsonSubComment"] as List<Map<String,Object>>).add({"subComment":comment,"userSubComment":user});
        NotificationObject notification = NotificationObject(id: "",content: "${user.firstName} ${user.lastName} đã nhắc bạn trong bài viết bạn quan tâm.",receiver: (jsonPost!["post"] as Post).createBy,createDate: DateTime.now(),idObject: (jsonPost!["post"] as Post).id,sender: user.id);
       CreateNewData("Notification", notification);
       PushNotification.sendPushNotification(User(),"${user.firstName} ${user.lastName} đã bình luận một bài viết của bạn.",userReceiver.token!);
    }
    else{
       jsonListComment!.insert(0,{"parentComment":comment,"userComment":user,"jsonSubComment":<Map<String,Object>>[]});
      if((jsonPost!["post"] as Post).createBy != auth.FirebaseAuth.instance.currentUser!.uid){
          
       NotificationObject notification = NotificationObject(id: "",content: "${user.firstName} ${user.lastName} đã bình luận một bài viết của bạn.",receiver: (jsonPost!["post"] as Post).createBy,createDate: DateTime.now(),idObject: (jsonPost!["post"] as Post).id,sender: user.id);
       CreateNewData("Notification", notification);
       PushNotification.sendPushNotification(User(),"${user.firstName} ${user.lastName} đã bình luận một bài viết của bạn.",userReceiver.token!);
      }
    }
   (jsonPost!["post"] as Post).commentCount = (jsonPost!["post"] as Post).commentCount! + 1;
  updatePost((jsonPost!["post"] as Post));
    setState(() {
      jsonListComment;
      jsonPost;
    });
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


