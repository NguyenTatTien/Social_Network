import 'package:do_an_tot_nghiep/DAO/DAOHepper.dart';
import 'package:do_an_tot_nghiep/Models/Like.dart';
import 'package:do_an_tot_nghiep/Models/Notification.dart';
import 'package:do_an_tot_nghiep/Models/Post.dart';
import 'package:do_an_tot_nghiep/Models/User.dart';
import 'package:do_an_tot_nghiep/NotificationService/PushNotification.dart';
import 'package:do_an_tot_nghiep/Views/pageComment.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

// ignore: must_be_immutable
class FirstFeedIU extends StatefulWidget {
  const FirstFeedIU({super.key});

  @override
  State<FirstFeedIU> createState() => _FirstFeedIUState();
}

class _FirstFeedIUState extends State<FirstFeedIU> {
  var posts = <Map<String,Object>>[];
  
   Future inintall()async{
    posts = await listPost("Post",auth.FirebaseAuth.instance.currentUser!.uid);
    setState(() {
      posts;
    });
  }
  @override
  void initState() {
    inintall();
    // TODO: implement initState
    super.initState();
  }
  likePost(Post post) async{
    post.likeCount=post.likeCount! + 1;
    updatePost(post);
    Like like = Like(id: "",postId: post.id,userId: auth.FirebaseAuth.instance.currentUser!.uid,createDate: DateTime.now());
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
      // ((posts.firstWhere((element) => (element["post"] as Post).id==id)["listUserLikePost"]) as List<Like>).remove((element) => element.userId==auth.FirebaseAuth.instance.currentUser!.uid);
      ((posts.firstWhere((element) => (element["post"] as Post).id==post.id)["listUserLikePost"]) as List<Like>).add(like);
    });
    
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
  @override
  Widget build(BuildContext context) {
    
    return 
   Column(
    children: [
      if(posts.isNotEmpty)
        for(int i = 0;i<posts.length;i++)
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
                                  '${(posts[i]["user"] as User).image}'
                                ),
                              )),
                              
                        ],
                      ),
                    ),
                    // ignore: avoid_unnecessary_containers
                    Container(child: Column(children: [
                      SizedBox(width: 150,child: Text("${(posts[i]["user"] as User).firstName} ${(posts[i]["user"] as User).lastName}",textAlign: TextAlign.left,style: TextStyle(fontWeight:FontWeight.bold,fontSize: 13),),),
                      // ignore: sized_box_for_whitespace, unnecessary_string_interpolations
                      Container(width: 150,child: Text("${(posts[i]["timePost"] as String).toString()}",textAlign: TextAlign.left,style: TextStyle(fontSize: 13),),),
                    ],),)
              ],
            ),
            Container(margin:const EdgeInsets.fromLTRB(10, 5, 0, 5),width: double.infinity,child: Text("${(posts[i]["post"] as Post).postContent}",textAlign: TextAlign.left,style: const TextStyle(fontSize: 13),),),
            // ignore: sized_box_for_whitespace
            Container(width: double.infinity,child: Image.network("${(posts[i]["post"] as Post).postImage}"),),
            if((posts[i]["post"] as Post).likeCount! > 0||(posts[i]["post"] as Post).commentCount! > 0)
              const Padding(
                                  padding: EdgeInsets.only(top: 5, bottom: 5),
                                  
                                  
                                ),
            if((posts[i]["post"] as Post).likeCount! > 0||(posts[i]["post"] as Post).commentCount! > 0)
              
                Container(padding: EdgeInsets.symmetric(horizontal: 25),child:Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                if((posts[i]["post"] as Post).likeCount! > 0)
                Row(
                  children: [
                    // ignore: avoid_unnecessary_containers
                  
                    InkWell(child: const Icon(Icons.favorite,size: 20,color: Colors.pink,),onTap: (){},),
                          Container(margin: const EdgeInsets.only(left: 5),child: Text("${(posts[i]["post"] as Post).likeCount}",style: TextStyle(fontSize: 13,color: Colors.black87),),)
                        ],
                      ),
                      if((posts[i]["post"] as Post).commentCount! > 0)
                      Row(
                        children: [
                          // ignore: avoid_unnecessary_containers
                          Container(child: const Icon(Icons.message,size: 20,),),
                          Container(margin: const EdgeInsets.only(left: 5),child: Text("${(posts[i]["post"] as Post).commentCount}",style: TextStyle(fontSize: 13,color: Colors.black87),),)
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
              if((posts[i]["listUserLikePost"] as List<Like>).where((element)=>element.userId==auth.FirebaseAuth.instance.currentUser!.uid).isEmpty)
                    InkWell(onTap: (){likePost((posts[i]["post"] as Post));},child:  Row(
                        children: [
                          // ignore: avoid_unnecessary_containers
                          const Icon(Icons.favorite_border,size: 20,),
                          Container(margin: const EdgeInsets.only(left: 5),child: const Text("Thích",style: TextStyle(fontSize: 13,color: Colors.black87),),)
                        ],
                      ),),
              if((posts[i]["listUserLikePost"] as List<Like>).where((element)=>element.userId==auth.FirebaseAuth.instance.currentUser!.uid).isNotEmpty)
                      InkWell(onTap: (){notLikePost((posts[i]["post"] as Post));},child:  Row(
                        children: [
                          // ignore: avoid_unnecessary_containers
                          const Icon(Icons.favorite,size: 20,color: Colors.pink,),
                          Container(margin: const EdgeInsets.only(left: 5),child: const Text("Thích",style: TextStyle(fontSize: 13,color: Colors.black87),),)
                        ],
                      ),),
              InkWell(onTap: (){Navigator.push(context, MaterialPageRoute(builder: (context)=> PageComment((posts[i]))));},child:Row(
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
          ],)
    else
      const Center(child:Text("Không có bài viết nào!",style: TextStyle(fontSize: 12),))
    ]);
  }
}
