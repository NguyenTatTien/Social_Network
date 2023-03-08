import 'package:do_an_tot_nghiep/Models/User.dart';
import 'package:do_an_tot_nghiep/Views/Chat.dart';
import 'package:do_an_tot_nghiep/Views/EditProfile.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// ignore: unnecessary_import
import 'package:flutter/services.dart';
// ignore: import_of_legacy_library_into_null_safe
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
  User? user;
  _ProfileState(this.id);
  Future getUser() async{
    print(id);
     var collection = FirebaseFirestore.instance.collection("User");
     var docSnapshot =  await collection.doc(id).get();
     print(docSnapshot);
    setState(() {
      user = User.fromJson(docSnapshot.data()!);
     
    });
     
    
     
      
  }
  @override
  void initState()  {
    user = User();
    getUser();
    // TODO: implement initState
    super.initState();
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
          child: Container(
            padding: const EdgeInsets.fromLTRB(15, 35, 15, 15),
            child: Column(
              children: <Widget>[
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage('assets/images/tien.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  "${user!.firstName} ${user!.lastName}",
                  style: kLargeTextStyle,
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  '${user!.email}',
                  style: kTitleTextStyle,
                ),
                const SizedBox(
                  height: 25,
                ),
                
               
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    PostFollower(
                      number: 80,
                      title: 'Posts',
                    ),
                    PostFollower(
                      number: 110,
                      title: 'Followers',
                    ),
                    PostFollower(
                      number: 152,
                      title: 'Following',
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
               Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Column(
                            children: <Widget>[
                              IconButton(
                                icon: Icon(Icons.collections,color: Colors.blueAccent), onPressed: () {  },
                              ),
                              Text('following',style: TextStyle(
                                color: Colors.blueAccent
                              ),)
                            ],
                          ),
                          Column(
                            children: <Widget>[
                              IconButton(
                                icon: Icon(Icons.message,color: Colors.black), onPressed: () {  },
                              ),
                              Text('Message',style: TextStyle(
                                color: Colors.black
                              ),)
                            ],
                          ),
                          Column(
                            children: <Widget>[
                              IconButton(
                                icon: Icon(Icons.more_vert,color: Colors.black),
                                onPressed: (){
                                  
                                },
                              ),
                              Text('More',style: TextStyle(
                                color: Colors.black
                              ),)
                            ],
                          )
                        ],
                      ),
                    ),
                    SizedBox(height: 10.0,),
                    Container(
                      padding: EdgeInsets.only(left: 10.0,right: 10.0),
                      child: Column(
                        children: <Widget>[
                          Row(children: <Widget>[
                            Icon(Icons.work),
                            SizedBox(width: 5.0,),
                            Text('Founder and CEO at',style: TextStyle(
                              fontSize: 18.0
                            ),),
                            SizedBox(width: 5.0,),
                            Text('SignBox',style: TextStyle(
                            fontSize: 18.0,
                              fontWeight: FontWeight.bold
                            ),)
                          ],),
                          SizedBox(height: 10.0,),
                          Row(children: <Widget>[
                            Icon(Icons.work),
                            SizedBox(width: 5.0,),
                            Text('Works at',style: TextStyle(
                              fontSize: 18.0
                            ),),
                            SizedBox(width: 5.0,),
                            Text('SignBox',style: TextStyle(
                            fontSize: 18.0,
                              fontWeight: FontWeight.bold
                            ),)
                          ],),
                          SizedBox(height: 10.0,),
                          Row(children: <Widget>[
                            Icon(Icons.school),
                            SizedBox(width: 5.0,),
                            Text('Studied Computer Science at',style: TextStyle(
                              fontSize: 18.0
                            ),),
                            SizedBox(width: 5.0,),                            
                          ],),
                          Wrap(
                            children: <Widget>[
                              Text('Abc University',style: TextStyle(
                            fontSize: 18.0,
                              fontWeight: FontWeight.bold
                            ),)
                            ],
                          ),

SizedBox(height: 10.0,),
                          Row(children: const <Widget>[
                            Icon(Icons.home),
                            SizedBox(width: 5.0,),
                            Text('Lives in',style: TextStyle(
                              fontSize: 18.0
                            ),),
                            SizedBox(width: 5.0,),    
                            Text('Pakistan',style: TextStyle(
                            fontSize: 18.0,
                              fontWeight: FontWeight.bold
                            ),)                        
                          ],),


                          SizedBox(height: 10.0,),
                          Row(children: const <Widget>[
                            Icon(Icons.location_on),
                            SizedBox(width: 5.0,),
                            Text('From',style: TextStyle(
                              fontSize: 18.0
                            ),),
                            SizedBox(width: 5.0,), 
                            Text('Lahore',style: TextStyle(
                            fontSize: 18.0,
                              fontWeight: FontWeight.bold
                            ),)                           
                          ],),
                            if(user!.id == auth.FirebaseAuth.instance.currentUser!.uid)
                                  Row(children: <Widget>[
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () { Navigator.push(context, MaterialPageRoute(builder: (context)=> const EditProfile())); },
                                    child: const Text('Edit Information'),
                                  ),
                                )
                                ],),


                              ],
                      ),)
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
      ),
    );
  }
}
// class GalleryImage extends StatelessWidget {
//   final String? imagePath;

//   GalleryImage({@required this.imagePath});

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
      margin: EdgeInsets.symmetric(
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
