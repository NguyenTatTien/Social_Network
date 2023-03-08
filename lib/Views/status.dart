import 'dart:io';

import 'package:do_an_tot_nghiep/Views/Profile.dart';
import 'package:do_an_tot_nghiep/Views/addImagePost.dart';
import 'package:do_an_tot_nghiep/Views/editorText.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';



// ignore: must_be_immutable
class Status extends StatelessWidget {
  List images = ["tien.jpg","person1.jpg","person2.jpg","person3.jpg","person4.jpg","person5.jpg","person6.jpg","person7.jpg","person8.jpg"];
  // ignore: non_constant_identifier_names
  List first_name = ["Tiến","Vinh","Trang","Nhung","Luân","Quỳnh","Vi","Khoa","Trinh"];
  // ignore: non_constant_identifier_names
  List last_name = ["Nguyễn","Hồ Trọng","Nguyễn","Nguyễn","Nguyễn Minh","Như","Trần","Nguyễn Đăng","Nguyễn Thị"];

  Status({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: ListView.builder(

          itemCount: 9,
          scrollDirection: Axis.horizontal,
          itemExtent: 75,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return InkWell(
              onTap: (){
                if(index==0){
                  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
                  var uid = firebaseAuth.currentUser!.uid;
                   Navigator.push(context, MaterialPageRoute(builder: (context)=> Profile(uid)));
                }
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
                          backgroundImage: AssetImage(
                            'assets/images/${images[index]}'
                          ),
                        )),
                        if (index == 0)
                            Positioned(
                              bottom: 0,
                              right: 5, //give the values according to your requirement
                              child: InkWell(onTap: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context)=> addImagePost()));
                            }, child:Material(
                                  color: Colors.orange,
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
                  text: '${first_name[index]}',
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
                  text: '${last_name[index]}',
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
