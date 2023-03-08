import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:file_picker/file_picker.dart';

import 'editorText.dart';
// ignore: camel_case_types, must_be_immutable
class addImagePost extends StatelessWidget {
  PlatformFile? pickFiles;

  addImagePost({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: 
      ElevatedButton(onPressed: () async{
              FilePickerResult? result = await FilePicker.platform.pickFiles();
              // ignore: unnecessary_null_comparison
             
              if(result!=null)
              {
                pickFiles = result.files.first;
                // ignore: curly_braces_in_flow_control_structures, use_build_context_synchronously
                Navigator.push(context, MaterialPageRoute(builder: (context)=> EditorText(pickFiles!.path)));
              }
            },child: const Text("Upload image"),),
    ),);
  }
}