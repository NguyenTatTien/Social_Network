
import 'dart:io';

import 'package:do_an_tot_nghiep/DAO/DAOHepper.dart';
import 'package:do_an_tot_nghiep/Models/Post.dart';
import 'package:do_an_tot_nghiep/Views/Navigation.dart';
import 'package:file_picker/src/file_picker_result.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';


// ignore: must_be_immutable
class EditorText extends StatefulWidget {
  String? url;
  EditorText(this.url,{super.key});

  @override
  // ignore: no_logic_in_create_state
  State<EditorText> createState() => _EditorTextState(url!);
}

class _EditorTextState extends State<EditorText> {
  String? url;
  var controlerText = TextEditingController();
  _EditorTextState(this.url);

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: 
      SingleChildScrollView(
child: Column(
    children: [Container(margin: const EdgeInsets.fromLTRB(5, 40, 5, 10),
                child: 
              TextField(controller: controlerText,maxLines: 10,minLines: 5,style: const TextStyle(fontSize: 15),decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),hintText: "Nhập văn bản...",filled: true),
              
              ),
              ),
              Image.file(File(url!),width: double.infinity,fit: BoxFit.cover,)
              ]
    )),
     bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
        child: ElevatedButton(
          onPressed: () async{
               final file = File(url!);
               
              var firebaseStorage =  FirebaseStorage.instance.ref().child("image/${FirebaseAuth.instance.currentUser!.uid}/${DateTime.now().toString()}");
              await firebaseStorage.putFile(file);
              String urlImage = await firebaseStorage.getDownloadURL();
              Post post = Post(id: "",postContent: controlerText.text,postImage:urlImage ,commentCount: 0,likeCount: 0,createBy: FirebaseAuth.instance.currentUser!.uid,createDate: DateTime.now(),updatedDate:DateTime.now());
              CreateNewData("Post", post);
              // ignore: use_build_context_synchronously
              Navigator.push(context, MaterialPageRoute(builder: (context)=> const NavigatorView()));
          },
          
          child: const Text('Đăng bài'),
        ),
      ),
    

    );
  }
}