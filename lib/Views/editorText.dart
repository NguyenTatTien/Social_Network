
import 'dart:io';

import 'package:do_an_tot_nghiep/DAO/DAOHepper.dart';
import 'package:do_an_tot_nghiep/Models/Post.dart';
import 'package:do_an_tot_nghiep/Views/Navigation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_picker/src/file_picker_result.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';


// ignore: must_be_immutable
class EditorText extends StatefulWidget {
  String? url;
  Post? post;
  EditorText(this.url,this.post,{super.key});

  @override
  // ignore: no_logic_in_create_state
  State<EditorText> createState() => _EditorTextState(url!,post);
}

class _EditorTextState extends State<EditorText> {
  String? url;
  Post?post;
  var controlerText = TextEditingController();
   PlatformFile? pickFiles;
  _EditorTextState(this.url,this.post);

  
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
             File(url!).isAbsolute==true? Image.file(File(url!),width: double.infinity,fit: BoxFit.cover,):Image.network(url!,width: double.infinity,fit: BoxFit.cover,)
              ]
    )),
     bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
        child:
        post!.id==null?
        ElevatedButton(
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
        ):Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
          ElevatedButton(
          onPressed: () async{
              FilePickerResult? result = await FilePicker.platform.pickFiles();
              // ignore: unnecessary_null_comparison
             
              if(result!=null)
              {
                pickFiles = result.files.first;
                // ignore: curly_braces_in_flow_control_structures, use_build_context_synchronously
                url = pickFiles!.path;
                setState(() {
                  url;
                });
              }
              // ignore: use_build_context_synchronously
             
          },
          
          child: const Text('Thay hình ảnh'),
        ),
        ElevatedButton(
          onPressed: () async{
              final file = File(url!);
               
              if(file.isAbsolute){
                String urlImage = await updateImageByPost(post!.postImage!, "image/${FirebaseAuth.instance.currentUser!.uid}/${DateTime.now().toString()}",file);
                post!.postImage = urlImage;

              }
              post!.postContent = controlerText.text;
            updatePost(post!);
              // ignore: use_build_context_synchronously
              Navigator.push(context, MaterialPageRoute(builder: (context)=> const NavigatorView()));
          },
          
          child: const Text('Lưu thay đổi'),
        )
        ],),
      ),
    

    );
  }
}