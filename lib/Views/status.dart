import 'dart:io';

import 'package:do_an_tot_nghiep/DAO/DAOHepper.dart';
import 'package:do_an_tot_nghiep/Models/User.dart';
import 'package:do_an_tot_nghiep/Views/Design.dart';
import 'package:do_an_tot_nghiep/Views/Profile.dart';
import 'package:do_an_tot_nghiep/Views/addImagePost.dart';
import 'package:do_an_tot_nghiep/Views/editorText.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class Status extends StatefulWidget {
  const Status({super.key});

  @override
  State<Status> createState() => _StatusState();
}

class _StatusState extends State<Status> {
   User? user;
   List images = ["tien.jpg","person1.jpg","person2.jpg","person3.jpg","person4.jpg","person5.jpg","person6.jpg","person7.jpg","person8.jpg"];
  // ignore: non_constant_identifier_names
  List first_name = ["Tiến","Vinh","Trang","Nhung","Luân","Quỳnh","Vi","Khoa","Trinh"];
  // ignore: non_constant_identifier_names
  List last_name = ["Nguyễn","Hồ Trọng","Nguyễn","Nguyễn","Nguyễn Minh","Như","Trần","Nguyễn Đăng","Nguyễn Thị"];
  var listUserStatus = <User>[];
  @override
  void initState() {
    user = User();
    // TODO: implement initState
    getUser();
    getListFriend();
    super.initState();
  }
  getUser() async{
    user = await getUserById(auth.FirebaseAuth.instance.currentUser!.uid);
    listUserStatus.add(user!);
    setState(() {
      user;
    });
   
    first_name[0] = user!.firstName;
    last_name[0] = user!.lastName;
  }
  getListFriend() async{
     listUserStatus.addAll(await getAllFriend(auth.FirebaseAuth.instance.currentUser!.uid));
    setState(() {
        listUserStatus;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: ListView.builder(

          itemCount: listUserStatus.length,
          scrollDirection: Axis.horizontal,
          itemExtent: 75,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return InkWell(
              onTap: (){
                   Navigator.push(context, MaterialPageRoute(builder: (context)=> Profile(listUserStatus[index].id)));
                
              },
              child: Column(
           
            children: [
              Container(
               
                decoration: const BoxDecoration(color: Colors.white),
                height: 90,
                child: Stack(
                  children: <Widget>[
                    Container(
                        height: 65,
                        width: 65,
                        margin: const EdgeInsets.only(
                            left: 0, right: 0, top: 20, bottom: 5),
                        padding: const EdgeInsets.all(2.0),
                        decoration: BoxDecoration(
                            border:
                                Border.all(color: const Color.fromARGB(255, 0, 207, 142), width: 2),
                            borderRadius: BorderRadius.circular(100)),
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(
                            '${listUserStatus[index].image}'
                          ),
                        )),
                        if (index == 0)
                            Positioned(
                              bottom: 0,
                              right: 5, //give the values according to your requirement
                              child: InkWell(onTap: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context)=> addImagePost()));
                            }, child:Material(
                                  color: mainColor,
                                  elevation: 10,
                                  borderRadius: BorderRadius.circular(100),
                                  child: const Padding(
                                    padding: EdgeInsets.all(3.0),
                                    child: Icon(
                                      Icons.add,
                                      size: 18,
                                      color: Colors.white,
                                    ),
                                  )),)
                            )
                  ],
                ),
              ),
            // ignore: sized_box_for_whitespace
            Container(
                  width: 60,
                 
                  child: RichText(
                    textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  strutStyle: const StrutStyle(fontSize: 12.0),
                  text: TextSpan(
                  text: '${listUserStatus[index].firstName}',
                  style: GoogleFonts.lato(
                      color: Colors.grey[700],
                      fontSize: 11,
                      
                      letterSpacing: 1,
                      fontWeight: FontWeight.normal),
                    
                ),)),
              
                
                // ignore: sized_box_for_whitespace
                Container(
                  width: 60,
                 
                  child: RichText(
                    textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  strutStyle: const StrutStyle(fontSize: 12.0),
                  text: TextSpan(
                  text: '${listUserStatus[index].lastName}',
                  style: GoogleFonts.lato(
                      color: Colors.grey[700],
                      fontSize: 11,
                      
                      letterSpacing: 1,
                      fontWeight: FontWeight.normal),
                    
                ),))
              
            ],
          ));
          },
        ),
          
        
    );
  }
}

// ignore: must_be_immutable