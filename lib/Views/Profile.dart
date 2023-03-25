import 'package:do_an_tot_nghiep/DAO/DAOHepper.dart';
import 'package:do_an_tot_nghiep/Models/Like.dart';
import 'package:do_an_tot_nghiep/Models/Notification.dart';
import 'package:do_an_tot_nghiep/Models/Post.dart';
import 'package:do_an_tot_nghiep/Models/User.dart';
import 'package:do_an_tot_nghiep/NotificationService/PushNotification.dart';
import 'package:do_an_tot_nghiep/Views/Chat.dart';
import 'package:do_an_tot_nghiep/Views/EditProfile.dart';
import 'package:do_an_tot_nghiep/Views/PageComment.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// ignore: unnecessary_import
import 'package:flutter/services.dart';
// ignore: import_of_legacy_library_into_null_safe, unused_import
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
  var posts = <Map<String,Object>>[];
  _ProfileState(this.id);
  getData() async{
    user = await getUserById(id!);
    if(auth.FirebaseAuth.instance.currentUser!.uid==id){
      print("a");
      posts = await listPostByUser(id!);
    }
    else{
      bool check = await checkFriend(auth.FirebaseAuth.instance.currentUser!.uid, id!);
      print(auth.FirebaseAuth.instance.currentUser!.uid+" : "+id!);
      print(check);
      if(check){
          print("b");
         posts = await listPostByUser(id!);
      }
    }
   
    setState(() {
      user;
    });
  }

  @override
  void initState()  {
    user = User();
    getData();
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
    return Scaffold(
      appBar:  AppBar(
        elevation: 0,
        leading: const Icon(Icons.turn_left, color: Colors.black87,),
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
              children: <Widget>[ Container(
            
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
                  if(user.id!=auth.FirebaseAuth.instance.currentUser!.uid)
                       Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Column(
                            children: <Widget>[
                              
                              
                                    IconButton(
                                    icon: const Icon(Icons.collections,color: Colors.blueAccent), onPressed: () {  },
                                  ),
                                  const Text('Kết bạn',style: TextStyle(
                                    color: Colors.blueAccent
                                  ),)
                            ],
                          ),
                          Column(
                            children: <Widget>[
                              IconButton(
                                icon: const Icon(Icons.message,color: Colors.black), onPressed: () {  },
                              ),
                              const Text('Nhắn tin',style: TextStyle(
                                color: Colors.black
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
                ],), const Divider(color: Color.fromARGB(95, 46, 46, 46),thickness: 5,)])]))
                

                             
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
