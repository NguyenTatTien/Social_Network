import 'package:do_an_tot_nghiep/DAO/DAOHepper.dart';
import 'package:do_an_tot_nghiep/Models/Post.dart';
import 'package:do_an_tot_nghiep/Models/User.dart';
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
  var posts = <List<Object>>[];
  
   Future inintall()async{
    posts = await listPost("Post");
    var times = <String>[];
    for(var post in (posts[0] as List<Post>)){
      var durationDate = DateTime.now().difference(post.createDate!);
        // ignore: prefer_interpolation_to_compose_strings
        times.add(durationDate.inSeconds<60?durationDate.inSeconds.toString()+" giây":durationDate.inMinutes<60?durationDate.inMinutes.toString()+" phút":durationDate.inHours<60?durationDate.inHours.toString()+" giờ":durationDate.inDays<10?durationDate.inDays.toString()+" ngày":DateFormat("dd/MM/yyyy").format(post.createDate!).toString());
    }
    posts.add(times);
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
  @override
  Widget build(BuildContext context) {
    
    return 
   Column(
    children: [
      for(int i =0;i<posts.length-1;i++)

      
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
                        child: const CircleAvatar(
                          backgroundImage: AssetImage(
                            'assets/images/tien.jpg'
                          ),
                        )),
                        
                  ],
                ),
              ),
              // ignore: avoid_unnecessary_containers
              Container(child: Column(children: [
                 SizedBox(width: 150,child: Text("${(posts[1][i] as User).firstName} ${(posts[1][i] as User).lastName}",textAlign: TextAlign.left,style: TextStyle(fontWeight:FontWeight.bold,fontSize: 13),),),
                // ignore: sized_box_for_whitespace, unnecessary_string_interpolations
                Container(width: 150,child: Text("${(posts[2][i] as String).toString()}",textAlign: TextAlign.left,style: TextStyle(fontSize: 13),),),
              ],),)
        ],
      ),
      Container(margin:const EdgeInsets.fromLTRB(10, 5, 0, 5),width: double.infinity,child: Text("${(posts[0][i] as Post).postContent}",textAlign: TextAlign.left,style: const TextStyle(fontSize: 13),),),
      // ignore: sized_box_for_whitespace
      Container(width: double.infinity,child: Image.network("${(posts[0][i] as Post).postImage}"),),

       const Padding(
                padding: EdgeInsets.only(left: 5, right: 5),
                
                child: Divider(color: Color.fromARGB(95, 46, 46, 46),),
              ),
      Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
        Row(
          children: [
            // ignore: avoid_unnecessary_containers
            Container(child: const Icon(Icons.favorite_border,size: 20,),),
            Container(margin: const EdgeInsets.only(left: 5),child: const Text("Thích",style: TextStyle(fontSize: 13,color: Colors.black87),),)
          ],
        ),
         Row(
          children: [
            // ignore: avoid_unnecessary_containers
            Container(child: const Icon(Icons.messenger_outline,size: 20,),),
            Container(margin: const EdgeInsets.only(left: 5),child: const Text("Bình luận",style: TextStyle(fontSize: 13,color: Colors.black87),),)
          ],
        ),
         Row(
          children: [
            const Icon(Icons.share,size: 20,),
            Container(margin: const EdgeInsets.only(left: 5),child: const Text("Chia sẽ",style: TextStyle(fontSize: 13,color: Colors.black87),),)
          ],
        )
      ],), const Divider(color: Color.fromARGB(95, 46, 46, 46),thickness: 5,),
      

    ],)
    ]);
  }
}
